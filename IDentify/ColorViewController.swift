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

                let croppedImage = image.crop()

                var bitmap = [UInt8](repeating: 0, count: 4)
                let context = CIContext()
                let inputImage: CIImage = croppedImage.ciImage ?? CoreImage.CIImage(cgImage: croppedImage.cgImage!)
                let extent = inputImage.extent
                let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
                let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
                let outputImage = filter.outputImage!
                let outputExtent = outputImage.extent
                assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)

                // Render to bitmap.
                context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
                let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
                

                try? PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest.creationRequestForAsset(from: image.crop())
                }
            }
        }
    }
}

extension UIImage {
    func crop() -> UIImage {

        let width = 50.0
        let height = 50.0
        let origin = CGPoint(x: (self.cgImage!.height - Int(width)) / 2, y: (self.cgImage!.height - Int(height)) / 2)
        let size = CGSize(width: width, height: height)
        let rect = CGRect(x: origin.x * self.scale, y: origin.y * self.scale, width: size.width * self.scale , height: size.height * self.scale)

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)

        return image
    }
}
