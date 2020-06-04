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
    public var scoreboard: Scoreboard!
    public var timer: Int = 0
    public var timerText: PXText!
    public var highscore: Int = 0 {
        didSet {
            hsText.text = "\(highscore)"
        }
    }
    public var hsText: PXText!
    public var game: TestGame!
}
