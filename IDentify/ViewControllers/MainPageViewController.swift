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


    @IBAction func actionButtonPressed(_ sender: UIButton) {
        var vc = UIViewController()
        switch buttonName {
        case "Read text":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "VisionViewController") as! VisionViewController
        case "Identify color":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ColorViewController") as! ColorViewController
        case "Saved texts":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SavedTextsViewController") as! SavedTextsViewController
        case "Saved colors":
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SavedColorsViewController") as! SavedColorsViewController
        default:
            voiceController.read(text: "Unexpected error occured. Please, restart an app")
            self.present(vc, animated: false, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        if let buttonName = buttonName {
            actionButton.setTitle(buttonName, for: .normal)
        }
    }
}
