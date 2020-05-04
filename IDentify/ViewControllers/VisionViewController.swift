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

    @IBAction override func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
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

                    self.voiceController.read(text: text, completion: {
                         self.voiceController.read(text: "Do you want to save this? Tap twice if yes", completion: nil)
                    })

                })

                return
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
