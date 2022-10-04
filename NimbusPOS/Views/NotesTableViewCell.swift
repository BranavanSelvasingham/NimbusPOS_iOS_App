//
//  NotesTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

let cellReuseIdentifier = "NotesTableViewCell"

class NotesTableViewCell: UITableViewCell {
    var note: Note? {
        didSet {
            self.textLabel?.text = note?.title
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(note: Note){
        self.note = note
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: cellReuseIdentifier)
        
        self.textLabel?.font = MDCTypography.subheadFont()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
