//
//  ImageUtils.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//
import UIKit

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
