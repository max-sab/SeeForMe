//
//  ColorController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class ColorController {

    func findAverageColorFor(image: UIImage) -> UIColor{
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        let inputImage: CIImage = image.ciImage ?? CoreImage.CIImage(cgImage: image.cgImage!)
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
        let outputImage = filter.outputImage!
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)

        // Render to bitmap.
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)

    }

    func distanceBetween(colorOne: UIColor, and colorTwo: UIColor) -> Double {
        let colorOneRGBA = colorOne.rgba
        let colorTwoRGBA = colorTwo.rgba

        let redMeanLevel = (colorOneRGBA.red + colorTwoRGBA.red) / 2
        let deltaRed = colorOneRGBA.red - colorTwoRGBA.red
        let deltaBlue = colorOneRGBA.blue - colorTwoRGBA.blue
        let deltaGreen = colorOneRGBA.green - colorTwoRGBA.green

        let distance = (2 + (redMeanLevel / 256) * (deltaRed * deltaRed) + (4 * (deltaGreen * deltaGreen)) + (2 + (255 - redMeanLevel) / 256) * (deltaBlue * deltaBlue)).squareRoot()

        return Double(distance)
    }

    func findClosestColor(for color: UIColor, among colorsCollection: [(CGFloat, CGFloat, CGFloat, String)]) -> String {
        let minDistance = Double.infinity
        var closestColor = ""

        colorsCollection.forEach({
            currentColor in
            if minDistance > distanceBetween(colorOne: color, and: UIColor(red: currentColor.0, green: currentColor.1, blue: currentColor.2, alpha: 1)) {
                closestColor = currentColor.3
            }
        })

        return closestColor
    }


}
