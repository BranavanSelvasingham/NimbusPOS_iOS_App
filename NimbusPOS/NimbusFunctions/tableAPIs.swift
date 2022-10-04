//
//  tableAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class TableAPIs: APIs, SyncDownDocumentBatchDelegate {
    var collectionName = "Tables"
    
    override func getOneDocumentFromServer(documentId: String){
        let tableQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: tableQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.Tables?.deleteTableById(tableId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let tableQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: tableQuery, delegate: self, notificationMessage: "Loading Tables...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let tableList = convertJSONToTable(json: results)
        saveToCoreData(resultsList: tableList)
    }
    
    private func convertJSONToTable(json: [[String: Any]]) -> [tableSchema]{
        var resultsList = [tableSchema]()
        json.forEach { json in
            let table = tableSchema(withJSONDataObject: json)
            resultsList.append(table)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [tableSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Table.entity().name ?? self.collectionName, syncComplete: true, message: "Tables saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadTableMO(tableMO: Table) -> Bool {
        let table: tableSchema = tableSchema(withManagedObject: tableMO)
        let uploadSuccess = uploadTable(table: table)
        return uploadSuccess
    }
    
    func uploadTable(table: tableSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(table)
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
    
    func deleteTableOnServer(table: Table){
        removeOneDocumentFromCollection(documentId: table.id ?? "", collectionName: collectionName)
    }
    
}
