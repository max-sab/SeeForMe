//
//  ImageUtils.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//
import UIKit

extension UIImage {

    //crop image to contain only small center region
    func crop() -> UIImage? {

        guard let cgImage = self.cgImage else {
            return nil
        }

        let width = 50.0
        let height = 50.0
        let origin = CGPoint(x: (cgImage.height - Int(width)) / 2, y: (cgImage.height - Int(height)) / 2)
        let size = CGSize(width: width, height: height)
        let rect = CGRect(x: origin.x * self.scale, y: origin.y * self.scale, width: size.width * self.scale , height: size.height * self.scale)

        if let croppedCGImage = cgImage.cropping(to: rect) {
            let image = UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
            return image
        } else {
            return nil
        }

    }

    var averageColor: UIColor? {

        guard let inputImage = CIImage(image: self) else { return nil }

        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        //filter that returns a single-pixel image that contains the average color for the ROI.
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }

        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])

        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension UIColor {

    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue)
    }

    var lab: (CIEL: CGFloat, CIEa: CGFloat, CIEb: CGFloat) {
        let rgbValues = self.rgb
        var var_R = ( rgbValues.red)
        var var_G = ( rgbValues.green)
        var var_B = ( rgbValues.blue)

        if var_R > 0.04045 { var_R = pow(( ( var_R + 0.055 ) / 1.055 ), 2.4) }
        else{
            var_R = var_R / 12.92
        }

        if var_G > 0.04045 { var_G = pow(( ( var_G + 0.055 ) / 1.055 ), 2.4) }
        else{
            var_G = var_G / 12.92
        }

        if var_B > 0.04045 { var_B = pow(( ( var_B + 0.055 ) / 1.055 ), 2.4) }
        else{
            var_B = var_B / 12.92
        }

        var_R = var_R * 100
        var_G = var_G * 100
        var_B = var_B * 100

        let X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805
        let Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722
        let Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505


        //to lab
        var var_X1 = X /  95.047
        var var_Y1 = Y / 100.0
        var var_Z1 = Z / 108.883

        if var_X1 > 0.008856 {
            var_X1 = pow(var_X1, ( 1/3 ))
        }
        else {
            var_X1 = ( 7.787 * var_X1 ) + ( 16 / 116 )
        }


        if var_Y1 > 0.008856 {
            var_Y1 = pow(var_Y1, ( 1/3 ))
        }
        else {
            var_Y1 = ( 7.787 * var_Y1 ) + ( 16 / 116 )
        }

        if var_Z1 > 0.008856 {
            var_Z1 = pow(var_Z1, ( 1/3 ))
        }
        else {
            var_Z1 = ( 7.787 * var_Z1 ) + ( 16 / 116 )
        }

        let CIEL = ( 116 * var_Y1 ) - 16
        let CIEa = 500 * ( var_X1 - var_Y1 )
        let CIEb = 200 * ( var_Y1 - var_Z1 )

        return (CIEL, CIEa, CIEb)
    }


}
