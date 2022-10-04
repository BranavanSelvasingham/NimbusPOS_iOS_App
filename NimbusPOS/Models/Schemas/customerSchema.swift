//
//  customerSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-28.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct customerSchema: Codable{
    var _id: String? = UUID().uuidString
    var name: String?
    var email: String?
    var phone: Int64?
    var businessId: String? = NIMBUS.Business?.getBusinessId()
    var notes: String?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject customerMO: Customer? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let customerObject = try decoder.decode(customerSchema.self, from: data)
                    self = customerObject
                } catch {
                    print(error)
                }
            }
        } else if let customerMO = customerMO {
            var customer = customerSchema()
            
            customer._id = customerMO.id
            customer.name = customerMO.name
            customer.email = customerMO.email
            customer.phone = customerMO.phone
            customer.businessId = customerMO.businessId
            customer.notes = customerMO.notes
            
            self = customer
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let customerEntity = NSEntityDescription.entity(forEntityName: "Customer", in: managedContext)!
            
            var customerMO: Customer
            
            if let customer = NIMBUS.Customers?.getCustomerById(id: self._id ?? " " ){
                customerMO = customer
            } else {
                customerMO = NSManagedObject(entity: customerEntity, insertInto: managedContext) as! Customer
            }
            
            customerMO.id = self._id
            customerMO.name = self.name
            customerMO.email = self.email
            customerMO.phone = self.phone ?? 0
            customerMO.businessId = self.businessId
            customerMO.notes = self.notes
            
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
