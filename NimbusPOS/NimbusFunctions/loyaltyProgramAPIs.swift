//
//  loyaltyProgramAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class LoyaltyProgramAPIs: APIs, SyncDownDocumentBatchDelegate {
    var collectionName = "LoyaltyPrograms"
    
    override func getOneDocumentFromServer(documentId: String){
        let loyaltyProgramQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: loyaltyProgramQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.LoyaltyPrograms?.deleteLoyaltyProgramById(programId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let programQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: programQuery, delegate: self, notificationMessage: "Loading Loyalty Programs...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let programList = convertJSONToProgram(json: results)
        saveToCoreData(resultsList: programList)
    }
    
    private func convertJSONToProgram(json: [[String: Any]]) -> [loyaltyProgramSchema]{
        var resultsList = [loyaltyProgramSchema]()
        json.forEach { json in
            let program = loyaltyProgramSchema(withJSONDataObject: json)
            resultsList.append(program)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [loyaltyProgramSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: LoyaltyProgram.entity().name ?? self.collectionName, syncComplete: true, message: "Loyalty programs saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadProgramMO(programMO: LoyaltyProgram) -> Bool {
        let program: loyaltyProgramSchema = loyaltyProgramSchema(withManagedObject: programMO)
        let uploadSuccess = uploadProgram(program: program)
        return uploadSuccess
    }
    
    func uploadProgram(program: loyaltyProgramSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(program)
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
    
    func deleteProgramOnServer(program: LoyaltyProgram){
        removeOneDocumentFromCollection(documentId: program.id ?? "", collectionName: collectionName)
    }
    
}
