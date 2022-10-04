//
//  employeeHoursSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct employeeHoursSchema: Codable {
    var _id: String? = UUID().uuidString
    var businessId: String? = NIMBUS.Business?.getBusinessId()
    var employeeId: String?
    var date: Date?
    var actualHours: Float?
    var actualClockIn: Date?
    var actualClockOut: Date?
    var plannedHours: Float?
    var plannedClockIn: Date?
    var plannedClockOut: Date?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject employeeHoursMO: EmployeeHours? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let employeeHoursObject = try decoder.decode(employeeHoursSchema.self, from: data)
                    self = employeeHoursObject
                } catch {
                    print(error)
                }
            }
        } else if let employeeHoursMO = employeeHoursMO {
            var employeeHoursEntry = employeeHoursSchema()
            
            employeeHoursEntry._id = employeeHoursMO.id
            employeeHoursEntry.businessId = employeeHoursMO.businessId
            employeeHoursEntry.employeeId = employeeHoursMO.employeeId
            employeeHoursEntry.date = employeeHoursMO.date as? Date
            employeeHoursEntry.actualHours = employeeHoursMO.actualHours
            employeeHoursEntry.actualClockIn = employeeHoursMO.actualClockIn as? Date
            employeeHoursEntry.actualClockOut = employeeHoursMO.actualClockOut as? Date
            employeeHoursEntry.plannedHours = employeeHoursMO.plannedHours
            employeeHoursEntry.plannedClockIn = employeeHoursMO.plannedClockIn as? Date
            employeeHoursEntry.plannedClockOut = employeeHoursMO.plannedClockOut as? Date
            
            self = employeeHoursEntry
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let employeeHoursEntity = NSEntityDescription.entity(forEntityName: "EmployeeHours", in: managedContext)!
            
            var employeeHoursMO: EmployeeHours
            
            if let employeeHour = NIMBUS.EmployeeHours?.getEmployeeHourById(hourId: self._id ?? " ") {
                employeeHoursMO = employeeHour
            } else {
                employeeHoursMO = NSManagedObject(entity: employeeHoursEntity, insertInto: managedContext) as! EmployeeHours
            }
            
            employeeHoursMO.id = self._id
            employeeHoursMO.businessId = self.businessId
            employeeHoursMO.employeeId = self.employeeId
            employeeHoursMO.date = self.date as? NSDate
            employeeHoursMO.actualHours = self.actualHours ?? 0
            employeeHoursMO.actualClockIn = self.actualClockIn as? NSDate
            employeeHoursMO.actualClockOut = self.actualClockOut as? NSDate
            employeeHoursMO.plannedHours = self.plannedHours ?? 0
            employeeHoursMO.plannedClockIn = self.plannedClockIn as? NSDate
            employeeHoursMO.plannedClockOut = self.plannedClockOut as? NSDate
            
            do {
                NIMBUS.Data?.loggingCoreDataChangesEnabled = enableChangeLog
                try managedContext.save()
                NIMBUS.Data?.loggingCoreDataChangesEnabled = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func isCheckedIn()-> Bool {
        if let checkIn = self.actualClockIn {
            return true
        }
        return false
    }
    
    func isCheckedOut()->Bool {
        if let checkOut = self.actualClockOut {
            return true
        }
        return false
    }
}
