//
//  productCategoryAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-03.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class ProductCategoryAPIs: APIs, SyncDownDocumentBatchDelegate {
    let collectionName: String = "ProductCategories"
    
    override func getOneDocumentFromServer(documentId: String){
        let productQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: productQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.Categories?.deleteProductCategory(categoryId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let categoryQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: categoryQuery, delegate: self, notificationMessage: "Loading Product Categories...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let categoryList = convertJSONToCategories(json: results)
        saveToCoreData(resultsList: categoryList)
    }
    
    private func convertJSONToCategories(json: [[String: Any]]) -> [productCategorySchema]{
        var resultsList = [productCategorySchema]()
        json.forEach { json in
            let product = productCategorySchema(withJSONDataObject: json)
            resultsList.append(product)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [productCategorySchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: ProductCategory.entity().name ?? self.collectionName, syncComplete: true, message: "Product categories saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
}
