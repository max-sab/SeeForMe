//
//  VisionViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 4/30/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit
import Vision
import VisionKit
import AVFoundation

class VisionViewController: UIViewController {

    @IBOutlet weak var resultPreviewView: UIView!

    private let cameraController = CameraController()
    private let voiceController = VoiceController()
    private let visionController = VisionController()


    override func viewDidLoad() {
        super.viewDidLoad()

        //configuring our camera controller for proper usage in the future
        setupCameraController()
    }

    @IBAction func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            cameraController.captureImage {(image, error) in
                guard let cgImage = image?.cgImage else {
                    print(error ?? "Error occured while capturing image or converting it to CGImage type")
                    return
                }

                self.visionController.processReceived(cgImage: cgImage, completion: { (text, error) in
                    if error != nil {
                        print(error!)
                        return
                    }

                    self.voiceController.read(text: text)
                })

                return
            }
        }
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
}
