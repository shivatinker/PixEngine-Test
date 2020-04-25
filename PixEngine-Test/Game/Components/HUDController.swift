//
//  PlayerControl.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 22.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

public class HUDController: PXComponent, CharacterController {
    public weak var parent: Character?
    
    private var velocity: PXv2f = .zero

    public func onFrame() {
        parent!.pos = parent!.pos + velocity
//        debugPrint(parent!.pos)
    }

    public func setJoystickTilt(_ tilt: PXv2f) {
        velocity = parent!.maxSpeed * tilt.normalize()
    }
}
