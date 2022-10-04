//
//  NotesViewManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-19.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

protocol NoteViewManagerDelegate {
    func noteSelected(note: Note)
    func addNewNote()
    func deleteSelectedNote()
    func dismissNewNoteModal()
    func saveNewNote()
}

class NotesViewManager: UIViewController, NoteViewManagerDelegate {
    var notesTableViewController: NotesTableView = NotesTableView()
    var notesDetailViewController: NotesDetailView = NotesDetailView()
    var notesCreateViewController: NoteCreateView = NoteCreateView()
    var pageView: PageView = PageView()
    var createNoteModal: SlideOverModalView = SlideOverModalView()
    
    var selectedNote: Note? {
        didSet {
            notesDetailViewController.noteSelected(noteMO: selectedNote!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageView = PageView(frame: self.view.frame)
        pageView.leftSection.setHeaderTitle(title: "Notes")
        
        let addNoteButton = UIBarButtonItem(image: UIImage(named: "ic_add"), style: .plain, target: self, action: #selector(addNewNote))
        pageView.leftSection.buttonBarActionButtons = [addNoteButton]
        
        notesTableViewController = NotesTableView()
        notesTableViewController.noteViewManagerDelegate = self
        self.addChildViewController(notesTableViewController)
        pageView.addTableViewToLeftSection(tableView: notesTableViewController.view)
        notesTableViewController.didMove(toParentViewController: self)
        
        let deleteButton = UIBarButtonItem(image: UIImage(named: "ic_delete"), style: .plain, target: self, action: #selector(deleteSelectedNote))
        pageView.rightSection.rightButtonBarActionButtons = [deleteButton]
        
        notesDetailViewController = NotesDetailView()
        notesDetailViewController.noteViewManagerDelegate = self
        self.addChildViewController(notesDetailViewController)
        pageView.addDetailViewToRightSection(detailView: notesDetailViewController.view)
        notesDetailViewController.didMove(toParentViewController: self)
        
        self.view.addSubview(pageView)
        
        //Create New Note Modal
        notesCreateViewController = NoteCreateView()
        notesCreateViewController.noteViewManagerDelegate = self
        self.addChildViewController(notesCreateViewController)
        createNoteModal = SlideOverModalView(frame: self.view.frame)
        createNoteModal.addViewToModal(view: notesCreateViewController.view)
        createNoteModal.headerTitle = "New Note"
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(dismissNewNoteModal))
        createNoteModal.rightButtonBarActionButtons = [dismissButton]
        
        let saveNewNoteButton = UIBarButtonItem(image: UIImage(named: "ic_save"), style: .plain, target: self, action: #selector(saveNewNote))
        createNoteModal.leftButtonBarActionButtons = [saveNewNoteButton]
        
        notesCreateViewController.didMove(toParentViewController: self)
        
        self.view.addSubview(createNoteModal)
        self.view.bringSubview(toFront: createNoteModal)
    }
    
    override func viewWillLayoutSubviews() {
        pageView.frame = self.view.frame
        createNoteModal.frame = self.view.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func noteSelected(note: Note) {
        self.selectedNote = note
    }
    
    func addNewNote(){
        createNoteModal.presentModal()
    }
    
    func deleteSelectedNote(){
        if let selectedNote = selectedNote {
            NIMBUS.Notes?.deleteNote(note: selectedNote)
        }
    }
    
    func dismissNewNoteModal(){
        createNoteModal.dismissModal()
    }
    
    func saveNewNote() {
        notesCreateViewController.saveNewNote()
    }
}
