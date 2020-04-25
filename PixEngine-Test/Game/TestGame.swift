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
    private var screenW: Float {
        renderer.width / (3.0 * 4.0)
    }
    private var screenH: Float {
        screenW / renderer.aspectRatio
    }
    private var screenDimensions: PXv2f {
        PXv2f(screenW, screenH)
    }
    private var currentScene: PXScene

    private var player: Character
    private var playerController: HUDController

    private var jBg: PXStaticSprite
    private var jPin: PXStaticSprite
    private var jOrigin: PXv2f {
        PXv2f(0, screenH) + PXv2f(40, -40)
    }

    internal init(renderer: PXRenderer) {
        self.renderer = renderer

        try! PXConfig.sharedTextureManager.loadAllTextures(
            path: Bundle.main.resourceURL!)
        try! PXConfig.resourceManager.loadTiles(
            path: Bundle.main.resourceURL!.appendingPathComponent("tiles.json"))


        // Create scene
        currentScene = PXScene(width: 100, height: 100)

        // Create player
        playerController = HUDController()
        player = Character(name: "Player", controller: playerController)
        player.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "sprite_player"))

        player.pos = PXv2f(300, 300)
        currentScene.addEntity(player)

        // Create HUD
        jBg = PXStaticSprite(name: "Joystick background")
        jBg.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_bg"))

        jPin = PXStaticSprite(name: "Joystick pin")
        jPin.animator.currentSprite = PXSprite(texture: PXConfig.sharedTextureManager.getTextureByID(id: "control_joystick_pin"))

        jPin.center = jOrigin

        currentScene.addHudEntity(jPin)

        // Setup cameras
        let camera = PXFollowCamera(dimensions: screenDimensions, followBorder: (1 / 3.0) * screenDimensions, target: player)
        let hudCamera = PXCamera(dimensions: screenDimensions)

        currentScene.camera = camera
        currentScene.hudCamera = hudCamera

        currentScene.addEntity(camera)
        currentScene.addEntity(hudCamera)

        // Setup background
        for x in 0..<100 {
            for y in 0..<100 {
                currentScene.setBackgroundTile(
                    x: x,
                    y: y,
                    tile: PXTile(id: Int.random(in: 0...1))!)
            }
        }

        renderer.scene = currentScene
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
        let dist = min(dVec.abs, jBg.width / 2.0)
        print(dVec.abs, dist)
        jPin.center = jOrigin + dist * (dVec.normalize())
        playerController.setJoystickTilt(dist * (dVec.normalize()))
    }
}
