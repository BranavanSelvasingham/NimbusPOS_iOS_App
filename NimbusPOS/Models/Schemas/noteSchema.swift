//
//  noteSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-24.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct noteVisibility: Codable {
    var businessWide: Bool = true
    var locationSpecific: Bool = false
    var userSpecific: Bool = false
    var customerSpecific: Bool = false
    var orderSpecific: Bool = false
}

struct noteSchema: Codable {
    var _id: String? = UUID().uuidString
    var businessId: String? = NIMBUS.Business?.getBusinessId()
    var locationId: String? = NIMBUS.Location?.getLocationId()
    var userId: String?
    var customerId: String?
    var orderId: String?
    var title: String?
    var description: String?
    var visibleTo: noteVisibility? = noteVisibility()
    var createdOn: Date? = Date()
    var createdBy: String?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject noteMO: Note? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let noteObject = try decoder.decode(noteSchema.self, from: data)
                    self = noteObject
                } catch {
                    print(error)
                }
            }
        } else if let noteMO = noteMO {
            var note = noteSchema()
            
            note._id = noteMO.id
            note.businessId = noteMO.businessId
            note.locationId = noteMO.locationId
            note.userId = noteMO.userId
            note.customerId = noteMO.customerId
            note.orderId = noteMO.orderId
            note.title = noteMO.title
            note.description = noteMO.body
            note.createdOn = noteMO.createdOn as? Date ?? Date()
            note.createdBy = noteMO.createdBy
            
            note.visibleTo = noteVisibility()
            note.visibleTo!.businessWide = noteMO.visibleToBusinessWide
            note.visibleTo!.locationSpecific = noteMO.visibleToLocationSpecific
            note.visibleTo!.userSpecific = noteMO.visibleToUserSpecific
            note.visibleTo!.customerSpecific = noteMO.visibleToCustomerSpecific
            note.visibleTo!.orderSpecific = noteMO.visibleToOrderSpecific

            self = note
        }
    }

    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let noteEntity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
            
            var noteMO: Note

            if let note = NIMBUS.Notes?.getNoteById(noteId: self._id ?? " "){
                noteMO = note
            } else {
                noteMO = NSManagedObject(entity: noteEntity, insertInto: managedContext) as! Note
            }
        
            noteMO.id = self._id
            noteMO.businessId = self.businessId
            noteMO.locationId = self.locationId
            noteMO.userId = self.userId
            noteMO.customerId = self.customerId
            noteMO.orderId = self.orderId
            noteMO.title = self.title
            noteMO.body = self.description
            noteMO.createdOn = self.createdOn as? NSDate
            noteMO.createdBy = self.createdBy

            if let visibility = self.visibleTo{
                noteMO.visibleToBusinessWide = visibility.businessWide
                noteMO.visibleToLocationSpecific = visibility.locationSpecific
                noteMO.visibleToUserSpecific = visibility.userSpecific
                noteMO.visibleToCustomerSpecific = visibility.customerSpecific
                noteMO.visibleToOrderSpecific = visibility.orderSpecific
            }
            
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
