//
//  productAddOnAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class ProductAddOnAPIs: APIs, SyncDownDocumentBatchDelegate {
    let collectionName: String = "ProductAddons"
    
    override func getOneDocumentFromServer(documentId: String){
        let productAddOnQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: productAddOnQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.AddOns?.deleteProductAddOns(addOnId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let addOnQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: addOnQuery, delegate: self, notificationMessage: "Loading Product AddOns...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let addOnList = convertJSONToAddOns(json: results)
        saveToCoreData(resultsList: addOnList)
    }
    
    private func convertJSONToAddOns(json: [[String: Any]]) -> [productAddOnSchema]{
        var resultsList = [productAddOnSchema]()
        json.forEach { json in
            let addOn = productAddOnSchema(withJSONDataObject: json)
            resultsList.append(addOn)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [productAddOnSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: ProductAddOn.entity().name ?? self.collectionName, syncComplete: true, message: "Product AddOns saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
}
