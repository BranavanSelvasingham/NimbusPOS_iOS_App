//
//  employeeSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-28.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct employeeSchema: Codable {
    var _id: String?
    var name: String?
    var businessId: String?
    var phone: Int64?
    var pin: String?
    var email: String?
//    var plannedHours: [employeeHours]?
//    var actualHours: [employeeHours]?
    var status: String?
    var rate: Float?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject employeeMO: Employee? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let employeeObject = try decoder.decode(employeeSchema.self, from: data)
                    self = employeeObject
                } catch {
                    print(error)
                }
            }
        } else if let employeeMO = employeeMO {
            var employee = employeeSchema()
            
            employee._id = employeeMO.id
            employee.name = employeeMO.name
            employee.businessId = employeeMO.businessId
            employee.phone = employeeMO.phone
            employee.pin = employeeMO.pin
            employee.email = employeeMO.email
            employee.status = employeeMO.status
            employee.rate = employeeMO.rate
            
            self = employee
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let employeeEntity = NSEntityDescription.entity(forEntityName: "Employee", in: managedContext)!
            
            var employeeMO: Employee
            
            if let employee = NIMBUS.Employees?.getEmployeeById(employeeId: self._id ?? " "){
                employeeMO = employee
            } else {
                employeeMO = NSManagedObject(entity: employeeEntity, insertInto: managedContext) as! Employee
            }
            
            employeeMO.id = self._id
            employeeMO.name = self.name
            employeeMO.businessId = self.businessId
            employeeMO.phone = self.phone ?? 0
            employeeMO.pin = self.pin
            employeeMO.email = self.email
            employeeMO.status = self.status
            employeeMO.rate = self.rate ?? 0
            
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
