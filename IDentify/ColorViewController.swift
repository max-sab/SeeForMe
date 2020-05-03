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

    let colorController = ColorController()
    lazy var colorsCollection = DatabaseController.shared.getGeneralColors()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction override func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            cameraController.captureImage {(image, error) in
                guard let imageAverageColor = image?.crop()?.averageColor else {
                    print(error ?? "Error occured while capturing image or converting it to CGImage type")
                    return
                }
                let averageCentralColor = imageAverageColor

                let res = self.colorController.findClosestColor(for: averageCentralColor, among: self.colorsCollection)
                print(res)

//                try? PHPhotoLibrary.shared().performChangesAndWait {
//                    PHAssetChangeRequest.creationRequestForAsset(from: image.crop())
//                }
            }
        }
    }
}


