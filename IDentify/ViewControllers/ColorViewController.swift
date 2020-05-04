//
//  ColorViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/2/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit
import Photos

class ColorViewController: ActionViewController {

    private let colorController = ColorController()
    private lazy var colorsCollection = DatabaseController.shared.getGeneralColors()
    private var currentColor: Color?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func handleTapTwiceGesture(_ sender: UITapGestureRecognizer) {
        guard let currentColor = currentColor else {
            voiceController.read(text: "Unable to save color")
            return
        }

        DatabaseController.shared.saveNew(color: currentColor)
    }

    @IBAction override func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            cameraController.captureImage {(image, error) in
                guard let imageAverageColor = image?.crop()?.averageColor else {
                    self.voiceController.read(text: "Error occured while capturing image")
                    print(error ?? "Error occured while capturing image or converting it to CGImage type")
                    return
                }
                let averageCentralColor = imageAverageColor

                let closestColor = self.colorController.findClosestColor(for: averageCentralColor, among: self.colorsCollection)
                self.voiceController.read(text: "Be sure to tap twice if you want to save the result. This color is close to \(closestColor)")
                self.currentColor = Color(name: closestColor, correspondingColor: averageCentralColor, dateSaved: nil)
//                try? PHPhotoLibrary.shared().performChangesAndWait {
//                    PHAssetChangeRequest.creationRequestForAsset(from: image.crop())
//                }
            }
        }
    }
}


