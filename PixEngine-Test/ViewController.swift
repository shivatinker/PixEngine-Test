//
//  ViewController.swift
//  PixEngine-Test
//
//  Created by Andrii Zinoviev on 09.04.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

import UIKit
import MetalKit
import PixeNgine

class InitialPanGestureRecognizer: UIPanGestureRecognizer {
    public var initialTouchLocation: CGPoint!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first!.location(in: view)
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    private var renderer: PXRenderer!
    private var scene: PXScene!
    private var camera: PXCamera!

    private var game: TestGame?

    private var recognizer = UITapGestureRecognizer()
    private var recognizer2 = InitialPanGestureRecognizer()

    @IBOutlet weak var mtkView: MTKView!
    override func viewDidLoad() {
        super.viewDidLoad()

        recognizer2.delegate = self
        recognizer2.addTarget(self, action: #selector(upd))
        view.addGestureRecognizer(recognizer2)
        recognizer2.maximumNumberOfTouches = 1

        renderer = PXRenderer(view: mtkView)
        game = TestGame(renderer: renderer)
    }

    private var active = false

    @objc
    func upd() {
        if recognizer2.state == .began {
            let l = recognizer2.initialTouchLocation
            game?.panStart(
                Float(l!.x) / Float(mtkView.frame.maxX),
                Float(l!.y) / Float(mtkView.frame.maxY))
        }
        if recognizer2.state == .changed {
            let l2 = recognizer2.translation(in: mtkView)
            game?.panUpdate(
                Float(l2.x) / Float(mtkView.frame.maxX),
                Float(l2.y) / Float(mtkView.frame.maxY))
        }
        if recognizer2.state == .ended {
            game?.panEnd()
        }

    }
}

