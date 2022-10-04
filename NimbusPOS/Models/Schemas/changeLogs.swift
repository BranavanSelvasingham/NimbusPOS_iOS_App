//
//  changeLogs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-01.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

//server change logs:
struct serverChangeLog: Codable {
    var _id: String?
    var businessId: String?
    var collectionName: String?
    var objectId: String?
    var objectChangeType: String?
    var updateTask: String?
    var updatedOn: Date?
    
    init (withJSONDataObject json: [String: Any] = [:]){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let serverChangeLogObject = try decoder.decode(serverChangeLog.self, from: data)
                    self = serverChangeLogObject
                } catch {
                    print(error)
                }
            }
        }
    }
}

//local change logs:

