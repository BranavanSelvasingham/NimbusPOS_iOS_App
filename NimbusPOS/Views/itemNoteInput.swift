//
//  itemNoteInput.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-29.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

class itemNoteInput: UITableViewCell {
    
    var noteInput: UITextField = UITextField()
    var addNoteButton: UIButton = UIButton()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        addNoteButton.setTitle("Add Note", for: .normal)
        addNoteButton.backgroundColor = UIColor.gray
        addNoteButton.setTitleColor(UIColor.white, for: .normal)
        
        noteInput.layer.borderWidth = 1
        noteInput.layer.borderColor = UIColor.lightGray.cgColor
        
        self.contentView.addSubview(noteInput)
        self.contentView.addSubview(addNoteButton)
        
        addNoteButton.addTarget(self, action: #selector(addNoteButtonClick), for: .touchUpInside)
        
        noteInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: noteInput, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: noteInput, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: noteInput, attribute: .trailing, relatedBy: .equal, toItem: addNoteButton, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: noteInput, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        addNoteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: addNoteButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addNoteButton, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: addNoteButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: addNoteButton, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addNoteButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addNoteButtonClick() {
        let newNote = noteInput.text ?? ""
        if !newNote.isEmpty {
            NIMBUS.OrderCreation?.addNoteToOrderItem(note: newNote)
            noteInput.text = ""
        }
    }
    
}
