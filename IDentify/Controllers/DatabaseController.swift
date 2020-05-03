//
//  DatabaseController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import Foundation
import SQLite
import CoreGraphics

class DatabaseController {

    let connection: Connection?
    static let shared = DatabaseController()

    private init() {
        do {
            let path = Bundle.main.path(forResource: "SFMDB", ofType: "db")

            if let path = path {
            self.connection = try Connection(path)
            } else {
                print("err")
                connection = nil
            }
        } catch {
            connection = nil
            print(error)
        }
    }

    func getGeneralColors() -> [(CGFloat, CGFloat, CGFloat, String)] {

        guard let connection = connection else {
            fatalError()
        }

        let colorsTable = Table("BaseColors")
        let red = Expression<Int>("red")
        let green = Expression<Int>("green")
        let blue = Expression<Int>("blue")
        let name = Expression<String>("name")
        var generalColors = [(CGFloat, CGFloat, CGFloat, String)]()
        do {
            for color in try connection.prepare(colorsTable) {
                generalColors.append((CGFloat(color[red]), CGFloat(color[green]), CGFloat(color[blue]), color[name]))
            }
        } catch {
            print(error)
        }

        return generalColors
    }
}
