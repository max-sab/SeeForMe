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

class VisionViewController: ActionViewController {

    var currentText = ""

    @IBAction func handleTapTwiceGesture(_ sender: UITapGestureRecognizer) {
        DatabaseController.shared.saveNew(text: currentText)
    }

    @IBAction override func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            cameraController.captureImage {(image, error) in
                guard let cgImage = image?.cgImage else {
                    self.voiceController.read(text: "Error occured while capturing image")
                    return
                }

                self.visionController.processReceived(cgImage: cgImage, completion: { (text, error) in
                    if error != nil {
                        print(error!)
                        return
                    }

                    self.voiceController.read(text: "Be sure to tap twice if you want to save the result. Recognized text is: \(text)")
                    self.currentText = text
                })

                return
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        voiceController.read(text: "SeeForMe. Text recognizing")
    }
}
