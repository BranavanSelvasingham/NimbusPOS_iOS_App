//
//  NotesTableViewTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import NotificationCenter

class NotesTableView: UITableViewController {
    init() {
        super.init(style: .plain)
    }
    
    var noteViewManagerDelegate: NoteViewManagerDelegate?
    var fetchedNotes = [Note](){
        didSet {
            self.tableView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchedNotes = NIMBUS.Notes?.fetchAllNotesSortedByDate() ?? []
        
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshNotesData(_:)), for: .valueChanged)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(NotesTableViewCell.self, forCellReuseIdentifier: "NotesTableViewCell")
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange),
                                       name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: NIMBUS.Notes?.managedContext)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstNoteIndex = IndexPath(row: 0, section: 0)
        if let firstCell = self.tableView.cellForRow(at: firstNoteIndex) as? NotesTableViewCell{
            self.tableView.selectRow(at: firstNoteIndex, animated: false, scrollPosition: .top)
            if let firstNote = firstCell.note {
                noteViewManagerDelegate?.noteSelected(note: firstNote)
            }
        }
    }
    
    func refreshNotesData(_ sender: Any){
        self.fetchedNotes = NIMBUS.Notes?.fetchAllNotesSortedByDate() ?? []
        self.tableView.refreshControl?.endRefreshing()
    }

    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Note.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription,
                                                                    notification: notification,
                                                                    callFunction: self.refreshNotesData(_:))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedNotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        let indexNote = fetchedNotes[indexPath.row]
        cell.initCell(note: indexNote)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NotesTableViewCell
        noteViewManagerDelegate?.noteSelected(note: cell.note!)
    }

}
