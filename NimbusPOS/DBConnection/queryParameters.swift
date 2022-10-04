//
//  QueryParameters.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-22.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation

struct queryParams{
    var collectionName: String
    var findParams: [String: Any] = [:]
    var limit: NSNumber
    var sortParams: [String: Any] = [:]
    var selectParams: [String: Any] = [:]
    let token = NIMBUS.Devices?.sessionToken
    var json: [String: Any]
    
    init(collectionName: String, findParams: [String: Any] = [:], limit: NSNumber = 0, sortParams: [String: Any] = [:], selectParams: [String: Any] = [:]){
        self.collectionName = collectionName
        self.findParams = findParams
        self.limit = limit
        self.sortParams = sortParams
        self.selectParams = selectParams
        
        self.json = [
            "collectionName": collectionName,
            "findParams": findParams,
            "limit": limit,
            "sortParams": sortParams,
            "selectParams": selectParams,
            "token": token
        ] as [String : Any]
    }
}
    
