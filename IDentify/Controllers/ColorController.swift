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

        //converting both colors to LAB format
        let colorOneLAB = colorOne.lab
        let colorTwoLAB = colorTwo.lab

        //Delta E 76 color difference formula used
        let result = (pow((colorTwoLAB.CIEL - colorOneLAB.CIEL), 2) + pow((colorTwoLAB.CIEa - colorOneLAB.CIEa), 2) + pow((colorTwoLAB.CIEb - colorOneLAB.CIEb), 2)).squareRoot()
        return Double (result)
    }

    func findClosestColor(for color: UIColor, among colorsCollection: [(red: CGFloat, green: CGFloat, blue: CGFloat, name: String)]) -> String {
        var minDistance = Double.infinity
        var closestColor = ""

        colorsCollection.forEach({
            currentColor in
            let distance = distanceBetween(colorOne: color, and: UIColor(red: currentColor.red / 255, green: currentColor.green / 255, blue: currentColor.blue / 255, alpha: 1))
            if minDistance > distance {
                minDistance = distance
                closestColor = currentColor.name
            }
        })

        return closestColor
    }


}
