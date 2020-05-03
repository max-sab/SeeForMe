//
//  ColorController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit
import Foundation

class ColorController {

    func distanceBetween(colorOne: UIColor, and colorTwo: UIColor) -> Double {
        let colorOneLAB = colorOne.lab
        let colorTwoLAB = colorTwo.lab
//
//        let redMeanLevel = (colorOneRGBA.red + colorTwoRGBA.red) / 2
//        let deltaRed = colorOneRGBA.red - colorTwoRGBA.red
//        let deltaBlue = colorOneRGBA.blue - colorTwoRGBA.blue
//        let deltaGreen = colorOneRGBA.green - colorTwoRGBA.green
//
//        let distance = ((2 + (redMeanLevel / 256)) * (deltaRed * deltaRed) + 4 * (deltaGreen * deltaGreen) + (2 + ((255 - redMeanLevel) / 256)) * (deltaBlue * deltaBlue)).squareRoot()
//
//        return Double(distance)
        let result = (pow((colorTwoLAB.CIEL - colorOneLAB.CIEL), 2) + pow((colorTwoLAB.CIEa - colorOneLAB.CIEa), 2) + pow((colorTwoLAB.CIEb - colorOneLAB.CIEb), 2)).squareRoot()
        return Double (result)
    }

    func findClosestColor(for color: UIColor, among colorsCollection: [(CGFloat, CGFloat, CGFloat, String)]) -> String {
        var minDistance = Double.infinity
        var closestColor = ""

        colorsCollection.forEach({
            currentColor in
            let distance = distanceBetween(colorOne: color, and: UIColor(red: currentColor.0 / 255, green: currentColor.1 / 255, blue: currentColor.2 / 255, alpha: 1))
            if minDistance > distance {
                minDistance = distance
                closestColor = currentColor.3
            }
        })

        return closestColor
    }


}
