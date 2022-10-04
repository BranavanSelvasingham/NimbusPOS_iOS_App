//
//  upsertParameters.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-30.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

struct upsertParams{
    var collectionName: String
    var findParams: [String: Any] = [:]
    var updateParams: [String: Any] = [:]
    var newDocument: [String: Any]
    let token = NIMBUS.Devices?.sessionToken
    var json: [String: Any]
    
    init(collectionName: String, newDocument: [String: Any]){
        self.collectionName = collectionName
        self.newDocument = newDocument
        self.findParams = ["_id": newDocument["_id"]]
        self.updateParams = newDocument
        
        self.json = [
            "collectionName": collectionName,
            "newDocument": newDocument,
            "findParams": findParams,
            "updateParams": updateParams,
            "token": token
            ] as [String : Any]
    }
}

