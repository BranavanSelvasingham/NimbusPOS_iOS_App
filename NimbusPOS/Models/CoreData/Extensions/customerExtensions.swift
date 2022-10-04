//
//  customerExtensions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-29.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension Customer {
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
