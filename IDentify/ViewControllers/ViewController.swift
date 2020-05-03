//
//  ViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 4/25/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func readTextButtonPressed(_ sender: UIButton) {
        let controller = VisionViewController()
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func showColorsButtonPressed(_ sender: UIButton) {
    }
}

