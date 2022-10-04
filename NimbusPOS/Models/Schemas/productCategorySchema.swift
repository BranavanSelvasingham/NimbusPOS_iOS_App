//
//  productCategorySchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-29.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct productCategorySchema: Codable{
    var _id: String?
    var name: String?
    var color: String?
    var businessId: String?
    var sortPosition: Int16?
    var createdBy: String?
    var createdAt: Date?
    var updatedBy: String?
    var updatedAt: Date?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject categoryMO: ProductCategory? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let categoryObject = try decoder.decode(productCategorySchema.self, from: data)
                    self = categoryObject
                } catch {
                    print(error)
                }
            }
        } else if let categoryMO = categoryMO {
            var category = productCategorySchema()
            
            category._id = categoryMO.id
            category.businessId = categoryMO.businessId
            category.name = categoryMO.name
            category.color = categoryMO.color
            category.sortPosition = categoryMO.sortPosition
            category.createdAt = categoryMO.createdAt as Date?
            category.updatedAt = categoryMO.updatedAt as Date?
            
            self = category
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext

            let categoryEntity = NSEntityDescription.entity(forEntityName: "ProductCategory", in: managedContext)!
            
            var category: ProductCategory

            if let cat = NIMBUS.Categories?.getCategoryById(categoryId: self._id ?? " "){
                //category exists
                category = cat
            } else {
                category = NSManagedObject(entity: categoryEntity, insertInto: managedContext) as! ProductCategory
            }
            
            category.id = self._id
            category.name = self.name
            category.color = self.color
            category.sortPosition = self.sortPosition ?? 0
            category.businessId = self.businessId
            category.createdAt = self.createdAt as NSDate?
            category.updatedAt = self.updatedAt as NSDate?
            
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
