//
//  SavedTextsViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class SavedTextsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let cellReuseIdentifier = "cell"
    @IBOutlet weak var savedTextsTableView: UITableView!
    private let voiceController = VoiceController()
    private var textsCollection = DatabaseController.shared.getSavedTexts()
    private let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.savedTextsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        savedTextsTableView.delegate = self
        savedTextsTableView.dataSource = self
    }

    @IBAction func handleScreenEdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textsCollection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.savedTextsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.contentView.backgroundColor = UIColor(red: 94, green: 253, blue: 234, alpha: 1)


        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: self.textsCollection[indexPath.row].dateSaved)

        cell.textLabel?.text = "Record №\(indexPath.row + 1) | Date: \(dateString)"
        return cell
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        voiceController.read(text: "Reading text saved on \(dateFormatter.string(from: self.textsCollection[indexPath.row].dateSaved)). Content is: \(self.textsCollection[indexPath.row].content)")
    }

    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            // remove the item from the data model
            textsCollection.remove(at: indexPath.row)

            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)

        } else if editingStyle == .insert {
            // Not used in our example, but if you were adding a new row, this is where you would do it.
        }
    }

}
