//
//  emplyeeHourAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class EmployeeHourAPIs: APIs, SyncDownDocumentBatchDelegate {
    var collectionName = "EmployeeHours"
    
    override func getOneDocumentFromServer(documentId: String){
        let employeeHourQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: employeeHourQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.EmployeeHours?.deleteEmployeeHourEntryById(hourId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let hourQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: hourQuery, delegate: self, notificationMessage: "Loading Employee Hours...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let hoursList = convertJSONToEmployeeHour(json: results)
        saveToCoreData(resultsList: hoursList)
    }
    
    private func convertJSONToEmployeeHour(json: [[String: Any]]) -> [employeeHoursSchema]{
        var resultsList = [employeeHoursSchema]()
        json.forEach { json in
            let hour = employeeHoursSchema(withJSONDataObject: json)
            resultsList.append(hour)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [employeeHoursSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: EmployeeHours.entity().name ?? self.collectionName, syncComplete: true, message: "Employee hours saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadEmployeeHourMO(employeeHourMO: EmployeeHours) -> Bool {
        let hour: employeeHoursSchema = employeeHoursSchema(withManagedObject: employeeHourMO)
        let uploadSuccess = uploadEmployeeHour(hour: hour)
        return uploadSuccess
    }
    
    func uploadEmployeeHour(hour: employeeHoursSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(hour)
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
    
    func deleteEmployeeHourOnServer(employeeHour: EmployeeHours){
        removeOneDocumentFromCollection(documentId: employeeHour.id ?? "", collectionName: collectionName)
    }
    
}
