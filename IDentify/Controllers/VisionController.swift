//
//  VisionController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/2/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import Vision

class VisionController {
    // Dispatch queue to perform Vision requests.
    private let textRecognitionQueue = DispatchQueue(label: "com.saba.textRecognitionQueue",
                                                     qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var currentTextResult = ""
    private var request: VNRecognizeTextRequest?

    init() {
        //set up our text recongition request
        setupVisionRequest()
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

    func processReceived(cgImage: CGImage, completion: @escaping (String, Error?) -> Void) {
        guard let request = request else {
            completion("", VisionControllerError.requestInvalid)
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
                completion(self.currentTextResult, nil)
            })
        }
    }
}

enum VisionControllerError: Error {
    case requestInvalid
}
