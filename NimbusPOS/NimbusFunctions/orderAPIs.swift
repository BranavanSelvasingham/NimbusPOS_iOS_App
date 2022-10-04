//
//  orderAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData

class OrderAPIs: APIs, SyncDownDocumentBatchDelegate {
    let collectionName: String = "Orders"
    
    override func getOneDocumentFromServer(documentId: String){
        let orderQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: orderQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.OrderManagement?.deleteOrder(orderId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let orderQuery = queryParams(collectionName: collectionName)
        self.queryForCollectionAsync(queryParameters: orderQuery)
    }
    
    func getAllLocalHistoryOrders(){
        let orderHistoryLimit: Int = NIMBUS.Data?.localOrderHistoryLimit ?? 7
        let syncOrdersAsOfDate: Date = Date().startOfDay.addingTimeInterval(-TimeInterval(1*60*60*24*orderHistoryLimit))
        let locationId: String = NIMBUS.Location?.getLocationId() ?? " "
        
        let orderQuery = queryParams(collectionName: collectionName, findParams: ["locationId": locationId, "createdAt": ["$gt": syncOrdersAsOfDate.convertToISOString()]], limit: 10000, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: orderQuery, delegate: self, notificationMessage: "Loading Orders...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let orderList = convertJSONToOrders(json: results)
        saveToCoreData(resultsList: orderList)
    }
    
    private func convertJSONToOrders(json: [[String: Any]]) -> [orderSchema]{
        var resultsList = [orderSchema]()
        json.forEach { json in
            let order = orderSchema(withJSONDataObject: json)
            resultsList.append(order)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [orderSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Order.entity().name ?? self.collectionName, syncComplete: true, message: "Orders saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadOrder(order: orderSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(order)
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
    
    func uploadOrder(orderMO: Order) -> Bool {
        let newOrder: orderSchema = orderSchema(withManagedObject: orderMO)
        let uploadSuccess = uploadOrder(order: newOrder)
        return uploadSuccess
    }
    
}
