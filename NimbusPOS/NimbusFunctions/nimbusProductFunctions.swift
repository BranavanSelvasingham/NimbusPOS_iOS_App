
//  nimbusProductFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-10.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusProductFunctions: NimbusBase {    
    override init (master: NimbusFramework?){
        super.init(master: master)
    }
    
    func syncProductsServerDataToLocal(){
        let productsOnServer = ProductAPIs()
        productsOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        let productServer = ProductAPIs()
        productServer.processChangeLog(log: log)
    }
    
    func getProductsFiltered(categoryFilter: String = "") -> [Product]{
        var fetchProducts = [NSManagedObject]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
        fetchRequest.returnsObjectsAsFaults = false
        
        if categoryFilter == "" || categoryFilter == "All" {
            fetchRequest.predicate = NSPredicate(format: "status = %@", "Active")
        } else {
            fetchRequest.predicate = NSPredicate(format: "status = %@ AND primaryCategory = %@", "Active", categoryFilter)
        }
        
        do {
            fetchProducts = try managedContext.fetch(fetchRequest) as! [Product]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchProducts as! [Product]
    }
    
    func getProductById(productId: String, status: String = "Active") -> Product?{
        var fetchProducts = [Product]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchRequest.predicate = NSPredicate(format: "status = %@ AND id = %@", status, productId)
        
        do {
            fetchProducts = try managedContext.fetch(fetchRequest) as! [Product]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchProducts.first
    }
    
    func getProductsSorted(filteredProducts: [Product]) -> [Product] {
        var sortedProducts: [Product] = []
        var allCategories: [ProductCategory] = NIMBUS.Categories?.getCategoriesSorted() ?? []
        
        allCategories.forEach{category in
            var allCategoryProducts: [Product] = filteredProducts.filter({$0.primaryCategory == category.name})
            allCategoryProducts.sort(by: {$0.sortPosition < $1.sortPosition})
            sortedProducts.append(contentsOf: allCategoryProducts)
        }
        
        var nonCategoryProducts: [Product] = filteredProducts.filter({$0.primaryCategory == nil || $0.primaryCategory == ""})
        nonCategoryProducts.sort(by: {$0.sortPosition < $1.sortPosition})
        sortedProducts.append(contentsOf: nonCategoryProducts)
        
//        sortedProducts = sortedProducts.sorted(by: {$0.sortPosition < $1.sortPosition})
        
        return sortedProducts as! [Product]
    }
    
    func convertManagedProductsToStructs(managedProducts: [Product]) -> [productSchema] {
        var structProducts = [productSchema]()
        managedProducts.forEach { product in 
            structProducts.append(product.convertToStruct())
        }
        return structProducts
    }
    
    func getProductsGrouped(sortedProducts: [productSchema]) -> [productSchema] {
        var groupedProducts = [productSchema]()
        
        sortedProducts.forEach {product in
            if let groupName = product.group {
//                print("product is part of group: \(groupName)")
                if let existingGroupObj = groupedProducts.first(where: { $0._id == groupName}) {
//                    print("group already created")
                    if let prodIndex = groupedProducts.index(where: { $0._id == groupName}) {
//                        print("appending at index \(prodIndex)")
                        (groupedProducts[prodIndex].productsUnderGroup!).append(product)
                    } else {
//                        print("unable to find existing ")
                    }
                } else {
                    var groupObj = product
                    groupObj.name = groupName
                    groupObj._id = groupName   //******* <- id of group object is group name
                    groupObj.isGroupObject = true
                    groupObj.productsUnderGroup = [product]
                    
                    groupedProducts.append(groupObj)
                }
            } else {
                groupedProducts.append(product)
            }
        }
        return groupedProducts
    }
    
    func getProductCollectionViewData(categoryFilter: String = "") -> [productSchema]{
        let filteredProducts = getProductsFiltered(categoryFilter: categoryFilter)
        
        let sortedProducts = getProductsSorted(filteredProducts: filteredProducts)
        
        let sortedProductsAsStructs = convertManagedProductsToStructs(managedProducts: sortedProducts)
    
        let groupedProducts = getProductsGrouped(sortedProducts: sortedProductsAsStructs)
        
        return groupedProducts
    }
    
    func getProductsByCategory(categoryFilter: String) -> [productSchema] {
        let filteredProducts = getProductsFiltered(categoryFilter: categoryFilter)
        return convertManagedProductsToStructs(managedProducts: filteredProducts)
    }
    
    func getProductSizeLabels() -> [Business_SetProductSizes]{
        var fetchBusinessSizes = [Business_SetProductSizes]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Business_SetProductSizes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            fetchBusinessSizes = try managedContext.fetch(fetchRequest) as! [Business_SetProductSizes]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let sortedBusinessSizes = fetchBusinessSizes.sorted(by: {$0.order < $1.order})
        return sortedBusinessSizes
    }
    
    func getSizeForCode (code: String = "") -> Business_SetProductSizes? {
        let sizeLabels = getProductSizeLabels()
        let labels = sizeLabels.filter{$0.code == code}
        return labels.first
    }
    
    func getLabelForCode (code: String) -> String {
        return getSizeForCode(code: code)?.label ?? code
    }
    
    func getSortPosition (code: String) -> Int16 {
        return getSizeForCode(code: code)?.order ?? 0
    }
    
    func deleteProduct(productId: String){
        if let doc = NIMBUS.Products?.getProductById(productId: productId){
            managedContext.delete(doc)
        }
    }
}
