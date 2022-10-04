//
//  locationSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-28.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct locationSchema: Codable {
    var _id: String?
    var name: String?
    var businessId: String?
    var address: address?
    var receiptMessage: String?
    var printers: [printer]?
    var floorLayoutSections: [floorSections]?
    
    struct address: Codable {
        var street: String?
        var city: String?
        var state: String?
        var pin: String?
        var country: String?
    }

    struct printer: Codable {
        var connection: String?
        var use: String?
        var address: String?
        var name: String?
        var disabled: Bool?
    }

    struct floorTile: Codable {
        var name: String?
        var url: String?
    }

    struct cornerCoordinates: Codable {
        var x: Float?
        var y: Float?
        var z: Float?
    }

    struct floorSections: Codable {
        var name: String?
        var floorTile: floorTile?
        var vertices: [cornerCoordinates]
    }

    init (withJSONDataObject json: [String: Any] = [:], withManagedObject locationMO: Location? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let locationObject = try decoder.decode(locationSchema.self, from: data)
                    self = locationObject
                } catch {
                    print(error)
                }
            }
        } else if let locationMO = locationMO {
            
        
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
            
            var location: Location
            
            if let loc = NIMBUS.Location?.getLocationById(locationId: self._id ?? " "){
                location = loc
            } else {
                location = NSManagedObject(entity: locationEntity, insertInto: managedContext) as! Location
            }
            
            location.id = self._id
            location.name = self.name
            location.businessId = self.businessId
            location.receiptMessage = self.receiptMessage
            location.addressStreet = self.address?.street
            location.addressCity = self.address?.city
            location.addressState = self.address?.state
            location.addressPin = self.address?.pin
            location.addressCountry = self.address?.country
            
            do {
                NIMBUS.Data?.loggingCoreDataChangesEnabled = enableChangeLog
                try managedContext.save()
                NIMBUS.Data?.loggingCoreDataChangesEnabled = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}

