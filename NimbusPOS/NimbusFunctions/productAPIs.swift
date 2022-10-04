//
//  nimbusProductAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-03.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

protocol ProductAPIDelegate {
    func saveToCoreDataCompleted()
}

class ProductAPIs: APIs, SyncDownDocumentBatchDelegate {
    let collectionName: String = "Products"
    
    override func getOneDocumentFromServer(documentId: String){
        let productQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: productQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.Products?.deleteProduct(productId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let productQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: productQuery, delegate: self, notificationMessage: "Loading Products...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let productList = convertJSONToProduct(json: results)
        saveToCoreData(resultsList: productList)
    }
    
    private func convertJSONToProduct(json: [[String: Any]]) -> [productSchema]{
        var resultsList = [productSchema]()
        json.forEach { json in
            let product = productSchema(withJSONDataObject: json)
            resultsList.append(product)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [productSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Product.entity().name ?? self.collectionName, syncComplete: true, message: "Products saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
}
