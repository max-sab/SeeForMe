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

    let data = Table("Data")
    let colors = Table("Colors")

    let id = Expression<Int>("id")
    let content = Expression<String>("content")
    let isText = Expression<Int>("is_Text")
    let dateSaved = Expression<String>("date")
    let red = Expression<Int>("red")
    let green = Expression<Int>("green")
    let blue = Expression<Int>("blue")
    let name = Expression<String>("name")
    let isBase = Expression<Int>("is_Base")


    //Texts
    let savedTextsTable = Table("Texts")
    //let id = Expression<Int>("id")

    let textDateSaved = Expression<String>("date")

    //Colors
    let savedColorsTable = Table("Colors")



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
        let query = data.select(data[content], colors[red], colors[green], colors[blue]).join(colors, on: data[id] == colors[id]).filter(data[isText] == 0).filter(colors[isBase] == 1)

        var generalColors = [ColorEntity]()
        do {
            for color in try connection.prepare(query) {
                let newColor = UIColor(red: CGFloat(color[red] / 255), green: CGFloat(color[green] / 255), blue: CGFloat(color[blue] / 255), alpha: 1)
                generalColors.append(ColorEntity(name: color[content], correspondingColor: newColor, dateSaved: nil))
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
            let query = data.select(data[id], data[content], data[dateSaved]).filter(data[isText] == 1)
            for text in try connection.prepare(query) {
                guard let date = formatter.date(from: text[dateSaved]) else {
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

        var colorsEntity = [ColorEntity]()
        formatter.dateFormat = "MM.dd.yy, HH:mm"
        //Kyiv not Kiev :(
        formatter.timeZone = .some(TimeZone(identifier: "Europe/Kiev")!)

        do {
            print("Before connection")
            let query = data.select(data[content], data[dateSaved], colors[red], colors[green], colors[blue]).join(colors, on: data[id] == colors[id]).filter(data[isText] == 0).filter(colors[isBase] == 0)
            for color in try connection.prepare(query) {
                guard let date = formatter.date(from: color[dateSaved]) else {
                    print("Date incorrect")
                    return []
                }
                print("\(date)")
                let correspondingColor = UIColor(red: CGFloat(color[red]), green: CGFloat(color[green]), blue: CGFloat(color[blue]), alpha: 1)
                colorsEntity.append(ColorEntity(name: color[content], correspondingColor: correspondingColor, dateSaved: date))
            }
        } catch {
            print(error)
        }

        return colorsEntity
    }

    func saveNew(text: String) {
        guard let connection = connection else {
            fatalError()
        }
        let currentDateTime = Date()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.string(from: currentDateTime)
        let insert = data.insert(content <- text, isText <- 1, dateSaved <- formatter.string(from: currentDateTime))
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
        let dataInsert = data.insert(content <- color.name, isText <- 0, dateSaved <- formatter.string(from: currentDateTime))

        do {
            try connection.run(dataInsert)

            var maxID = 0
//            for ids in try connection.prepare("SELECT MAX(id) FROM Data") {
//                maxID = ids[0] as! Int
//            }

            let colorInsert = savedColorsTable.insert(red <- Int(color.correspondingColor.rgb.red * 255.0), green <- Int(color.correspondingColor.rgb.green * 255), blue <- Int(color.correspondingColor.rgb.blue * 255), id <- Int(connection.lastInsertRowid), isBase <- 0)
            try connection.run(colorInsert)
        } catch {
            print(error)
        }
    }

    func removeSavedText(with textId: Int) {
        guard let connection = connection else {
            fatalError()
        }

        let textToDelete = data.filter(id == textId)
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

        let dataToDelete = data.filter(content == colorName).filter(isText == 0)

        var idToDelete = 0


        do {
            for data in try connection.prepare(data.filter(content == colorName).filter(isText == 0)) {
                idToDelete = data[id]
            }
            
            try connection.run(dataToDelete.delete())
            let colorToDelete = colors.filter(id == idToDelete)

            try connection.run(colorToDelete.delete())
        } catch {
            print(error)
        }
    }
}
