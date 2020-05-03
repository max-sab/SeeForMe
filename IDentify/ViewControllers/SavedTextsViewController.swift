//
//  SavedTextsViewController.swift
//  IDentify
//
//  Created by Maksym Sabadyshyn on 5/3/20.
//  Copyright © 2020 Maksym Sabadyshyn. All rights reserved.
//

import UIKit

class SavedTextsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cellReuseIdentifier = "cell"
    @IBOutlet weak var savedTextsTableView: UITableView!
    var textsCollection = DatabaseController.shared.getSavedTexts()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.savedTextsTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        savedTextsTableView.delegate = self
        savedTextsTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.textsCollection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell: UITableViewCell = self.savedTextsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        // set the text from the data s
        cell.textLabel?.text = "Record №\(self.textsCollection[indexPath.row].id) | Date added: \(self.textsCollection[indexPath.row].dateSaved)" 
        return cell
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

}
