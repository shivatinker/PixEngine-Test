//
//  ScoreboardProvider.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 03.06.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation

public protocol ScoreboardProvider {
    func setUserData<T>(username: String, key: String, _ value: T)
    func getUserData<T>(username: String, key: String, of: T.Type, callback: @escaping (T?) -> Void)
    func isRegistered(key: String, callback: @escaping (Bool) -> Void)
    func register() -> String?
}
