//
//  ProductAddonSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-29.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct productAddOnSchema: Codable{
    var _id: String?
    var name: String?
    var price: Float?
    var categories: [String]?
    var isSubstitution: Bool?
    var businessId: String?
    var status: String?
    var createdBy: String?
    var createdAt: Date?
    var updatedBy: String?
    var updatedAt: Date?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject addOnMO: ProductAddOn? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let addOnObject = try decoder.decode(productAddOnSchema.self, from: data)
                    self = addOnObject
                } catch {
                    print(error)
                }
            }
        } else if let addOnMO = addOnMO {
            var AddOn = productAddOnSchema()
            
            AddOn._id = addOnMO.id
            AddOn.name = addOnMO.name
            AddOn.price = addOnMO.price
            AddOn.categories = addOnMO.categories as! [String]
            AddOn.isSubstitution = addOnMO.isSubstitution
            AddOn.businessId = addOnMO.businessId
            AddOn.status = addOnMO.status
            AddOn.createdAt = addOnMO.createdAt as Date?
            AddOn.createdBy = addOnMO.createdBy as String?
            AddOn.updatedAt = addOnMO.updatedAt as Date?
            AddOn.updatedBy = addOnMO.updatedBy as String?
            
            self = AddOn
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let addOnEntity = NSEntityDescription.entity(forEntityName: "ProductAddOn", in: managedContext)!
            
            var addOn: ProductAddOn

            if let existingAddOn = NIMBUS.AddOns?.getAddOnById(addOnId: self._id ?? " "){
                //addon exists
                addOn = existingAddOn
            } else {
                addOn = NSManagedObject(entity: addOnEntity, insertInto: managedContext) as! ProductAddOn
            }
            
            addOn.id = self._id
            addOn.name = self.name
            addOn.businessId = self.businessId
            addOn.price = self.price as? Float ?? 0.00
            addOn.categories = self.categories as NSArray?
            addOn.isSubstitution = self.isSubstitution as? Bool ?? false
            addOn.status = self.status as String?
            addOn.createdAt = self.createdAt as NSDate?
            addOn.createdBy = self.createdBy
            addOn.updatedBy = self.updatedBy
            addOn.updatedAt = self.updatedAt as NSDate?
            
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
