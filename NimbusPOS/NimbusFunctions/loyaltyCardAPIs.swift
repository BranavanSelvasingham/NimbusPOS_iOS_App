//
//  loyaltyCardAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class LoyaltyCardAPIs: APIs, SyncDownDocumentBatchDelegate {
    var collectionName = "LoyaltyCards"
    
    override func getOneDocumentFromServer(documentId: String){
        let loyaltyCardQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: loyaltyCardQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.LoyaltyCards?.deleteLoyaltyCardById(cardId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let cardQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: cardQuery, delegate: self, notificationMessage: "Loading Loyalty Cards...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let cardList = convertJSONToCards(json: results)
        saveToCoreData(resultsList: cardList)
    }
    
    private func convertJSONToCards(json: [[String: Any]]) -> [loyaltyCardSchema]{
        var resultsList = [loyaltyCardSchema]()
        json.forEach { json in
            let card = loyaltyCardSchema(withJSONDataObject: json)
            resultsList.append(card)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [loyaltyCardSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: LoyaltyCard.entity().name ?? self.collectionName, syncComplete: true, message: "Loyalty cards saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadCardMO(cardMO: LoyaltyCard) -> Bool {
        let card: loyaltyCardSchema = loyaltyCardSchema(withManagedObject: cardMO)
        let uploadSuccess = uploadCard(card: card)
        return uploadSuccess
    }
    
    func uploadCard(card: loyaltyCardSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(card)
        if let data = jsonOrder {
            do {
                serialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            } catch {
                print("Could not convert data to json", error)
            }
            
            let upsertParameters = upsertParams(collectionName: collectionName, newDocument: serialized)
            uploadSuccess = upsertDocumentInCollection(upsertParameters: upsertParameters)
        }
        
        return uploadSuccess
    }
    
    func deleteCardOnServer(card: LoyaltyCard){
        removeOneDocumentFromCollection(documentId: card.id ?? "", collectionName: collectionName)
    }
    
}
