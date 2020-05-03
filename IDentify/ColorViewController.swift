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

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction override func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            cameraController.captureImage {(image, error) in
                guard let image = image else {
                    print(error ?? "Error occured while capturing image or converting it to CGImage type")
                    return
                }

                self.colorController.findAverageColorFor(image: image.crop())

                try? PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest.creationRequestForAsset(from: image.crop())
                }
            }
        }
    }
}


