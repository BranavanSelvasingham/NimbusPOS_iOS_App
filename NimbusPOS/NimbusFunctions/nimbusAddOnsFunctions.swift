//
//  nimbusAddOnsFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusAddOnsFunctions: NimbusBase {

    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    func syncProductAddOnServerDataToLocal(){
        let addOnServer = ProductAddOnAPIs()
        addOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        let addOnServer = ProductAddOnAPIs()
        addOnServer.processChangeLog(log: log)
    }
    
    func getAllAddOnsAndSubstitutions(withFilters: Bool = false,
                                      onlyActive: Bool = true,
                                      onlyAddOns: Bool = false,
                                      onlySubs: Bool = false,
                                      byAddOnIdSet: [String] = [],
                                      unassociatedAddOns: Bool = false,
                                      byAddOnId: String = "") -> [ProductAddOn]{
        
        var fetchAddOns = [ProductAddOn]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ProductAddOn")
        fetchRequest.returnsObjectsAsFaults = false
        
        if withFilters == true {
            var compoundPredicate = [NSPredicate]()
            if onlyActive {
                compoundPredicate.append(NSPredicate(format: "status = %@", "Active"))
            }
            
            if onlyAddOns {
                compoundPredicate.append(NSPredicate(format: "isSubstitution != %@", NSNumber(value: true)))
            } else if onlySubs {
                compoundPredicate.append(NSPredicate(format: "isSubstitution = %@", NSNumber(value: true)))
            }
            
            if !byAddOnIdSet.isEmpty {
                if unassociatedAddOns {
                    compoundPredicate.append(NSPredicate(format: "NOT (id IN %@)", byAddOnIdSet))
                } else {
                    compoundPredicate.append(NSPredicate(format: "id IN %@", byAddOnIdSet))
                }
            } else if !byAddOnId.isEmpty{
                compoundPredicate.append(NSPredicate(format: "id = %@", byAddOnId))
            }

            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: compoundPredicate)
        }
        
        do {
            fetchAddOns = try managedContext.fetch(fetchRequest) as! [ProductAddOn]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchAddOns
    }
    
    func isAddOnASubstitution(withAddOnId addOnId: String) -> Bool {
        let item = getAllAddOnsAndSubstitutions(withFilters: true,
                                                onlyActive: false,
                                                onlyAddOns: false,
                                                onlySubs: true,
                                                byAddOnId: addOnId)
        if let item = item.first {
            if item.isSubstitution == true {
                return true
            }
        }
        
        return false
    }
    
    func convertManagedAddOnsToStructs(managedAddOns: [ProductAddOn]) -> [productAddOnSchema] {
        var structAddOns = [productAddOnSchema]()
        managedAddOns.forEach { addOn in
            structAddOns.append(addOn.convertToStruct())
        }
        return structAddOns
    }
    
    func getAllAddOnsAsStructs(onlyActive: Bool = true, onlyAddOns: Bool = true, onlySubs: Bool = false) -> [productAddOnSchema]{
        let allAddOns = getAllAddOnsAndSubstitutions(withFilters: true,
                                                            onlyActive: onlyActive,
                                                            onlyAddOns: onlyAddOns,
                                                            onlySubs: onlySubs)
        
        return convertManagedAddOnsToStructs(managedAddOns: allAddOns)
    }
    
    func getProductAssociatedAddOnsAsStructs(onlyActive: Bool = true, productId: String = " ", onlyAddOns: Bool = true, onlySubs: Bool = false) -> [productAddOnSchema]{
        let product = NIMBUS.Products?.getProductById(productId: productId)
        
        var allAddOns = [ProductAddOn]()
        if let product = product {
            if let productAddOns = product.addOns as? [String]{
                if !productAddOns.isEmpty {
                    allAddOns = getAllAddOnsAndSubstitutions(withFilters: true,
                                                             onlyActive: onlyActive,
                                                             onlyAddOns: onlyAddOns,
                                                             onlySubs: onlySubs,
                                                             byAddOnIdSet: product.addOns as! [String])
                }
            }
        }
        
        return convertManagedAddOnsToStructs(managedAddOns: allAddOns)
    }
    
    func getProductUnassociatedAddOnsAsStructs(onlyActive: Bool = true, productId: String = " ", onlyAddOns: Bool = true, onlySubs: Bool = false) -> [productAddOnSchema]{
        let product = NIMBUS.Products?.getProductById(productId: productId)
        
        var allAddOns = [ProductAddOn]()
        
        if let product = product {
            if let productAddOns = product.addOns as? [String]{
                allAddOns = getAllAddOnsAndSubstitutions(withFilters: true,
                                                             onlyActive: onlyActive,
                                                             onlyAddOns: onlyAddOns,
                                                             onlySubs: onlySubs,
                                                             byAddOnIdSet: product.addOns as! [String],
                                                             unassociatedAddOns: true)
            
            }
        }
        
        return convertManagedAddOnsToStructs(managedAddOns: allAddOns)
    }

    func getAddOnAsStruct(byAddOnId: String, onlyActive: Bool = true, onlyAddOns: Bool = true, onlySubs: Bool = false) -> productAddOnSchema? {
        let allAddOns = getAllAddOnsAndSubstitutions(withFilters: true,
                                                     onlyActive: onlyActive,
                                                     onlyAddOns: onlyAddOns,
                                                     onlySubs: onlySubs,
                                                     byAddOnId: byAddOnId)
        
        let addOnAsStruct = allAddOns.first?.convertToStruct()
        
        return addOnAsStruct
    }
    
    func getAddOnById(addOnId: String) -> ProductAddOn? {
        var fetchAddOns = [ProductAddOn]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ProductAddOn")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", addOnId)
        
        do {
            fetchAddOns = try managedContext.fetch(fetchRequest) as! [ProductAddOn]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchAddOns.first
    }
    
    func deleteProductAddOns(addOnId: String){
        if let doc = NIMBUS.AddOns?.getAddOnById(addOnId: addOnId){
            managedContext.delete(doc)
        }
    }
}
