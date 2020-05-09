//
//  TestGame.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 14.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

private class TimeHandler: PXEntity {
    private let context: GameContext
    override func update() {
        context.time += 1
    }
    init(context: GameContext) {
        self.context = context
        super.init(name: "Time counter")
    }
}

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
            path: Bundle.main.resourceURL!.appendingPathComponent("Textures"))
        try! PXConfig.resourceManager.loadTiles(
            path: Bundle.main.url(
                forResource: "tiles", withExtension: "json",
                subdirectory: "Descriptors")!)
        try! PXConfig.fontManager.loadAllFonts(
            path: Bundle.main.resourceURL!.appendingPathComponent("Fonts"))


        // Create game context
        gameContext = GameContext()
        gameContext.luaVM = LuaVM()
                

        let urls = Bundle.main.urls(forResourcesWithExtension: "lua", subdirectory: "Scripts/Core")!
        for url in urls {
            gameContext.luaVM.loadLModule(url, name: url.deletingPathExtension().lastPathComponent)
        }
        
        // Create scene
        let scene = PXScene(width: 100, height: 100)
        scene.addEntity(TimeHandler(context: gameContext))

        // Create player
        playerController = HUDController()
        let playerSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "sprite_player"))
        player = Character(context: gameContext, name: "Player", controller: playerController, sprite: playerSprite)

        player.pos = PXv2f(16, 16)
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
        for x in 1..<99 {
            for y in 1..<99 {
                let id = 1//Int.random(in: 0...1)
                let tile: PXTile = PXTile(id: id)!
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

        let light = PXFollowLight(name: "PlayerLight", amount: 3.0, color: PXColor(r: 0.3, g: 0, b: 1, a: 1.0), radius: 200)
        light.target = player
        gameContext.playerLight = light
        scene.addEntity(light)

        gameContext.currentScene = scene
        renderer.scene = scene

        let text = PXText(text: "0")
        text.pos = 32 * .ones
        scene.addHudEntity(text)
        gameContext.scoreText = text
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
            let spell = Projectile(name: "Fireball!", context: gameContext)
            spell.drawable.sprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "proj_fire_ball"))
//            spell.velocity = 8 * player.viewDirection
            spell.controller = LuaProjectileController(vm: gameContext.luaVM, moduleName: "fireball")
            spell.center = player.center


            let light = PXFollowLight(name: "Fireball Light",
                                      amount: 1.0,
                                      color: PXColor(r: 1.0, g: 0.5, b: 0, a: 1.0),
                                      radius: 200)

            light.target = spell
            gameContext.currentScene.addEntity(spell)
            gameContext.currentScene.addEntity(light)

            gameContext.score += 1
            gameContext.scoreText.text = String(gameContext.score)

            gameContext.player.recieveDamage(damage: 14)
        }
    }
}
