//
//  notesOptions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotesOptionsView: UIViewController{
    var notesTableView: UITableView = UITableView()
    var addedNotes = [String]()
    
    override func viewDidLoad() {
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        self.notesTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.notesTableView.estimatedRowHeight = 50
        self.notesTableView.rowHeight = UITableViewAutomaticDimension
        
        self.notesTableView.register(itemNote.self, forCellReuseIdentifier: "itemNoteCell")
        self.notesTableView.register(itemNoteInput.self, forCellReuseIdentifier: "itemNoteInputCell")
        
        self.view.addSubview(notesTableView)
        
        notesTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: notesTableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: notesTableView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: notesTableView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: notesTableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        refreshNotesData()
    }
}

extension NotesOptionsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSectionTitle(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return getNumberOfNotes(tableView: tableView, numberOfRowsInSection: section)
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getNotesCellForItem(tableView: tableView, cellForRowAt: indexPath)
        } else {
            return getNoteInputCell(tableView: tableView, cellForRowAt: indexPath)
        }
    }

}

extension NotesOptionsView: UITableViewDelegate {
}

extension NotesOptionsView {
    func getSectionTitle(forSection section: Int) ->String{
        let sectionTitles = ["Added Notes: (click to remove)", "New Note:"]
        return sectionTitles[section]
    }
    
    func getNumberOfNotes(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addedNotes.count
    }
    
    func getNotesCellForItem(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemNoteCell", for: indexPath) as! itemNote
        let indexNote = addedNotes[indexPath.row]
        
        cell.initCell(cellNote: indexNote, cellIndexPath: indexPath)
        
        return cell
    }
    
    func getNoteInputCell(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemNoteInputCell", for: indexPath) as! itemNoteInput
        return cell
    }
    
    func refreshNotesData(){
        self.addedNotes = NIMBUS.OrderCreation?.getOrderItemNotes() ?? []
        self.notesTableView.reloadData()
    }
}
