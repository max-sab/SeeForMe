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

    // Vision requests to be performed on each page of the scanned document.
    private var requests = [VNRequest]()
    // Dispatch queue to perform Vision requests.
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                         qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var resultingText = ""
    let cameraController = CameraController()

    @IBOutlet weak var resultPreviewView: UIView!

    // Setup Vision request as the request can be reused
    private func setupVision() {
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
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
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVision()

        func configureCameraController() {
            cameraController.setupCamera {(error) in
                if let error = error {
                    print(error)
                }

                try? self.cameraController.displayPreview(on: self.resultPreviewView)
            }
        }

        configureCameraController()
    }

    @IBAction func scanReceipts(_ sender: UIControl?) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }

            self.textRecognitionWorkQueue.async {
                self.resultingText = ""
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error)
                    }
                }
                self.resultingText += "\n\n"
                DispatchQueue.main.async(execute: {
                    print(self.resultingText)
                    let utterance = AVSpeechUtterance(string: self.resultingText)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                })
            }
            return

            //        let documentCameraViewController = VNDocumentCameraViewController()
            //        documentCameraViewController.delegate = self
            //        present(documentCameraViewController, animated: true)
        }
    }
}
// MARK: VNDocumentCameraViewControllerDelegate
