//
//  Character.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 22.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine
import Metal

public protocol CharacterController {
    var parent: Character? { get set }
    func onFrame(context: GameContext)
}


public class Character: PXEntity {
    public var drawable = PXSpriteDrawable()

    public override var dimensions: PXv2f {
        drawable.dimensions
    }

    public override func draw(context: PXDrawContext) {
        drawable.draw(entity: self, context: context)
    }

    public override func update() {
        controller.onFrame(context: context)
        collider.fixCollision(context: context)
    }

    public let context: GameContext

    // MARK: Character stats
    public var viewDirection: PXv2f = .ones
    public var maxSpeed: Float = 5
    public var health: Int = 100

    // MARK: Components
    public var controller: CharacterController
    public var collider = BasicCollider()

    public func recieveDamage(damage: Int) {
        let text = PXBlobText(text: String(damage), pos: pos, height: 100)
        text.drawable.scale = 2.0/3.0
        health -= damage
        context.currentScene.addEntity(text)
    }

    public init(context: GameContext, name: String, controller: CharacterController, sprite: PXSprite) {
        self.controller = controller
        self.context = context
        self.drawable.sprite = sprite
        super.init(name: name)
        self.controller.parent = self
        self.collider.parent = self
    }
}
