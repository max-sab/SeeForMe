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

    let cameraController = CameraController()
    let voiceController = VoiceController()
    let visionController = VisionController()

    override func viewDidLoad() {
        super.viewDidLoad()

        //configuring our camera controller for proper usage in the future
        setupCameraController()
    }

     @IBAction func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
    }

    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        voiceController.toggleSpeechSynthesizerState()
    }

    @IBAction func handleScreenEdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began {
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func setupCameraController() {
        cameraController.setupCamera {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.showCameraPreview(on: self.resultPreviewView)
        }
    }

    override open var shouldAutorotate: Bool {
       return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }

}
