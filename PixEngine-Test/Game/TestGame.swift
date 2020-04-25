//
//  TestGame.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 14.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

class TestGame {
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

    private var player: Character
    private var playerController: HUDController

    private var jBg: PXStaticSprite
    private var jPin: PXStaticSprite
    private var jOrigin: PXv2f {
        PXv2f(0, screenH) + PXv2f(70, -70)
    }

    private var spellButton: PXStaticSprite

    private var gameContext: GameContext

    internal init(renderer: PXRenderer) {
        self.renderer = renderer

        try! PXConfig.sharedTextureManager.loadAllTextures(
            path: Bundle.main.resourceURL!)
        try! PXConfig.resourceManager.loadTiles(
            path: Bundle.main.resourceURL!.appendingPathComponent("tiles.json"))


        // Create game context
        gameContext = GameContext()

        // Create scene
        let scene = PXScene(width: 100, height: 100)

        // Create player
        playerController = HUDController()
        player = Character(context: gameContext, name: "Player", controller: playerController)
        player.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "sprite_player"))

        player.pos = PXv2f(300, 300)
        scene.addEntity(player)

        // Create HUD
        spellButton = PXStaticSprite(name: "Spell button")
        spellButton.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_pin"))

        jBg = PXStaticSprite(name: "Joystick background")
        jBg.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_bg"))

        jPin = PXStaticSprite(name: "Joystick pin")
        jPin.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_pin"))

        jPin.scale = 2
        jPin.center = jOrigin
        spellButton.scale = 2
        spellButton.center = screenDimensions - 70.0 * .ones

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
        for x in 1..<99 {
            for y in 1..<99 {
                let tile: PXTile = PXTile(id: Int.random(in: 0...1))!
                scene.setBackgroundTile(
                    x: x,
                    y: y,
                    tile: tile)
            }
        }

        for x in 0..<100 {
            for y in [0, 99] {
                let tile: PXTile = PXTile(id: 1)!
                tile.solid = true
                scene.setBackgroundTile(
                    x: x,
                    y: y,
                    tile: tile)
            }
        }

        for y in 0..<100 {
            for x in [0, 99] {
                let tile: PXTile = PXTile(id: 1)!
                tile.solid = true
                scene.setBackgroundTile(
                    x: x,
                    y: y,
                    tile: tile)
            }
        }

        gameContext.currentScene = scene
        renderer.scene = scene
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
            let spell = Projectile(name: "Fireball!")
            spell.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "proj_fire_ball"))
            spell.velocity = 8 * player.viewDirection
            spell.center = player.center

            gameContext.currentScene.addEntity(spell)
        }
    }
}
