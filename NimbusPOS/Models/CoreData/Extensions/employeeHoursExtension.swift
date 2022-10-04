//
//  employeeHoursExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension EmployeeHours {
    public override func didSave() {
        if NIMBUS.Data?.loggingCoreDataChangesEnabled == true {
            if let objectId = self.id {
                if let collectionName = self.entity.managedObjectClassName {
                    NIMBUS.Data?.syncUP.addToChangeLog(objectId: objectId, collectionName: collectionName)
                }
            }
        }
    }
    
    func isCheckedIn()-> Bool {
        if self.actualClockIn != nil {
            return true
        }
        return false
    }
    
    func isCheckedOut()->Bool {
        if self.actualClockOut != nil {
            return true
        }
        return false
    }
}
