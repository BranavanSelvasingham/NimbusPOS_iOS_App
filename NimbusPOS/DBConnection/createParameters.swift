//
//  createParameters.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-23.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation

struct createParams{
    var collectionName: String
    var newDocument: [String: Any]
    var json: [String: Any]
    let token = NIMBUS.Devices?.sessionToken
    
    init(collectionName: String, newDocument: [String: Any]){
        self.collectionName = collectionName
        self.newDocument = newDocument
        
        self.json = [
            "collectionName": collectionName,
            "newDocument": newDocument,
            "token": token
            ] as [String : Any]
    }
}
    
