//
//  ColorViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/2/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class ColorViewController: ActionViewController {

    private let color = Color()
    private lazy var colorsCollection = Database.shared.getGeneralColors()
    private var currentColor: ColorEntity?

    override func viewDidLoad() {
        super.viewDidLoad()
        voice.read(text: "SeeForMe. Color recognizing")
    }

    @IBAction func handleTapTwiceGesture(_ sender: UITapGestureRecognizer) {
        guard let currentColor = currentColor else {
            voice.read(text: "Unable to save color")
            return
        }

        Database.shared.saveNew(color: currentColor)
    }

    @IBAction override func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            camera.captureImage {(image, error) in
                guard let imageAverageColor = image?.crop()?.averageColor else {
                    self.voice.read(text: "Error occured while capturing image")
                    print(error ?? "Error occured while capturing image or converting it to CGImage type")
                    return
                }

                let closestColor = self.color.findClosestColor(for: imageAverageColor, among: self.colorsCollection)
                self.voice.read(text: "Be sure to tap twice if you want to save the result. This color is close to \(closestColor)")
                self.currentColor = ColorEntity(name: closestColor, correspondingColor: imageAverageColor, dateSaved: nil)
            }
        }
    }

    override open var shouldAutorotate: Bool {
       return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }
}


