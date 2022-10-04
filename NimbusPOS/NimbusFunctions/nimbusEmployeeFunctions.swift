//
//  nimbusEmployeeFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusEmployeesFunctions: NimbusBase{
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let employeesOnServer = EmployeeAPIs()
    
    func syncEmployeeData(){
        syncEmployeesServerDataToLocal()
    }
    
    func syncEmployeesServerDataToLocal(){
        employeesOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        employeesOnServer.processChangeLog(log: log)
    }
    
    func fetchAllEmployees() -> [Employee] {
        var fetchEmployees = [Employee]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            fetchEmployees = try managedContext.fetch(fetchRequest) as! [Employee]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        var sortedEmployees = fetchEmployees
        
        sortedEmployees = sortedEmployees.sorted(by: {$0.name! < $1.name!})
        
        return sortedEmployees
    }
    
    func getEmployeeById(employeeId: String) -> Employee?{
        var fetchEmployees = [Employee]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Employee")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", employeeId)
        
        do {
            fetchEmployees = try managedContext.fetch(fetchRequest) as! [Employee]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchEmployees.first
    }
    
    func updateEmployeeName(employeeId: String, name: String){
        if let employee = getEmployeeById(employeeId: employeeId){
            if name.count > 0 && name != " "{
                employee.name = name
                self.saveChangesToContext()
            }
        }
    }
    
    func updateEmployeePhone(employeeId: String, phone: Int64){
        if let employee = getEmployeeById(employeeId: employeeId){
            employee.phone = phone
            self.saveChangesToContext()
        }
    }
    
    func updateEmployeeEmail(employeeId: String, email: String){
        if let employee = getEmployeeById(employeeId: employeeId){
            if email.count > 0 && email != " "{
                employee.email = email
                self.saveChangesToContext()
            }
        }
    }
    
    func createNewEmployee(employee: employeeSchema){
        employee.saveToCoreData()
    }
    
    func deleteEmployee(employee: Employee){
        managedContext.delete(employee)
    }
    
    func deleteEmployeeById(employeeId: String){
        if let employee = getEmployeeById(employeeId: employeeId){
            deleteEmployee(employee: employee)
        }
    }
    
    func uploadEmployeeMO(employeeMO: Employee) -> Bool{
        return employeesOnServer.uploadEmployeeMO(employeeMO: employeeMO)
    }
    
    func deleteAllEmployees(){
        deleteAllRecords(entityName: Employee.entity().managedObjectClassName )
    }
}
