//
//  employeeAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class EmployeeAPIs: APIs, SyncDownDocumentBatchDelegate {
    var collectionName = "Employees"
    
    override func getOneDocumentFromServer(documentId: String){
        let employeeQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: employeeQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.Employees?.deleteEmployeeById(employeeId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let employeeQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: employeeQuery, delegate: self, notificationMessage: "Loading Employees...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let employeeList = convertJSONToEmployee(json: results)
        saveToCoreData(resultsList: employeeList)
    }
    
    private func convertJSONToEmployee(json: [[String: Any]]) -> [employeeSchema]{
        var resultsList = [employeeSchema]()
        json.forEach { json in
            let employee = employeeSchema(withJSONDataObject: json)
            resultsList.append(employee)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [employeeSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Employee.entity().name ?? self.collectionName, syncComplete: true, message: "Employees saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadEmployeeMO(employeeMO: Employee) -> Bool {
        let employee: employeeSchema = employeeSchema(withManagedObject: employeeMO)
        let uploadSuccess = uploadEmployee(employee: employee)
        return uploadSuccess
    }
    
    func uploadEmployee(employee: employeeSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(employee)
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
    
    func deleteEmployeeOnServer(employee: Employee){
        removeOneDocumentFromCollection(documentId: employee.id ?? "", collectionName: collectionName)
    }
    
}
