//
//  updateParameters.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-23.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation

struct updateParams{
    var collectionName: String
    var findParams: [String: Any] = [:]
    var updateParams: [String: Any] = [:]
    let token = NIMBUS.Devices?.sessionToken
    var json: [String: Any]
    
    init(collectionName: String, findParams: [String: Any] = [:], updateParams: [String: Any] = [:]){
        self.collectionName = collectionName
        self.findParams = findParams
        self.updateParams = updateParams
        
        self.json = [
            "collectionName": collectionName,
            "findParams": findParams,
            "updateParams": updateParams,
            "token": token
            ] as [String : Any]
    }
}
    
