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

    //Texts
    let savedTextsTable = Table("Texts")
    let id = Expression<Int>("id")
    let content = Expression<String>("content")
    let dateSaved = Expression<String>("date")

    //Colors

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

    func getSavedTexts() -> [SavedText]{
        guard let connection = connection else {
            fatalError()
        }

        var texts = [SavedText]()

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM y"

        //Kyiv not Kiev :(
        formatter.timeZone = .some(TimeZone(identifier: "Europe/Kiev")!)

        do {
            print("Before connection")
            for text in try connection.prepare(savedTextsTable) {
                guard let date = formatter.date(from: text[dateSaved]) else {
                    print("Date incorrect")
                    return []
                }
                print("\(date)")
                texts.append(SavedText(id: text[id], content: text[content], dateSaved: date))
            }
        } catch {
            print(error)
        }

        return texts
    }

    func removeSavedText(with textId: Int) {
        guard let connection = connection else {
            fatalError()
        }

        let savedTextsTable = Table("Texts")
        let textToDelete = savedTextsTable.filter(id == textId)
        
        do {
            try connection.run(textToDelete.delete())
        } catch {
            print(error)
        }

        getSavedTexts()
    }

    func removeSavedColor(with id: Int) {

    }
}
