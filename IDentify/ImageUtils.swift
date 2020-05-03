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

    var ciColor: CIColor {
        return CIColor(color: self)
    }
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        let ciColor = self.ciColor
        return (ciColor.red, ciColor.green, ciColor.blue)
    }

    //returns image in LAB format in order to calculate distance between images on another level that's common to how humans compare them
    //we will first convert RGB to XYZ and then XYZ to LAB
    var lab: (CIEL: CGFloat, CIEa: CGFloat, CIEb: CGFloat) {
        let rgbValues = self.rgb

        //RGB -> XYZ
        var rgbRed = rgbValues.red
        var rgbGreen = rgbValues.green
        var rgbBlue = rgbValues.blue

        if rgbRed > 0.04045 {
            rgbRed = pow(((rgbRed + 0.055) / 1.055), 2.4)
        }
        else {
            rgbRed /= 12.92
        }

        if rgbGreen > 0.04045 {
            rgbGreen = pow(((rgbGreen + 0.055) / 1.055), 2.4)
        }
        else {
            rgbGreen /= 12.92
        }

        if rgbBlue > 0.04045 {
            rgbBlue = pow(((rgbBlue + 0.055) / 1.055), 2.4)
        }
        else {
            rgbBlue /= 12.92
        }

        rgbRed *= 100
        rgbGreen *= 100
        rgbBlue *= 100

        let X = rgbRed * 0.4124 + rgbGreen * 0.3576 + rgbBlue * 0.1805
        let Y = rgbRed * 0.2126 + rgbGreen * 0.7152 + rgbBlue * 0.0722
        let Z = rgbRed * 0.0193 + rgbGreen * 0.1192 + rgbBlue * 0.9505


        //XYZ -> LAB
        var labX = X /  95.047
        var labY = Y / 100.0
        var labZ = Z / 108.883

        if labX > 0.008856 {
            labX = pow(labX, 1/3)
        }
        else {
            labX = (7.787 * labX) + (16 / 116)
        }

        if labY > 0.008856 {
            labY = pow(labY, 1/3)
        }
        else {
            labY = (7.787 * labY) + (16 / 116)
        }

        if labZ > 0.008856 {
            labZ = pow(labZ, 1/3)
        }
        else {
            labZ = (7.787 * labZ) + (16 / 116)
        }

        let CIEL = (116 * labY) - 16
        let CIEa = 500 * (labX - labY)
        let CIEb = 200 * (labY - labZ)

        return (CIEL, CIEa, CIEb)
    }


}
