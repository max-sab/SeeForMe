//
//  Database.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import Foundation
import SQLite
import CoreGraphics
import UIKit

class Database {

    let connection: Connection?
    static let shared = Database()
    let formatter = DateFormatter()

    //Texts
    let savedTextsTable = Table("Texts")
    let id = Expression<Int>("id")
    let content = Expression<String>("content")
    let textDateSaved = Expression<String>("date")

    //Colors
    let savedColorsTable = Table("Colors")
    let name = Expression<String>("name")
    let red = Expression<Int>("red")
    let green = Expression<Int>("green")
    let blue = Expression<Int>("blue")
    let colorDateSaved = Expression<String>("date")


    private init() {
        do {
            let dbPathInit = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            guard let dbPath = dbPathInit else {
                connection = nil
                return
            }
            let fileManager = FileManager()

            let initialPath = Bundle.main.path(forResource: "SFMDB", ofType: ".db")
            do {
                if !FileManager.default.fileExists(atPath: "\(dbPath)/SFMDB.db") {
                    try fileManager.copyItem(atPath: initialPath!, toPath: "\(dbPath)/SFMDB.db")
                }
            } catch let error as NSError {
                print("error occurred, here are the details:\n \(error)")
            }
            self.connection =  try Connection("\(dbPath)/SFMDB.db")

        } catch {
            connection = nil
            print(error)
        }
    }

    func getGeneralColors() -> [ColorEntity] {

        guard let connection = connection else {
            fatalError()
        }

        let colorsTable = Table("BaseColors")
        //        let red = Expression<Int>("red")
        //        let green = Expression<Int>("green")
        //        let blue = Expression<Int>("blue")
        //        let name = Expression<String>("name")

        var generalColors = [ColorEntity]()
        do {
            for color in try connection.prepare(colorsTable) {
                let newColor = UIColor(red: CGFloat(color[red] / 255), green: CGFloat(color[green] / 255), blue: CGFloat(color[blue] / 255), alpha: 1)
                generalColors.append(ColorEntity(name: color[name], correspondingColor: newColor, dateSaved: nil))
            }
        } catch {
            print(error)
        }

        return generalColors
    }

    func getSavedTexts() -> [TextEntity]{
        guard let connection = connection else {
            fatalError()
        }

        var texts = [TextEntity]()

        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yy, HH:mm"

        //Kyiv not Kiev :(
        formatter.timeZone = .some(TimeZone(identifier: "Europe/Kiev")!)

        do {
            print("Before connection")
            for text in try connection.prepare(savedTextsTable) {
                guard let date = formatter.date(from: text[textDateSaved]) else {
                    print("Date incorrect")
                    return []
                }
                print("\(date)")
                texts.append(TextEntity(id: text[id], content: text[content], dateSaved: date))
            }
        } catch {
            print(error)
        }

        return texts
    }

    func getSavedColors() -> [ColorEntity]{
        guard let connection = connection else {
            fatalError()
        }

        var colors = [ColorEntity]()


        formatter.dateFormat = "MM.dd.yy, HH:mm"
        //Kyiv not Kiev :(
        formatter.timeZone = .some(TimeZone(identifier: "Europe/Kiev")!)

        do {
            print("Before connection")
            for color in try connection.prepare(savedColorsTable) {
                guard let date = formatter.date(from: color[colorDateSaved]) else {
                    print("Date incorrect")
                    return []
                }
                print("\(date)")
                let correspondingColor = UIColor(red: CGFloat(color[red]), green: CGFloat(color[green]), blue: CGFloat(color[blue]), alpha: 1)
                colors.append(ColorEntity(name: color[name], correspondingColor: correspondingColor, dateSaved: date))
            }
        } catch {
            print(error)
        }

        return colors
    }

    func saveNew(text: String) {
        guard let connection = connection else {
            fatalError()
        }
        let currentDateTime = Date()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.string(from: currentDateTime)
        let insert = savedTextsTable.insert(content <- text, textDateSaved <- formatter.string(from: currentDateTime))
        do {
            try connection.run(insert)
        } catch {
            print(error)
        }
    }

    func saveNew(color: ColorEntity) {
        guard let connection = connection else {
            fatalError()
        }
        let currentDateTime = Date()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.string(from: currentDateTime)
        let insert = savedColorsTable.insert(name <- color.name, red <- Int(color.correspondingColor.rgb.red * 255.0), green <- Int(color.correspondingColor.rgb.green * 255), blue <- Int(color.correspondingColor.rgb.blue * 255),  colorDateSaved <- formatter.string(from: currentDateTime))
        do {
            try connection.run(insert)
        } catch {
            print(error)
        }
    }

    //    func saveNew(text: String) {
    //        guard let connection = connection else {
    //            fatalError()
    //        }
    //        let currentDateTime = Date()
    //        formatter.dateStyle = .short
    //        formatter.string(from: currentDateTime)
    //        let insert = savedTextsTable.insert(content <- text, textDateSaved <- formatter.string(from: currentDateTime))
    //        do {
    //            try connection.run(insert)
    //        } catch {
    //            print(error)
    //        }
    //    }


    func removeSavedText(with textId: Int) {
        guard let connection = connection else {
            fatalError()
        }

        let textToDelete = savedTextsTable.filter(id == textId)
        
        do {
            try connection.run(textToDelete.delete())
        } catch {
            print(error)
        }
    }

    func removeSavedColor(with colorName: String) {
        guard let connection = connection else {
            fatalError()
        }

        let colorToDelete = savedColorsTable.filter(name == colorName)

        do {
            try connection.run(colorToDelete.delete())
        } catch {
            print(error)
        }
    }
}
