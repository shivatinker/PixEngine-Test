//
//  Projectile.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

public class Projectile: PXStaticSprite, PXUpdateableEntity {
    public func onFrame() {
        pos = pos + velocity
    }

    public var velocity: PXv2f = .zero
    public override var outOfBoundsDiscardable: Bool { true }
}