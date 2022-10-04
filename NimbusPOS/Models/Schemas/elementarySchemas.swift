//
//  elementarySchemas.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-29.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation

struct timeComponents: Codable {
    var year: Int? = Calendar.current.component(.year, from: Date())
    var month: Int? = Calendar.current.component(.month, from: Date()) - 1
    var day: Int? = Calendar.current.component(.day, from: Date())
    var hour: Int? = Calendar.current.component(.hour, from: Date())
    
    init(createdDate: Date = Date()){
        year = Calendar.current.component(.year, from: createdDate)
        month = Calendar.current.component(.month, from: createdDate) - 1
        day = Calendar.current.component(.day, from: createdDate)
        hour = Calendar.current.component(.hour, from: createdDate)
    }
}

struct coordinates: Codable {
    var x: Float?
    var y: Float?
    var z: Float?
    
//    init(){
//        self.x = 0.0
//        self.y = 0.0
//        self.z = 0.0
//    }
//
//    mutating func initWithJSON(json: [String: Float]){
//        self.x = json["x"] as! Float
//        self.y = json["y"] as! Float
//        self.z = json["z"] as! Float
//    }
}

struct addressSchema: Codable {
    var street: String?
    var city: String?
    var state: String?
    var pin: String?
    var country: String?
}
