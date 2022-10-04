//
//  businessAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

protocol BusinessAPIDelegate {
    func saveToCoreDataCompleted()
}

class BusinessAPIs: APIs, SyncDownDocumentBatchDelegate {
    let collectionName = "Businesses"
    var businessDelegate: BusinessAPIDelegate?
    
    override func getOneDocumentFromServer(documentId: String){
        let businessQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: businessQuery)
    }
    
    func getAllDocumentsFromServer(){
        let businessQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: businessQuery, delegate: self, notificationMessage: "Loading Business Info...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let businessList = convertJSONToBusiness(json: results)
        saveToCoreData(resultsList: businessList)
    }
    
    private func convertJSONToBusiness(json: [[String: Any]]) -> [businessSchema]{
        var resultsList = [businessSchema]()
        json.forEach { json in
            let business = businessSchema(withJSONDataObject: json)
            resultsList.append(business)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [businessSchema]){
        let business = resultsList.first
        if let businessId = business?._id{
            NIMBUS.Business?.businessId = businessId
            business?.saveToCoreData(enableChangeLog: false)
            businessDelegate?.saveToCoreDataCompleted()
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Business.entity().name ?? self.collectionName, syncComplete: true, message: "Business saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
}
