//
//  itemNote.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-29.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class itemNote: UITableViewCell {
    var cellNote: String?
    var cellIndexPath: IndexPath?
    
    func initCell(cellNote: String, cellIndexPath: IndexPath ){
        self.cellNote = cellNote
        self.cellIndexPath = cellIndexPath
        self.textLabel?.text = cellNote
        self.textLabel?.font = MDCTypography.subheadFont()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected == true {
            NIMBUS.OrderCreation?.removeNoteFromOrderItem(note: cellNote!)
        }
    }

}
