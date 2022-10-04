//
//  nimbusEmployeeHoursFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-24.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusEmployeeHoursFunctions: NimbusBase{
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let employeeHoursOnServer = EmployeeHourAPIs()
    
    func syncEmployeeHoursData(employeeId: String){
        syncEmployeeHoursServerDataToLocal()
    }
    
    func syncEmployeeHoursServerDataToLocal(){
        employeeHoursOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        employeeHoursOnServer.processChangeLog(log: log)
    }
    
    func getEmployeeHourById(hourId: String) -> EmployeeHours?{
        var fetchEmployeeHours = [EmployeeHours]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EmployeeHours")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", hourId)
        
        do {
            fetchEmployeeHours = try managedContext.fetch(fetchRequest) as! [EmployeeHours]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchEmployeeHours.first
    }
    
    func fetchAllEmployeeHoursby(employeeId: String) -> [EmployeeHours]{
        var fetchEmployeeHours = [EmployeeHours]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EmployeeHours")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "employeeId = %@", employeeId)
        
        do {
            fetchEmployeeHours = try managedContext.fetch(fetchRequest) as! [EmployeeHours]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        var sortedEmployeeHours = fetchEmployeeHours
        
        sortedEmployeeHours = sortedEmployeeHours.sorted(by: {$0.date?.compare($1.date as! Date) == ComparisonResult.orderedDescending})

        return sortedEmployeeHours
    }
    
    func getEmployeeHourEntryForDate(employeeId: String, date: Date) -> EmployeeHours?{
        var fetchEmployeeHours = [EmployeeHours]()
        
        let searchDate = date.startOfDay as! NSDate
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EmployeeHours")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "employeeId = %@ AND date = %@", employeeId, searchDate)
        
        do {
            fetchEmployeeHours = try managedContext.fetch(fetchRequest) as! [EmployeeHours]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchEmployeeHours.first
    }
    
    func checkInEmployeeForDate(employeeId: String, date: Date){
        if let existingEntry = getEmployeeHourEntryForDate(employeeId: employeeId, date: date){
            let clockIn = date as! NSDate
            existingEntry.actualClockIn = clockIn
            self.saveChangesToContext()
        } else {
            var newHourEntry = employeeHoursSchema()
            newHourEntry.date = date.startOfDay
            newHourEntry.employeeId = employeeId
            newHourEntry.actualClockIn = date
            newHourEntry.saveToCoreData()
        }
    }
    
    func checkOutEmployeeForDate(employeeId: String, date: Date){
        if let existingEntry = getEmployeeHourEntryForDate(employeeId: employeeId, date: date){
            let clockOut = date as! NSDate
            existingEntry.actualClockOut = clockOut
            self.saveChangesToContext()
        } else {
            var newHourEntry = employeeHoursSchema()
            newHourEntry.date = date.startOfDay
            newHourEntry.employeeId = employeeId
            newHourEntry.actualClockOut = date
            newHourEntry.saveToCoreData()
        }
    }

    
    func createNewEmployeeHourEntry(entryDate: Date, checkIn: Date, checkOut: Date, employeeId: String) {
        if let existingEntry = getEmployeeHourEntryForDate(employeeId: employeeId, date: entryDate){
            existingEntry.actualClockIn = checkIn as! NSDate
            existingEntry.actualClockOut = checkOut as! NSDate
            self.saveChangesToContext()
        } else {
            var newHourEntry = employeeHoursSchema()
            newHourEntry.date = entryDate.startOfDay
            newHourEntry.employeeId = employeeId
            newHourEntry.actualClockIn = checkIn
            newHourEntry.actualClockOut = checkOut
            newHourEntry.saveToCoreData()
        }
    }
    
    func uploadEmployeeHourMO(hourMO: EmployeeHours) -> Bool {
        return employeeHoursOnServer.uploadEmployeeHourMO(employeeHourMO: hourMO)
    }
    
    func deleteEmployeeHourEntryById(hourId: String){
        if let hour = getEmployeeHourById(hourId: hourId){
            deleteEmployeeHourEntry(employeeHourEntry: hour)
        }
    }
    
    func deleteEmployeeHourEntry(employeeHourEntry: EmployeeHours){
        managedContext.delete(employeeHourEntry)
    }
    
    func deleteAllEmployeeHours(){
        deleteAllRecords(entityName: EmployeeHours.entity().managedObjectClassName )
    }
}
