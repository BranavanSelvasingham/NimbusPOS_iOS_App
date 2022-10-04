//
//  nimbusCategoriesFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-11.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusCategoriesFunctions: NimbusBase {
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    func syncProductCategoryServerDataToLocal(){
        let categoryServer = ProductCategoryAPIs()
        categoryServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        let categoryServer = ProductCategoryAPIs()
        categoryServer.processChangeLog(log: log)
    }
    
    func getCategoryById(categoryId: String) -> ProductCategory? {
        var fetchCategories = [ProductCategory]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ProductCategory")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", categoryId)
        
        do {
            fetchCategories = try managedContext.fetch(fetchRequest) as! [ProductCategory]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchCategories.first
    }
    
    func getCategoriesSorted() -> [ProductCategory]{
        var fetchCategories = [ProductCategory]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ProductCategory")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            fetchCategories = try managedContext.fetch(fetchRequest) as! [ProductCategory]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        var sortedCategories = fetchCategories
        sortedCategories = sortedCategories.sorted(by: {$0.sortPosition < $1.sortPosition})
        
        return sortedCategories
    }
    
    func deleteProductCategory(categoryId: String){
        if let doc = NIMBUS.Categories?.getCategoryById(categoryId: categoryId){
            managedContext.delete(doc)
        }
    }
}
