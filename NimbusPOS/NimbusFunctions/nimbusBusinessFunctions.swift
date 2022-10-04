//
//  nimbusBusinessFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData

class nimbusBusinessFunctions: NimbusBase, BusinessAPIDelegate {
    let businessOnServer = BusinessAPIs()
    var businessId: String {
        get {
            return UserDefaults.standard.string(forKey: "businessId") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "businessId")
            UserDefaults.standard.synchronize()
        }
    }
    
    override init(master: NimbusFramework?){
        super.init(master: master)
        
        businessOnServer.businessDelegate = self
    }
    
    func getBusinessId() -> String {
        return businessId
    }
    
    func syncBusinessServerDataToLocal(){
        businessOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        businessOnServer.processChangeLog(log: log)
    }
    
    func getBusiness() -> Business? {
        var fetchedBusiness = [Business]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Business")
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.predicate = NSPredicate(format: "id = %@", businessId)
        
        do {
            fetchedBusiness = try managedContext.fetch(fetchRequest) as! [Business]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return fetchedBusiness.first
    }
    
    func getBusinessName() -> String {
        let business = getBusiness()
        return business?.name ?? ""
    }
    
    func saveBusinessInfoToApp(){
        if let business = getBusiness(){
            UserDefaults.standard.set(business.id, forKey: "businessId")
            UserDefaults.standard.synchronize()
        }
    }
    
    func deleteAllBusinesses(){
        deleteAllRecords(entityName: "Business")
    }
    
    func saveToCoreDataCompleted() {
        saveBusinessInfoToApp()
    }
}
