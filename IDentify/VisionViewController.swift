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

    // Dispatch queue to perform Vision requests.
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var resultingText = ""
    let cameraController = CameraController()

    @IBOutlet weak var resultPreviewView: UIView!

    var request: VNRecognizeTextRequest!

    @IBAction func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        guard let request = request else {
            return
        }
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }

            //perform an async call for text recognition
            self.textRecognitionWorkQueue.async {
                self.resultingText = ""
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
                    do {
                        try requestHandler.perform([request])
                    } catch {
                        print(error)
                    }
                }
                self.resultingText += "\n\n"
                DispatchQueue.main.async(execute: {
                    print(self.resultingText)
                    let utterance = AVSpeechUtterance(string: self.resultingText)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    utterance.rate = 0.5
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                })
            }
            return
        }
    }

    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        resultPreviewView = UIView()
        //set up our text recongition request
        setupVision()

        //configuring our camera controller for proper usage in the future
        configureCameraController()
    }

    private func configureCameraController() {
        cameraController.setupCamera {(error) in
            if let error = error {
                print(error)
            }

            try? self.cameraController.displayPreview(on: self.resultPreviewView)
        }
    }

    // Setup Vision request as the request can be reused
    private func setupVision() {
        request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // Concatenate the recognised text from all the observations.
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                self.resultingText += candidate.string + "\n"
            }
        }
        // specify the recognition level
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
    }
}
