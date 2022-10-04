//
//  orderExtensions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-12.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension Order {
    func formattedUniqueOrderNumber() -> String {
       let rawString = String(self.uniqueOrderNumber)
       return rawString.insertingReverse(separator: " ", every: 3)
    }
    
    func formattedDailyOrderNumber() -> String {
        let rawString = String(self.dailyOrderNumber ?? 1)
        return ("#" + rawString.insertingReverse(separator: "-", every: 3))
    }
    
    func formattedCreatedDate(includeTime: Bool = true, longDate: Bool = false) -> String {
        if let createdAt = self.createdAt {
            return createdAt.toDateStringWithTime(dateStyle: .short , timeStyle: .short)
        }
        return ""
    }

    public override func didSave() {
        if NIMBUS.Data?.loggingCoreDataChangesEnabled == true {
            if let objectId = self.id {
                if let collectionName = self.entity.managedObjectClassName {
                    NIMBUS.Data?.syncUP.addToChangeLog(objectId: objectId, collectionName: collectionName)
                }
            }
            
//            NIMBUS.Data?.performPeriodicSync()
        }
    }
    
}
