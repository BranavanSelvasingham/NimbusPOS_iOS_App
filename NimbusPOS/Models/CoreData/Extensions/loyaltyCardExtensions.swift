//
//  loyaltyCardExtensions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension LoyaltyCard {
    func programName() -> String {
        return NIMBUS.LoyaltyPrograms?.getProgramName(byId: self.programId ?? "") ?? ""
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
