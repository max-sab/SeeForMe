//
//  MainPageViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/4/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit
class MainPageViewController: UIViewController {
    
    @IBOutlet weak var actionButton: UIButton!
    var buttonName: String?
    var buttonIndex: Int!

    private let voiceController = VoiceController()
    private var awaitingForResult = true

    @IBAction func voiceCommandButtonPressed(_ sender: UIButton) {
        awaitingForResult = true
        voiceController.recordAndRecognizeSpeech(completion: { command in
            if self.awaitingForResult {
                self.awaitingForResult = false
                if command.lowercased() == "read" {
                    self.presentViewController(with: "Read text")
                } else if command.lowercased() == "identify"{
                    self.presentViewController(with: "Identify color")
                } else if  command.lowercased() == "text" {
                    self.presentViewController(with: "Saved texts")
                } else if command.lowercased() == "color" {
                    self.presentViewController(with: "Saved colors")
                } else {
                    self.voiceController.read(text: "Command is not recognized. Please, retry your voice command")
                }
            }
        })
    }

    @IBAction func actionButtonPressed(_ sender: UIButton) {
        guard let buttonName = buttonName else {
            return
        }
        presentViewController(with: buttonName)
    }

    func presentViewController(with id: String) {
        var vc = UIViewController()
        switch id {
        case "Read text":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "VisionViewController") as! VisionViewController
            self.present(vc, animated: false, completion: nil)
        case "Identify color":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ColorViewController") as! ColorViewController
            self.present(vc, animated: false, completion: nil)
        case "Saved texts":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SavedTextsViewController") as! SavedTextsViewController
            self.present(vc, animated: false, completion: nil)
        case "Saved colors":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SavedColorsViewController") as! SavedColorsViewController
            self.present(vc, animated: false, completion: nil)
        default:
            voiceController.read(text: "Unexpected error occured. Please, restart an app")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let buttonName = buttonName {
            actionButton.setTitle(buttonName, for: .normal)
        }
    }

    override open var shouldAutorotate: Bool {
       return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }
}
