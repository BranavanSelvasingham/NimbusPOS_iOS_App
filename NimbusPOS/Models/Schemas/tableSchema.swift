//
//  tableSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-29.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct tableSchema: Codable {
    var _id: String?
    var businessId: String?
    var locationId: String?
    var status: String?
    var waiter: String?
    var tableLabel: String?
    var defaultSeats: Int16?
    var seats: Int16?
    var orders: [String]?
    var shape: String?
    var position: coordinates?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject tableMO: Table? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let tableObject = try decoder.decode(tableSchema.self, from: data)
                    self = tableObject
                } catch {
                    print(error)
                }
            }
        } else if let tableMO = tableMO {
            var table = tableSchema()

            table._id = tableMO.id
            table.businessId = tableMO.businessId
            table.locationId = tableMO.locationId
            table.status = tableMO.status
            table.waiter = tableMO.waiter
            table.tableLabel = tableMO.tableLabel
            table.defaultSeats = tableMO.defaultSeats
            table.seats = tableMO.seats
            table.orders = tableMO.orders
            table.shape = tableMO.shape
            
            table.position = coordinates()
            table.position?.x = tableMO.positionX
            table.position?.y = tableMO.positionY
            table.position?.z = tableMO.positionZ
            
            self = table
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let tableEntity = NSEntityDescription.entity(forEntityName: "Table", in: managedContext)!
            
            var tableMO: Table
            
            if let table = NIMBUS.Tables?.getTableById(tableId: self._id ?? " "){
                tableMO = table
            } else {
                tableMO = NSManagedObject(entity: tableEntity, insertInto: managedContext) as! Table
            }
            
            tableMO.id = self._id
            tableMO.businessId = self.businessId
            tableMO.locationId = self.locationId
            tableMO.status = self.status
            tableMO.waiter = self.waiter
            tableMO.tableLabel = self.tableLabel
            tableMO.defaultSeats = self.defaultSeats ?? 1
            tableMO.seats = self.seats ?? 1
            tableMO.orders = self.orders
            tableMO.shape = self.shape
            tableMO.positionX = self.position?.x ?? 0
            tableMO.positionY = self.position?.y ?? 0
            tableMO.positionZ = self.position?.z ?? 0
            
            do {
                NIMBUS.Data?.loggingCoreDataChangesEnabled = enableChangeLog
                try managedContext.save()
                NIMBUS.Data?.loggingCoreDataChangesEnabled = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func waiterName() -> String? {
        return NIMBUS.Tables?.getWaiterNameForTable(employeeId: self.waiter ?? "" )
    }
    
    func getOpenOrders() -> [Order]? {
        return NIMBUS.Tables?.getTableOpenOrder(tableId: self._id ?? "")
    }
}

struct seatStruct {
    let seatNumber: Int
}
