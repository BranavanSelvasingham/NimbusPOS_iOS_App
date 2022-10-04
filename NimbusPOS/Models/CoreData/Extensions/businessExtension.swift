//
//  businessExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-18.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Business {
    func convertToStruct() -> businessSchema {
        return businessSchema(withManagedObject: self)
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
