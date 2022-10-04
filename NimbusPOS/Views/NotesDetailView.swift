//
//  NotesDetailView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//
import Foundation
import UIKit
import MaterialComponents

class NotesDetailView: UIViewController, UITextViewDelegate {
    var noteTitle: UITextField = UITextField()
    var noteBody: UITextView = UITextView()
    var noteBodyBackground: UIImageView = UIImageView()
    var noteViewManagerDelegate: NoteViewManagerDelegate?
    
    var note: Note?{
        didSet{
            noteTitle.text = note?.title
            noteBody.text = note?.body
        }
    }
    
    func noteSelected(noteMO: Note){
        self.note = noteMO
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noteTitle.font = MDCTypography.titleFont()
        self.noteTitle.placeholder = "Note Title"
        self.noteTitle.addTarget(self, action: #selector(noteTitleEdited(_:)), for: .editingChanged)
        self.view.addSubview(noteTitle)
        
        self.noteBody.font = MDCTypography.body2Font()
        self.noteBody.backgroundColor = UIColor.clear
        self.noteBody.layer.borderColor = UIColor.lightGray.cgColor
        self.noteBody.layer.borderWidth = 1
        self.noteBody.delegate = self
        
        let backgroundImage = UIImage(named: "background_paper_white_1")
        self.noteBodyBackground.image = backgroundImage
        self.noteBodyBackground.contentMode = .scaleAspectFill
        
        self.view.addSubview(noteBodyBackground)
        self.view.addSubview(noteBody)
        self.view.sendSubview(toBack: noteBodyBackground)
        
        self.view.autoresizesSubviews = true
    }
    
    override func viewWillLayoutSubviews() {
        self.noteTitle.frame = CGRect(origin: CGPoint(x: 10, y: 0), size: CGSize(width: self.view.frame.width - 20, height: 50 ))
        self.noteBody.frame = CGRect(origin: CGPoint(x: 10, y: self.noteTitle.frame.height + 10 ), size: CGSize(width: self.view.frame.width - 20, height: self.view.frame.height - self.noteTitle.frame.height - 20 ))
        self.noteBodyBackground.frame = CGRect(origin: CGPoint(x: 0, y: 0 ), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
    }

    func noteTitleEdited(_ sender: UITextField){
        note?.title = sender.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        note?.body = textView.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        note?.body = textView.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteThisNote(){
        NIMBUS.Notes?.deleteNote(note: note!)
    }
    
}
