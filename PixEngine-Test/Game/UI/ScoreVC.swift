//
//  ScoreVC.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 04.06.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import Foundation
import UIKit

public class ScoreVC: UIViewController {

    private let scoreLabel = UILabel()
    private let newGameButton = UIButton(type: .system)

    private let back: () -> Void

    public init(score: Int, isHighscore: Bool, back: @escaping () -> Void) {
        self.back = back
        super.init(nibName: nil, bundle: nil)


        view.backgroundColor = .black

        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "You scored \(score)"
        view.addSubview(scoreLabel)

        if isHighscore {
            scoreLabel.text?.append(" [New highscore!]")
        }

        newGameButton.translatesAutoresizingMaskIntoConstraints = false
        newGameButton.setTitle("New game", for: .normal)
        newGameButton.addTarget(self, action: #selector(newGame), for: .touchUpInside)
        view.addSubview(newGameButton)

        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            scoreLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),

            newGameButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            newGameButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            newGameButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            newGameButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc public func newGame() {
        dismiss(animated: true, completion: back)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
