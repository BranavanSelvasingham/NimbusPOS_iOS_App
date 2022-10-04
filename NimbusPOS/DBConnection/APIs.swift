//
//  apiDirectory.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-27.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol APIsProtocol {
    func resultsFromQueryCollectionCall(results: [[String: Any]])
    
    func resultsFromCreateDocumentCall(results: APIs.createResponse)
    
    func resultsFromDocumentIdList(results: [[String: String]])
    
    func getOneDocumentFromServer(documentId: String)
    
    func deleteOneDocumentLocally(documentId: String)
}

class APIs{
    let baseURL: String

    let queryCollectionURL: String
    let createDocumentURL: String
    let upsertDocumentURL: String
    let udpateDocumentURL: String
    let removeDocumentURL: String
    
    let headers: [String: String?]
    var httpResponse: HTTPURLResponse?
    let timeOut: TimeInterval = 120
    
    var authenticationToken: String {
        get {
            return UserDefaults.standard.string(forKey: "token") ?? ""
        }
    }
    
    init(workOffLocalServer: Bool = false ) {
        let localURL = "http://localhost:8080"
        let apiURL = "https://nimbusapi-dot-nimbuspos-apis-core.appspot.com"
        
        if workOffLocalServer {
            baseURL = localURL
        } else {
            baseURL = apiURL
        }
        
        queryCollectionURL = "\(baseURL)/api/queryCollection"
        createDocumentURL = "\(baseURL)/api/createNewDocument"
        upsertDocumentURL = "\(baseURL)/api/upsertOneDocument"
        udpateDocumentURL = "\(baseURL)/api/updateOneDocument"
        removeDocumentURL = "\(baseURL)/api/deleteOneDocument"
        headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache"
        ]
    }
    
    struct genericResponse {
        let success: Bool
        let message: String
        let results: [[String: Any]]
        
        init(json: [String: Any]){
            self.success = (json["success"] as? Bool) ?? false
            self.message = (json["message"] as? String) ?? ""
            self.results = (json["results"] as? [[String: Any]]) ?? []
        }
    }
    
    struct createResponse {
        let _id: String?
        let message: String?
        let success: Bool
        
        init(json: [String: Any]){
            self._id = (json["_id"] as? String) ?? ""
            self.message = (json["message"] as? String) ?? ""
            self.success = (json["success"] as? Bool) ?? false
        }
    }
    
    func queryCollection(queryParameters: queryParams){
        let postData = try? JSONSerialization.data(withJSONObject: queryParameters.json, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: queryCollectionURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: timeOut)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.httpResponse = (response as? HTTPURLResponse)!
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let queryResults = responseJSON as? [[String: Any]] {
                    self.resultsFromQueryCollectionCall(results: queryResults)
                }
            }
            semaphore.signal()
        })
        
        dataTask.resume()
        semaphore.wait()
    }
    
    func queryForCollectionAsync(queryParameters: queryParams){
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
                    self.resultsFromQueryCollectionCall(results: queryResults)
                }
            }
        })
        
        dataTask.resume()
    }
    
    func createDocumentInCollection(createParameters: createParams) -> Bool {
        var success: Bool = false
        let postData = try? JSONSerialization.data(withJSONObject: createParameters.json, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: createDocumentURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: timeOut)
        
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.httpResponse = (response as? HTTPURLResponse)!
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let responseData = createResponse(json: responseJSON)
                    success = true
                } else {
                    print("error tryig to convert json")
                }
            }
            semaphore.signal()
        })
        
        dataTask.resume()
        semaphore.wait()
        
        return success
    }
    
    func removeOneDocumentFromCollection(documentId: String, collectionName: String){
        let parameters = [
            "collectionName": collectionName,
            "documentId": documentId
            ] as [String : Any]
        
        let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: removeDocumentURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: timeOut)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.httpResponse = (response as? HTTPURLResponse)!
            }
        })
        
        dataTask.resume()
    }
    
    func upsertDocumentInCollection(upsertParameters: upsertParams) -> Bool {
        var success: Bool = false
        let postData = try? JSONSerialization.data(withJSONObject: upsertParameters.json, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: upsertDocumentURL)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: timeOut)
        
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                self.httpResponse = (response as? HTTPURLResponse)!
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let responseData = createResponse(json: responseJSON)
                    success = true
                } else {
                    print("error tryig to convert json")
                }
            }
            semaphore.signal()
        })
        
        dataTask.resume()
        semaphore.wait()
        
        return success
    }
    
    func resultsFromQueryCollectionCall(results: [[String: Any]]){
        //override this
    }
    
    func resultsFromCreateDocumentCall(results: createResponse){
        //override this
    }
    
    func resultsFromDocumentIdList(results: [[String: String]]){
        //override this
    }
    
    func processChangeLog(log: serverChangeLog){
        let documentId = log.objectId ?? " "
        if log.objectChangeType == "i" || log.objectChangeType == "u" {
            getOneDocumentFromServer(documentId: documentId)
        } else if log.objectChangeType == "d" {
            deleteOneDocumentLocally(documentId: documentId)
        }
    }
    
    func getOneDocumentFromServer(documentId: String){
        //override this
    }
    
    func deleteOneDocumentLocally(documentId: String){
        //override this
    }
}
