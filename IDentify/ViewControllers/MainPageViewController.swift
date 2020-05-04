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

    override func viewDidLoad() {
        super.viewDidLoad()

        if let buttonName = buttonName {
            actionButton.setTitle(buttonName, for: .normal)
        }
    }
}
