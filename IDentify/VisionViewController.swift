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
    // Dispatch queue to perform Vision requests.
    private let textRecognitionQueue = DispatchQueue(label: "com.saba.textRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var currentTextResult = ""
    private let cameraController = CameraController()
    private let voiceController = VoiceController()
    private var request: VNRecognizeTextRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        //set up our text recongition request
        setupVisionRequest()

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

                self.processReceived(cgImage: cgImage)
                return
            }
        }
    }

    private func processReceived(cgImage: CGImage) {
        guard let request = request else {
            return
        }

        //perform an async call for text recognition
        self.textRecognitionQueue.async {
            self.currentTextResult = ""
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
            DispatchQueue.main.async(execute: {
                self.voiceController.read(text: self.currentTextResult)
            })
        }
    }

    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        voiceController.toggleSpeechSynthesizerState()
    }

    private func setupCameraController() {
        cameraController.setupCamera {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController.showCameraPreview(on: self.resultPreviewView)
        }
    }

    // Setup Vision request in order to reuse it in the future
    private func setupVisionRequest() {
        request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("Unexpected type of observations received")
                return
            }
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                self.currentTextResult += candidate.string + "\n"
            }
        }

        // implicitly unwrapping request because we just initialized it above
        request!.recognitionLevel = .accurate
        request!.usesLanguageCorrection = true
    }
}
