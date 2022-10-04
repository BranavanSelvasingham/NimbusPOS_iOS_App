//
//  locationAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class LocationAPIs: APIs, SyncDownDocumentBatchDelegate {
    let collectionName = "Locations"
    var firstRun: Bool = true
    
    override func getOneDocumentFromServer(documentId: String){
        let locationQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: locationQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
//        NIMBUS.Products?.deleteProduct(productId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let locationQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: locationQuery, delegate: self, notificationMessage: "Loading Locations...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let locationList = convertJSONToLocation(json: results)
        saveToCoreData(resultsList: locationList)
    }
    
    private func convertJSONToLocation(json: [[String: Any]]) -> [locationSchema]{
        var resultsList = [locationSchema]()
        json.forEach { json in
            let location = locationSchema(withJSONDataObject: json)
            resultsList.append(location)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [locationSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Location.entity().name ?? self.collectionName, syncComplete: true, message: "Locations saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
}
