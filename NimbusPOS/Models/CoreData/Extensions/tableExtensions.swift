//
//  tableExtensions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension Table {
    func waiterName() -> String? {
        return NIMBUS.Tables?.getWaiterNameForTable(employeeId: self.waiter ?? "" )
    }
    
    func getOpenOrders() -> [Order]? {
        return NIMBUS.Tables?.getTableOpenOrder(tableId: self.id ?? "")
    }
    
    public override func didSave() {
        if NIMBUS.Data?.loggingCoreDataChangesEnabled == true {
            if let objectId = self.id {
                if let collectionName = self.entity.managedObjectClassName {
                    NIMBUS.Data?.syncUP.addToChangeLog(objectId: objectId, collectionName: collectionName)
                }
            }
        }
    }
}
