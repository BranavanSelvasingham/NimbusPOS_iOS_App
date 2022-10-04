//
//  nimbusSyncUPLocalChanges.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-28.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import NotificationCenter

class nimbusSyncUPLocalChanges: NimbusBase {
    init() {
        super.init(master: nil)
    }
    
    var localChangeLog: [ObjectChangeLog] {
        get {
            return fetchObjectChangeLogs()
        }
    }
    
    var lastSuccessfulSyncUP: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastSuccessfulSyncUP") as! Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastSuccessfulSyncUP")
            UserDefaults.standard.synchronize()
        }
    }
    
    func fetchObjectChangeLogs() -> [ObjectChangeLog]{
        var fetchChangeLogs = [ObjectChangeLog]()

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ObjectChangeLog")
        fetchRequest.returnsObjectsAsFaults = false

        do {
            fetchChangeLogs = try managedContext.fetch(fetchRequest) as! [ObjectChangeLog]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        var sortedChangeLogs = fetchChangeLogs

        sortedChangeLogs = sortedChangeLogs.sorted(by: {$0.updatedOn?.compare($1.updatedOn as! Date) == ComparisonResult.orderedDescending})

        return sortedChangeLogs
    }

    func addToChangeLog(objectId: String, collectionName: String, objectChangeType: String = ""){
        let changeLogEntity = NSEntityDescription.entity(forEntityName: "ObjectChangeLog", in: managedContext)!
        
        let changeLog: ObjectChangeLog = NSManagedObject(entity: changeLogEntity, insertInto: managedContext) as! ObjectChangeLog
        
        changeLog.objectId = objectId
        changeLog.collectionName = collectionName
        //        changeLog.objectChangeType //TO DO: don't know how to get this yet
        changeLog.updatedOn = Date() as NSDate
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllChangeLogs(){
        let deleteFetch_Products = NSFetchRequest<NSFetchRequestResult>(entityName: "ObjectChangeLog")
        let deleteRequest_Products = NSBatchDeleteRequest(fetchRequest: deleteFetch_Products)
        
        do
        {
            try managedContext.execute(deleteRequest_Products)
            try managedContext.save()
        }
        catch
        {
            print ("There was an error deleting all change logs")
        }
    }
    
    func performSyncUP(){
//        print("Performing sync UP ^^^^")
        var syncUpSuccess: Bool = true
        self.localChangeLog.forEach{changeLog in
            let collectionName: String! = changeLog.collectionName ?? ""
            let objectId: String = changeLog.objectId ?? ""
            var syncLogSuccess: Bool = true
            
            if collectionName == Order.entity().managedObjectClassName {
                if let order = NIMBUS.OrderManagement?.getOrder(byId: objectId) {
                    syncLogSuccess = NIMBUS.OrderManagement?.uploadOrder(orderMO: order) ?? false
                    if syncLogSuccess == true {
                        managedContext.delete(changeLog)
                    } else {
                        
                    }
                }
            } else if collectionName == LoyaltyCard.entity().managedObjectClassName {
                if let newLoyaltyCard = NIMBUS.LoyaltyCards?.getLoyaltyCard(byId: objectId) {
                    syncLogSuccess = NIMBUS.LoyaltyCards?.uploadCardMO(cardMO: newLoyaltyCard) ?? false
                    if syncLogSuccess == true {
                        managedContext.delete(changeLog)
                    } else {
                        
                    }
                }
            } else if collectionName == Customer.entity().managedObjectClassName {
                if let customer = NIMBUS.Customers?.getCustomerById(id: objectId) {
                    syncLogSuccess = NIMBUS.Customers?.uploadCustomer(customer: customer) ?? false
                    if syncLogSuccess == true {
                        managedContext.delete(changeLog)
                    } else {
                        
                    }
                }
            } else if collectionName == Table.entity().managedObjectClassName {
                if let table = NIMBUS.Tables?.getTableById(tableId: objectId) {
                    syncLogSuccess = NIMBUS.Tables?.uploadTableMO(tableMO: table) ?? false
                    if syncLogSuccess == true {
                        managedContext.delete(changeLog)
                    } else {
                        
                    }
                }
            } else if collectionName == Employee.entity().managedObjectClassName {
                if let employee = NIMBUS.Employees?.getEmployeeById(employeeId: objectId) {
                    syncLogSuccess = NIMBUS.Employees?.uploadEmployeeMO(employeeMO: employee) ?? false
                    if syncLogSuccess == true {
                        managedContext.delete(changeLog)
                    } else {
                        
                    }
                }
            } else if collectionName == EmployeeHours.entity().managedObjectClassName {
                if let hour = NIMBUS.EmployeeHours?.getEmployeeHourById(hourId: objectId) {
                    syncLogSuccess = NIMBUS.EmployeeHours?.uploadEmployeeHourMO(hourMO: hour) ?? false
                    if syncLogSuccess == true {
                        managedContext.delete(changeLog)
                    } else {
                        
                    }
                }
            } else if collectionName == Note.entity().managedObjectClassName {
                if let note = NIMBUS.Notes?.getNoteById(noteId: objectId) {
                    syncLogSuccess = NIMBUS.Notes?.uploadNoteMO(noteMO: note) ?? false
                    if syncLogSuccess == true {
                        managedContext.delete(changeLog)
                    } else {
                        
                    }
                }
            } 
            
            syncUpSuccess = syncUpSuccess && syncLogSuccess
        }
        
        if syncUpSuccess == true {
            lastSuccessfulSyncUP = Date()
        }
    }

}
