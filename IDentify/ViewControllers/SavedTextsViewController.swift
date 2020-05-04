//
//  SavedTextsViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class SavedTextsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var savedTextsTableView: UITableView!
    private let cellReuseIdentifier = "cell"
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
        
        cell.textLabel?.textColor = #colorLiteral(red: 0.06666666667, green: 0.1764705882, blue: 0.2039215686, alpha: 1)
        cell.textLabel?.text = "Record №\(indexPath.row + 1) | Date: \(dateString)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        voiceController.read(text: "Reading text saved on \(dateFormatter.string(from: self.textsCollection[indexPath.row].dateSaved)). Content is: \(self.textsCollection[indexPath.row].content)")
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            DatabaseController.shared.removeSavedText(with: textsCollection[indexPath.row].id)
            textsCollection.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
