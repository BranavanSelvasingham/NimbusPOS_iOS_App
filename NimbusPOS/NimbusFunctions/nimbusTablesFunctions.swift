//
//  nimbusTablesFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusTablesFunctions: NimbusBase{
    override init(master: NimbusFramework?){
        super.init(master: master)
    }

    let tablesOnServer = TableAPIs()
    
    func syncTablesServerDataToLocal(){
        tablesOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        tablesOnServer.processChangeLog(log: log)
    }
    
    func fetchAllTables() -> [Table]{
        var fetchTables = [Table]()
        
        let locationId = NIMBUS.Location?.getLocationId() ?? ""
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Table")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "locationId = %@", locationId)
        
        do {
            fetchTables = try managedContext.fetch(fetchRequest) as! [Table]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let sortedTables = fetchTables.sorted(by: {$0.tableLabel! < $1.tableLabel!})
        
        return sortedTables
    }
    
    func getTableById(tableId: String) -> Table? {
        var fetchTables = [Table]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Table")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", tableId)
        
        do {
            fetchTables = try managedContext.fetch(fetchRequest) as! [Table]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchTables.first
    }
    
    func createNewTable(table: tableSchema){
        table.saveToCoreData()
    }
    
    func deleteTable(table: Table){
        managedContext.delete(table)
    }
    
    func deleteTableById(tableId: String){
        if let table = getTableById(tableId: tableId){
            deleteTable(table: table)
        }
    }
    
    func getWaiterNameForTable(employeeId: String) -> String?  {
        let employee = NIMBUS.Employees?.getEmployeeById(employeeId: employeeId)
        return employee?.name
    }
    
    func getTableOpenOrder(tableId: String) -> [Order]? {
        return NIMBUS.OrderManagement?.getOpenOrderForTable(tableId: tableId)
    }
    
    func uploadTableMO(tableMO: Table) -> Bool {
        return tablesOnServer.uploadTableMO(tableMO: tableMO)
    }
    
    func deleteAllTables(){
        deleteAllRecords(entityName: Table.entity().managedObjectClassName )
    }
    
}
