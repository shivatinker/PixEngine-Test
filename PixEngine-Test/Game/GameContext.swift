//
//  GameContext.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 25.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import PixeNgine

public class GameContext {
    public var currentScene: PXScene!
    public var player: Character!
    public var playerLight: PXLight!
    public var scoreText: PXText!
    public var score: Int = 0
    public var time: Int64 = 0
    public var lua: LuaScripting!
}
