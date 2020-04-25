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

extension Character: PXUpdateableEntity {
    public func onFrame() {
        controller.onFrame(context: context)
        collider.fixCollision(context: context)
    }
}

public class Character: PXStaticSprite {
    public var maxSpeed: Float = 5
    public var controller: CharacterController
    public var collider = BasicCollider()
    public let context: GameContext

    public var viewDirection: PXv2f = .ones

    public init(context: GameContext, name: String, controller: CharacterController) {
        self.controller = controller
        self.context = context
        super.init(name: name)
        self.controller.parent = self
        self.collider.parent = self
    }
}
