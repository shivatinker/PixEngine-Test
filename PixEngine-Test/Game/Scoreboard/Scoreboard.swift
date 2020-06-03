//
//  Scoreboard.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 03.06.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public class Scoreboard {
    private let provider: ScoreboardProvider

    private enum DBKey: String {
        case highscore = "highscore"
    }

    private var username: String? {
        get {
            UserDefaults.standard.string(forKey: "id")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "id")
        }
    }

    public init(provider: ScoreboardProvider) {
        self.provider = provider
    }

    public func getHighscore(callback: @escaping (Int?) -> Void) {
        provider.getUserData(username: username!,
                             key: DBKey.highscore.rawValue,
                             of: Int.self,
                             callback: callback)
    }

    public func acceptScore(score: Int, callback: @escaping (Bool) -> Void){
        getHighscore() { oldHighscore in
            guard let old = oldHighscore else {
                self.provider.setUserData(username: self.username!, key: DBKey.highscore.rawValue, score)
                callback(true)
                return
            }
            if old < score {
                self.provider.setUserData(username: self.username!, key: DBKey.highscore.rawValue, score)
                callback(true)
                return
            }
            callback(false)
        }
    }

    private func reg() {
        let id = provider.register()!
        print("Registered new \(id)")
        username = id
    }

    public func ensureRegistered(callback: @escaping () -> Void) {
        if let idd = username {
            provider.isRegistered(key: idd) { (registered) in
                if registered {
                    print("Got id \(idd)")
                    callback()
                } else {
                    self.reg()
                    callback()
                }
            }
        } else {
            reg()
            callback()
        }
    }

    public struct GameScore {
        let score: Int
    }
}
