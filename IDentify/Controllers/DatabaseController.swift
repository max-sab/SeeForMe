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
import UIKit

class DatabaseController {

    let connection: Connection?
    static let shared = DatabaseController()

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
            //            let fileManager = FileManager()
            //            let path = Bundle.main.path(forResource: "SFMDB", ofType: ".db")
            //            do {
            //                if FileManager.default.fileExists(atPath: "\(dbPath!)/SFMDB.db") {
            //                    try! FileManager.default.removeItem(atPath: "\(dbPath!)/SFMDB.db")
            //                }
            //                try fileManager.copyItem(atPath: path!, toPath: "\(dbPath!)/SFMDB.db")
            //            }catch let error as NSError {
            //                print("error occurred, here are the details:\n \(error)")
            //            }

            let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            if let dbPath = dbPath {
                self.connection =  try Connection("\(dbPath)/SFMDB.db")
            } else {
                print("err")
                connection = nil
            }

        } catch {
            connection = nil
            print(error)
        }
    }

    func getGeneralColors() -> [Color] {

        guard let connection = connection else {
            fatalError()
        }

        let colorsTable = Table("BaseColors")
        //        let red = Expression<Int>("red")
        //        let green = Expression<Int>("green")
        //        let blue = Expression<Int>("blue")
        //        let name = Expression<String>("name")

        var generalColors = [Color]()
        do {
            for color in try connection.prepare(colorsTable) {
                let newColor = UIColor(red: CGFloat(color[red] / 255), green: CGFloat(color[green] / 255), blue: CGFloat(color[blue] / 255), alpha: 1)
                generalColors.append(Color(name: color[name], correspondingColor: newColor, dateSaved: nil))
            }
        } catch {
            print(error)
        }

        return generalColors
    }

    func getSavedTexts() -> [Text]{
        guard let connection = connection else {
            fatalError()
        }

        var texts = [Text]()

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM y"

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
                texts.append(Text(id: text[id], content: text[content], dateSaved: date))
            }
        } catch {
            print(error)
        }

        return texts
    }

    func getSavedColors() -> [Color]{
        guard let connection = connection else {
            fatalError()
        }

        var colors = [Color]()

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM y"
        //Kyiv not Kiev :(
        formatter.timeZone = .some(TimeZone(identifier: "Europe/Kiev")!)

        do {
            print("Before connection")
            for color in try connection.prepare(savedTextsTable) {
                guard let date = formatter.date(from: color[colorDateSaved]) else {
                    print("Date incorrect")
                    return []
                }
                print("\(date)")
                let correspondingColor = UIColor(red: CGFloat(color[red]), green: CGFloat(color[green]), blue: CGFloat(color[blue]), alpha: 1)
                colors.append(Color(name: color[name], correspondingColor: correspondingColor, dateSaved: date))
            }
        } catch {
            print(error)
        }

        return colors
    }


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
