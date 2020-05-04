//
//  SavedColorsViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class SavedColorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var savedColorsTableView: UITableView!
    private let cellReuseIdentifier = "cell"
    private let voiceController = VoiceController()
    private var colorsCollection = DatabaseController.shared.getSavedColors()
    private let dateFormatter = DateFormatter()


    override func viewDidLoad() {
           super.viewDidLoad()
           self.savedColorsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
           savedColorsTableView.delegate = self
           savedColorsTableView.dataSource = self
       }

       @IBAction func handleScreenEdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
           if sender.state == .began {
               self.dismiss(animated: true, completion: nil)
           }
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return self.colorsCollection.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell: UITableViewCell = self.savedColorsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
           cell.contentView.backgroundColor = UIColor(red: 94, green: 253, blue: 234, alpha: 1)


           dateFormatter.dateStyle = .short
           dateFormatter.timeStyle = .short
           let dateString = dateFormatter.string(from: self.colorsCollection[indexPath.row].dateSaved)

           cell.textLabel?.text = "Record №\(indexPath.row + 1) | Date: \(dateString)"
           return cell
       }

       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           dateFormatter.dateStyle = .short
           dateFormatter.timeStyle = .short

           voiceController.read(text: "Reading text saved on \(dateFormatter.string(from: self.colorsCollection[indexPath.row].dateSaved)). Content is: \(self.colorsCollection[indexPath.row].content)")
       }

       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

           if editingStyle == .delete {
               DatabaseController.shared.removeSavedText(with: colorsCollection[indexPath.row].id)
               colorsCollection.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)
           }
       }

}
