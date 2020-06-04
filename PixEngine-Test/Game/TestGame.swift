//
//  TestGame.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 14.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine
import UIKit

private class TimeHandler: PXEntity {
    private let context: GameContext

    private let module: LuaLModule = LuaLModule(functions: [
        LuaFunction(name: "onFrame", args: 0, res: 0)
    ])

    override func update() {
        context.time += 1
        context.timer -= 1
        context.timerText.text = "\(context.timer / 60)"
        context.lua.vm.call(module: module, script: "gamel", f: "onFrame")

        if context.timer <= 0 {
            context.game.endGame()
        }
    }
    init(context: GameContext) {
        self.context = context
        super.init(name: "Time counter")
    }
}

public class TestGame {
    private let renderer: PXRenderer
    private let scale: Int = 3

    private var screenW: Float {
        renderer.width / Float((scale))
    }
    private var screenH: Float {
        screenW / renderer.aspectRatio
    }
    private var screenDimensions: PXv2f {
        PXv2f(screenW, screenH)
    }

    private var player: Character!
    private var playerController: HUDController!

    private var jBg: PXStaticSprite!
    private var jPin: PXStaticSprite!
    private var jOrigin: PXv2f {
        PXv2f(0, screenH) + PXv2f(70, -70)
    }

    private var spellButton: PXStaticSprite!

    private var gameContext: GameContext

    private var parentView: UIViewController

    public func endGame() {
        gameContext.currentScene.paused = true
        let score = gameContext.score
        gameContext.scoreboard.acceptScore(score: score) { new in
            DispatchQueue.main.async {
                if new {
                    self.gameContext.highscore = score
                }
                let vc = ScoreVC(score: score, isHighscore: new) {
                    self.newGame()
                    self.gameContext.currentScene.paused = false
                }
                self.parentView.present(vc, animated: true)
            }
        }
    }

    private func newGame() {

        gameContext.score = 0

        // Create scene
        let scene = PXScene(width: 100, height: 100)
        scene.addEntity(TimeHandler(context: gameContext))

        // Create player
        playerController = HUDController()
        let playerSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "sprite_player"))
        player = Character(context: gameContext, name: "Player", controller: playerController, sprite: playerSprite)

        player.pos = PXv2f(16 * 50, 16 * 50)
        gameContext.player = player
        scene.addEntity(player)

        // Create HUD
        spellButton = PXStaticSprite(name: "Cast spell button",
                                     sprite: PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_pin")))
        spellButton.drawable.scale = 2

        jBg = PXStaticSprite(name: "Joystick background",
                             sprite: PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_bg")))

        jPin = PXStaticSprite(name: "Joystick pin",
                              sprite: PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_pin")))
        jPin.drawable.scale = 2
        spellButton.center = screenDimensions - 70.0 * .ones
        jPin.center = jOrigin

        scene.addHudEntity(spellButton)
        scene.addHudEntity(jPin)

        // Setup cameras
        let camera = PXFollowCamera(dimensions: screenDimensions, followBorder: (1 / 3.0) * screenDimensions, target: player)
        let hudCamera = PXCamera(dimensions: screenDimensions)

        scene.camera = camera
        scene.hudCamera = hudCamera

        scene.addEntity(camera)
        scene.addEntity(hudCamera)

        // Setup background
        for x in 0..<100 {
            for y in 0..<100 {
                let border = x == 0 || y == 0 || x == 99 || y == 99
                let id = border ? 1 : Int.random(in: 0...1)
                let tile: PXTile = PXTile(id: id)!
                tile.physics?.dynamic = false
                scene.setBackgroundTile(
                    x: x,
                    y: y,
                    tile: tile,
                    solid: border)
            }
        }

        let light = PXFollowLight(name: "PlayerLight", amount: 3.0, color: PXColor(r: 0.3, g: 0, b: 1, a: 1.0), radius: 200)
        light.target = player
        gameContext.playerLight = light
        scene.addEntity(light)

        gameContext.currentScene = scene
        renderer.scene = scene

        // Add score label
        let text = PXText(text: "0")
        text.pos = PXv2f(32, 32 + 20)
        scene.addHudEntity(text)
        gameContext.scoreText = text

        // Add time label
        let timeText = PXText(text: "0")
        timeText.pos = PXv2f(400, 32)
        scene.addHudEntity(timeText)
        gameContext.timerText = timeText

        gameContext.timer = 60 * 10

        // Add highscore label
        let hsText = PXText(text: "0")
        hsText.pos = PXv2f(32, 32)
        scene.addHudEntity(hsText)
        gameContext.hsText = hsText
        gameContext.highscore = gameContext.highscore


    }

    internal init(renderer: PXRenderer, view: UIViewController) {
        self.renderer = renderer
        self.parentView = view

        try! PXConfig.sharedTextureManager.loadAllTextures(
            path: Bundle.main.resourceURL!.appendingPathComponent("Textures"))
        try! PXConfig.resourceManager.loadTiles(
            path: Bundle.main.url(
                forResource: "tiles", withExtension: "json",
                subdirectory: "Descriptors")!)
        try! PXConfig.fontManager.loadAllFonts(
            path: Bundle.main.resourceURL!.appendingPathComponent("Fonts"))


        // Create game context
        gameContext = GameContext()
        gameContext.lua = LuaScripting(context: gameContext)

        // Create scoreboard
        gameContext.scoreboard = Scoreboard(provider: FirebaseScoreboardProvider())

        gameContext.game = self

        gameContext.scoreboard.ensureRegistered {
            DispatchQueue.main.async {
                self.newGame()
                self.gameContext.scoreboard.getHighscore { (hs) in
                    DispatchQueue.main.async {
                        self.gameContext.highscore = hs ?? 0
                    }
                }
            }
        }
    }

    // MARK: Buttons

    private func onSpellButtonClicked() {
        endGame()
    }

    // MARK: User actions

    private var active: Bool = false

    public func panStart(_ xn: Float, _ yn: Float) {
        let x = xn * screenW
        let y = yn * screenH
        if x >= jPin.pos.x && x <= jPin.pos.x + jPin.width &&
            y >= jPin.pos.y && y <= jPin.pos.y + jPin.height {
            debugPrint("start")
            active = true
        }
    }

    public func panEnd() {
        if !active {
            return
        }
        playerController.setJoystickTilt(.zero)
        debugPrint("end")
        active = false
        jPin.center = jOrigin
    }

    public func panUpdate(_ xn: Float, _ yn: Float) {
        if !active {
            return
        }
        let x = xn * screenW
        let y = yn * screenH
        let dVec: (PXv2f) = PXv2f(x, y)
        let dist = min(dVec.abs / (jBg.width / 2.0), 1)
//        print(dVec.abs, dist)
        jPin.center = jOrigin + dist * (jBg.width / 2.0) * (dVec.normalize())
        playerController.setJoystickTilt(dist * (dVec.normalize()))
    }

    public func onTap(_ xn: Float, _ yn: Float) {
        let tapPos = PXv2f(xn * screenW, yn * screenH)
        if spellButton.isInside(point: tapPos) {
            onSpellButtonClicked()
        }
    }
}
