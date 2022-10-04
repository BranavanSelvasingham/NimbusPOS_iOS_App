//
//  SyncDownDocumentBatchJob.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-06-10.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

protocol SyncDownDocumentBatchDelegate {
    func syncDownDocumentResultsReady(documentResults: [[String: Any]])
}


class SyncDownDocumentBatch: APIs{
    var documentProgress: Int = 0 {
        didSet {
            if documentProgress > 0 {
                if documentProgress >= totalDocuments {
                    isComplete = true
                    isSyncing = false
                    let syncProgressNotication: notificationDocumentListSyncObject = notificationDocumentListSyncObject(totalDocuments: totalDocuments, currentDocumentProgress: documentProgress, collectionName: syncQueryParameters.collectionName, syncComplete: true, message: notificationMessage)
                    NotificationCenter.default.post(name: .onResultsFromDocumentIdListCall, object: syncProgressNotication)
                } else {
                    let syncProgressNotication: notificationDocumentListSyncObject = notificationDocumentListSyncObject(totalDocuments: totalDocuments, currentDocumentProgress: documentProgress, collectionName: syncQueryParameters.collectionName, syncComplete: false, message: notificationMessage)
                    NotificationCenter.default.post(name: .onResultsFromDocumentIdListCall, object: syncProgressNotication)
                }
            }
        }
    }
    var totalDocuments: Int = 0
    var documentResults: [[String: Any]] = []
    let syncQueryParameters: queryParams
    var isSyncing: Bool = false
    var isComplete: Bool = false {
        didSet {
            if isComplete == true {
                delegate.syncDownDocumentResultsReady(documentResults: documentResults)
            }
        }
    }
    let delegate: SyncDownDocumentBatchDelegate
    let notificationMessage: String
    
    init(queryParameters: queryParams, delegate: SyncDownDocumentBatchDelegate, notificationMessage: String) {
        self.syncQueryParameters = queryParameters
        self.delegate = delegate
        self.notificationMessage = notificationMessage
    }
    
    func startSync(){
        isSyncing = true
        queryForDocumentIdList(queryParameters: syncQueryParameters)
    }
    
    func queryForDocumentIdList(queryParameters: queryParams){
        let postData = try? JSONSerialization.data(withJSONObject: queryParameters.json, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: queryCollectionURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: timeOut)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.httpResponse = (response as? HTTPURLResponse)!
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let queryResults = responseJSON as? [[String: String]] {
                    self.syncDocumentBatch(results: queryResults)
                }
            }
        })
        
        dataTask.resume()
    }
    
    private func syncDocumentBatch(results: [[String: String]]){
        totalDocuments = results.count
        
        if totalDocuments == 0 {
            isComplete = true
        }
        
        let syncNotication: notificationDocumentListSyncObject = notificationDocumentListSyncObject(totalDocuments: totalDocuments, currentDocumentProgress: documentProgress, collectionName: syncQueryParameters.collectionName, syncComplete: false, message: notificationMessage)
        NotificationCenter.default.post(name: .onResultsFromDocumentIdListCall, object: syncNotication)
        
        results.forEach{document in
            let documentId: String = document["_id"] ?? " "
            getOneDocumentAndStoreToCache(documentId: documentId)
        }
        
        if results.count == 0 {
            let syncNotication: notificationDocumentListSyncObject = notificationDocumentListSyncObject(totalDocuments: totalDocuments, currentDocumentProgress: documentProgress, collectionName: syncQueryParameters.collectionName, syncComplete: true, message: notificationMessage)
            NotificationCenter.default.post(name: .onResultsFromDocumentIdListCall, object: syncNotication)
        }
    }
    
    private func getOneDocumentAndStoreToCache(documentId: String){
        let orderQuery = queryParams(collectionName: syncQueryParameters.collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        queryForDocumentAsync(queryParameters: orderQuery)
    }
    
    private func queryForDocumentAsync(queryParameters: queryParams){
        let postData = try? JSONSerialization.data(withJSONObject: queryParameters.json, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: queryCollectionURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: timeOut)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.httpResponse = (response as? HTTPURLResponse)!
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let queryResults = responseJSON as? [[String: Any]] {
                    self.storeDocumentToCache(results: queryResults)
                }
            }
        })
        
        dataTask.resume()
    }
    
    private func storeDocumentToCache(results: [[String: Any]]){
        if let document = results.first {
            documentResults.append(document)
        }
        documentProgress += 1
    }
}
