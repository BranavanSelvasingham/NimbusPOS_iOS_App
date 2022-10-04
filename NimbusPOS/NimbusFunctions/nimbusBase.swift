//
//  nimbusBase.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-10.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NimbusBase {
    var appDelegate: AppDelegate
    public var managedContext: NSManagedObjectContext
    var Nimbus: NimbusFramework?
    
    init (master: NimbusFramework?){
        if let master = master {
            Nimbus = master
        }
        self.appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func saveChangesToContext(){
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllRecords(entityName: String){
        let deleteFetch_Products = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest_Products = NSBatchDeleteRequest(fetchRequest: deleteFetch_Products)
        
        do
        {
            try managedContext.execute(deleteRequest_Products)
            try managedContext.save()
        }
        catch
        {
            print ("There was an error")
        }
    }
}
