//
//  customerAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class CustomerAPIs: APIs, SyncDownDocumentBatchDelegate {
    var collectionName = "Customers"
    
    override func getOneDocumentFromServer(documentId: String){
        let customerQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: customerQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.Customers?.deleteCustomerById(customerId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let customerQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: customerQuery, delegate: self, notificationMessage: "Loading Customers...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let customerList = convertJSONToCustomers(json: results)
        saveToCoreData(resultsList: customerList)
    }
    
    private func convertJSONToCustomers(json: [[String: Any]]) -> [customerSchema]{
        var resultsList = [customerSchema]()
        json.forEach { json in
            let customer = customerSchema(withJSONDataObject: json)
            resultsList.append(customer)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [customerSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Customer.entity().name ?? self.collectionName, syncComplete: true, message: "Customers saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadCustomerMO(customerMO: Customer) -> Bool {
        let customer: customerSchema = customerSchema(withManagedObject: customerMO)
        let uploadSuccess = uploadCustomer(customer: customer)
        return uploadSuccess
    }
    
    func uploadCustomer(customer: customerSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(customer)
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
    
    func deleteCustomerOnServer(customer: Customer){
        removeOneDocumentFromCollection(documentId: customer.id ?? "", collectionName: collectionName)
    }
    
}
