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
    func onFrame()
}

extension Character: PXUpdateableEntity {
    public func onFrame() {
        controller.onFrame()
    }
}

public class Character: PXStaticSprite {
    public var maxSpeed: Float = 3
    public var controller: CharacterController

    public init(name: String, controller: CharacterController) {
        self.controller = controller
        super.init(name: name)
        self.controller.parent = self
    }
}
