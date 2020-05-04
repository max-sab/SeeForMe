//
//  VoiceController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/2/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import AVFoundation
import Speech

class VoiceController {
    // 0.5 is default utteranceRate defined by Apple
    private var utteranceRate: Float = 0.4
    private let synthesizer = AVSpeechSynthesizer()

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioSession = AVAudioSession.sharedInstance()


    func read(text input: String) {
        //print(input)
        synthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        let utterance = AVSpeechUtterance(string: input)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = utteranceRate
        synthesizer.speak(utterance)
    }

    func toggleSpeechSynthesizerState() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        } else {
            synthesizer.pauseSpeaking(at: AVSpeechBoundary.word)
        }
    }

    func recordAndRecognizeSpeech(completion: @escaping (String) -> Void) {

        guard let speechRecognizer = speechRecognizer else {
            read(text: "Couldn't create speech recognizer. Please restart your app and try again")
            return
        }

        recognitionTask?.cancel()
        self.recognitionTask = nil
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            read(text: "Unable to process your request")
            return
        }

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            read(text: "Couldn't start audio engine. Please restart your app and try again")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            read(text: "Couldn't create recognition request. Please restart your app and try again")
            return
        }

        if #available(iOS 13, *) {
            if speechRecognizer.supportsOnDeviceRecognition {
                recognitionRequest.requiresOnDeviceRecognition = true
            }
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    completion(result.bestTranscription.formattedString)
                    self.recognitionTask?.cancel()
                    self.recognitionTask?.finish()
                }
            }

            if error != nil {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                print(error)
            }
        }
    }
}
