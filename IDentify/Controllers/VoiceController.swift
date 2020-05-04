//
//  VoiceController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/2/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import AVFoundation

struct VoiceController {
    // 0.5 is default utteranceRate defined by Apple
    private var utteranceRate: Float = 0.4
    private let synthesizer = AVSpeechSynthesizer()

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
}
