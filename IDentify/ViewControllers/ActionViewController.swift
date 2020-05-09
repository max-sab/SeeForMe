//
//  ActionViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/2/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class ActionViewController: UIViewController {
    @IBOutlet weak var resultPreviewView: UIView!

    let camera = Camera()
    let voice = Voice()
    let vision = Vision()

    override func viewDidLoad() {
        super.viewDidLoad()

        //configuring our camera controller for proper usage in the future
        setupCamera()
    }

     @IBAction func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
    }

    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        voice.toggleSpeechSynthesizerState()
    }

    @IBAction func handleScreenEdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func setupCamera() {
        camera.setupCamera {(error) in
            if let error = error {
                print(error)
            }
            try? self.camera.showCameraPreview(on: self.resultPreviewView)
        }
    }

    override open var shouldAutorotate: Bool {
       return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }

}
