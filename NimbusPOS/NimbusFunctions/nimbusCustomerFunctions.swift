//
//  nimbusCustomerFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-20.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusCustomerFunctions: NimbusBase{
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let customerServer = CustomerAPIs()
    
    func syncCustomerServerDataToLocal(){
        customerServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        customerServer.processChangeLog(log: log)
    }
    
    func syncCustomersData(){
        syncCustomerServerDataToLocal()
    }
    
    func fetchAllCustomers(predicate: NSPredicate?) -> [Customer]{
        var fetchCustomers = [Customer]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Customer")
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            fetchCustomers = try managedContext.fetch(fetchRequest) as! [Customer]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        var soredCustomers = fetchCustomers
        
        soredCustomers = soredCustomers.sorted(by: {$0.name ?? "" < $1.name ?? ""})
        
        return soredCustomers
    }
    
    func fetchCustomer(predicate: NSPredicate) -> Customer? {
        var fetchCustomers = [Customer]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Customer")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = predicate
        
        do {
            fetchCustomers = try managedContext.fetch(fetchRequest) as! [Customer]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchCustomers.first
    }
    
    func getAllMatchingCustomers(searchText: String = "", searchScope: String = "") -> [Customer] {
        var fetchPredicate: NSPredicate?
        var compoundPredicate = [NSPredicate]()
        
        if searchText.count > 2 {
            switch searchScope{
                case "name":
                    compoundPredicate.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
                case "phone":
                    compoundPredicate.append(NSPredicate(format: "phone = " + searchText))
                case "email":
                    compoundPredicate.append(NSPredicate(format: "email CONTAINS[cd] %@", searchText))
                default:
                    print("Invalid search scope")
            }
        }
        fetchPredicate = NSCompoundPredicate(type: .and, subpredicates: compoundPredicate)
        
        return fetchAllCustomers(predicate: fetchPredicate)
    }
    
    func getCustomerById(id: String) -> Customer? {
        let predicate = NSPredicate(format: "id = %@", id)
        return fetchCustomer(predicate: predicate)
    }
    
    func doesCustomerAlreadyExistByName(name: String) -> Bool {
        if !(name.isEmpty){
            let predicate = NSPredicate(format: "name ==[c] %@", name)
            let customer = fetchCustomer(predicate: predicate)
            if customer != nil {
                return true
            }
        }
        return false
    }
    
    func doesCustomerAlreadyExistByEmail(email: String) -> Bool {
        if !(email.isEmpty){
            let predicate = NSPredicate(format: "email ==[c] %@", email)
            let customer = fetchCustomer(predicate: predicate)
            if customer != nil {
                return true
            }
        }
        return false
    }
    
    func attemptNewCustomerCreation(name: String, phone: Int64, email: String) -> (Bool, String) {
        if name.count == 0 {
            return (false, "Provide a customer name.")
        }
        
        if doesCustomerAlreadyExistByEmail(email: email) {
            return (false, "Email already exists in system.")
        }
        
        if doesCustomerAlreadyExistByName(name: name) {
            if email.count == 0 {
                return (false, "Customer name already exists. Provide a unique email.")
            }
        }
        
        var newCustomer = customerSchema()
        newCustomer.name = name
        newCustomer.phone = phone
        newCustomer.email = email
        
        createNewCustomer(customer: newCustomer)
        return (true, newCustomer._id!)
    }
    
    func createNewCustomer(customer: customerSchema){
        customer.saveToCoreData()
    }
    
    func deleteCustomerById(customerId: String){
        if let customer = getCustomerById(id: customerId) {
            managedContext.delete(customer)
        }
    }

    func uploadCustomer(customer: Customer) -> Bool {
        return customerServer.uploadCustomerMO(customerMO: customer)
    }
    
    func deleteAllCustomers(){
        deleteAllRecords(entityName: "Customer")
    }
    
    func validCustomerNameUpdate(customerId: String, name: String) -> (Bool, String) {
        let predicate1 = NSPredicate(format: "name ==[c] %@", name)
        let predicate2 = NSPredicate(format: "id != %@", customerId)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        var resultSuccess: Bool = false
        var resultMessage: String = "Could not update"
        
        if let customer = getCustomerById(id: customerId){
            if !(name.isEmpty){
                if let matchingCustomer = fetchCustomer(predicate: predicate) {
                    if !(customer.email?.isEmpty ?? true) {
                        resultSuccess = true
                    } else {
                        resultSuccess = false
                        resultMessage = "There is another customer with a matching name. Enter a unique email first."
                    }
                } else {
                    resultSuccess = true
                }
            } else {
                resultSuccess = false
                resultMessage = "Customer name can not be empty"
            }
        } else {
            resultSuccess = false
            resultMessage = "Customer not found"
        }
        
        return (resultSuccess, resultMessage)
    }
    
    func validCustomerEmailUpdate(customerId: String, email: String) -> (Bool, String) {
        let predicate1 = NSPredicate(format: "email ==[c] %@", email)
        let predicate2 = NSPredicate(format: "id != %@", customerId)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        
        var resultSuccess: Bool = false
        var resultMessage: String = "Could not update"
        
        if let customer = getCustomerById(id: customerId){
            if !(email.isEmpty){
                if let matchingCustomer = fetchCustomer(predicate: predicate) {
                    resultSuccess = false
                    resultMessage = "Customer with matching email already exists"
                } else {
                    resultSuccess = true
                }
            } else {
                resultSuccess = false
                resultMessage = "Customer email can not be empty"
            }
        } else {
            resultSuccess = false
            resultMessage = "Customer not found"
        }
        
        return (resultSuccess, resultMessage)
    }
    
    func updateCustomerName(customerId: String, name: String) -> (Bool, String){
        let (resultSuccess, resultMessage) = validCustomerNameUpdate(customerId: customerId, name: name)
        if resultSuccess == true {
            if let customer = getCustomerById(id: customerId){
                customer.name = name
                self.saveChangesToContext()
                return (resultSuccess, resultMessage)
            } else {
                return (false, "Could not find customer")
            }
        } else {
            return (resultSuccess, resultMessage)
        }
    }
    
    func updateCustomerPhone(customerId: String, phone: Int64){
        if let customer = getCustomerById(id: customerId){
            customer.phone = phone
            self.saveChangesToContext()
        }
    }
    
    func updateCustomerEmail(customerId: String, email: String) -> (Bool, String){
        let (resultSuccess, resultMessage) = validCustomerEmailUpdate(customerId: customerId, email: email)
        if resultSuccess == true {
            if let customer = getCustomerById(id: customerId){
                customer.email = email
                self.saveChangesToContext()
                return (resultSuccess, resultMessage)
            } else {
                return (false, "Could not find customer")
            }
        } else {
            return (resultSuccess, resultMessage)
        }
    }
    
    func updateCustomerNotes(customerId: String, notes: String){
        if let customer = getCustomerById(id: customerId){
            customer.notes = notes
            self.saveChangesToContext()
        }
    }
    
    
}
