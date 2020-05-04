//
//  Projectile.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

public class Projectile: PXEntity {
    public var drawable = PXSpriteDrawable()
    public var collider = BasicCollider()

    public override func draw(context: PXDrawContext) {
        drawable.draw(entity: self, context: context)
    }

    private var context: GameContext

    public override func update() {
        pos = pos + velocity
        if collider.fixCollision(context: context) {
            onCollision()
        }
    }

    private func onCollision() {
        shouldBeRemoved = true
    }
    // MARK: State
    public var velocity: PXv2f = .zero

    public init(name: String, context: GameContext) {
        self.context = context
        super.init(name: name)
        collider.parent = self
    }
}
