//
//  FirebaseScoreboard.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 03.06.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

public class FirebaseScoreboardProvider: ScoreboardProvider {
    let rootRef = Database.database().reference(withPath: "scoreboard")

    public func setUserData<T>(username: String, key: String, _ value: T) {
        rootRef.child(username).child(key).setValue(value)
    }

    public func getUserData<T>(username: String, key: String, of: T.Type, callback: @escaping (T?) -> Void) {
        rootRef.child(username).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            callback(snapshot.value as? T)
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    public func isRegistered(key: String, callback: @escaping (Bool) -> Void) {
        rootRef.child(key).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                callback(true)
            } else {
                callback(false)
            }
        }
    }

    public func register() -> String? {
        return rootRef.childByAutoId().key
    }
}
