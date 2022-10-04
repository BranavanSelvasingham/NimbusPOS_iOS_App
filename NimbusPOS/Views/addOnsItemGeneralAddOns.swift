//
//  addOnsItemGeneralAddOns.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class addOnsItemGeneralAddOns: UITableViewCell {
    var cellAddOnItem: orderItemAddOns?
    var cellIndexPath: IndexPath?

    func initCell(cellAddOnItem: orderItemAddOns, cellIndexPath: IndexPath ){
        self.cellAddOnItem = cellAddOnItem
        self.cellIndexPath = cellIndexPath
        self.textLabel?.text = cellAddOnItem.name
        self.textLabel?.font = MDCTypography.subheadFont()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            NIMBUS.OrderCreation?.addSelectedAddOnToOrderItem(selectedAddOn: self.cellAddOnItem!)
        }
    }
}
