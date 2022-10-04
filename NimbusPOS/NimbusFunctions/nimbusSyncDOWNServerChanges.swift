//
//  nimbusSyncDOWNServerChanges.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-01.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import NotificationCenter

class nimbusSyncDOWNServerChanges: APIs {
    var fetchedInsertLogs = [serverChangeLog](){
        didSet {
            newLogsFetched(logs: fetchedInsertLogs)
        }
    }
    
    var fetchedUpdateLogs = [serverChangeLog](){
        didSet {
            newLogsFetched(logs: fetchedUpdateLogs)
        }
    }
    
    var fetchedDeleteLogs = [serverChangeLog](){
        didSet {
            newLogsFetched(logs: fetchedDeleteLogs)
        }
    }
    
    var lastSuccessfulSyncDOWN: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastSuccessfulSyncDOWN") as? Date ?? nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastSuccessfulSyncDOWN")
            UserDefaults.standard.synchronize()
        }
    }
    
    var changeLogPaths = changeLogAPIPaths()
    
    struct changeLogAPIPaths {
        let baseSubRoute = "/api/changeLog"
        let getUpdates: String
        let getInserts: String
        let getDeletes: String
        
        init () {
            let basePaths = APIs()
            getUpdates = basePaths.baseURL + baseSubRoute + "/getUpdates"
            getInserts = basePaths.baseURL + baseSubRoute +  "/getInserts"
            getDeletes = basePaths.baseURL + baseSubRoute + "/getDeletes"
        }
    }
    
    func newLogsFetched(logs: [serverChangeLog]){
        recordLatestDateAsSyncDate(logs: logs)
        processLogs(logs: logs)
    }
    
    func processLogs(logs: [serverChangeLog]){
        logs.forEach{ log in
            if log.collectionName == "Products" {
                NIMBUS.Products?.processServerChangeLog(log: log)
                
            } else  if log.collectionName == "ProductCategories" {
                NIMBUS.Categories?.processServerChangeLog(log: log)
                
            } else  if log.collectionName == "ProductAddons" {
                NIMBUS.AddOns?.processServerChangeLog(log: log)

            } else  if log.collectionName == "Orders" {
                NIMBUS.OrderManagement?.processServerChangeLog(log: log)

            } else  if log.collectionName == "Tables" {
                NIMBUS.Tables?.processServerChangeLog(log: log)

            } else  if log.collectionName == "Customers" {
                NIMBUS.Customers?.processServerChangeLog(log: log)

            } else  if log.collectionName == "LoyaltyPrograms" {
                NIMBUS.LoyaltyPrograms?.processServerChangeLog(log: log)

            } else  if log.collectionName == "LoyaltyCards" {
                NIMBUS.LoyaltyCards?.processServerChangeLog(log: log)

            } else  if log.collectionName == "Employees" {
                NIMBUS.Employees?.processServerChangeLog(log: log)

            } else  if log.collectionName == "EmployeeHours" {
                NIMBUS.EmployeeHours?.processServerChangeLog(log: log)

            } else  if log.collectionName == "Notes" {
                NIMBUS.Notes?.processServerChangeLog(log: log)

            } else  if log.collectionName == "Locations" {
                NIMBUS.Location?.processServerChangeLog(log: log)

            } else  if log.collectionName == "Businesses" {


            } else  if log.collectionName == "Devices" {
                
            }
        }
    }
    
    func performSyncDown(){
//        print("Perform sync DOWN")
//        print("using last sync time:", lastSuccessfulSyncDOWN?.convertToISOString())
        queryChangeLogsForInserts()
        queryChangeLogsForUpdates()
        queryChangeLogsForDeletes()
    }
    
    func recordLatestDateAsSyncDate(logs: [serverChangeLog]){
        let sortedLogs = logs.sorted(by: {$0.updatedOn?.compare($1.updatedOn!) == ComparisonResult.orderedDescending})
        if let latestLog = sortedLogs.first {
            self.lastSuccessfulSyncDOWN = latestLog.updatedOn
        }
    }
    
    private func convertToJSONLogs(json: [[String: Any]]) -> [serverChangeLog]{
        var changeLogs = [serverChangeLog]()
        json.forEach { json in
            changeLogs.append(serverChangeLog(withJSONDataObject: json))
        }
        return changeLogs
    }
    
    func queryChangeLogsForInserts(){
        let bodyJSON: [String: String] = [
            "token": NIMBUS.Devices?.sessionToken ?? "",
            "lastSync": lastSuccessfulSyncDOWN?.convertToISOString() ?? ""
        ]

        let postData = try? JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: changeLogPaths.getInserts)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
//        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let queryResponse = genericResponse(json: responseJSON)
                    self.fetchedInsertLogs = self.convertToJSONLogs(json: queryResponse.results)
//                    print(responseJSON)
                }
            }
//            semaphore.signal()
        })
        
        dataTask.resume()
//        semaphore.wait()
    }
    
    func queryChangeLogsForUpdates(){
        let bodyJSON: [String: String] = [
            "token": NIMBUS.Devices?.sessionToken ?? "",
            "lastSync": lastSuccessfulSyncDOWN?.convertToISOString() ?? ""
        ]

        let postData = try? JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: changeLogPaths.getUpdates)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        //        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let queryResponse = genericResponse(json: responseJSON)
                    self.fetchedUpdateLogs = self.convertToJSONLogs(json: queryResponse.results)
//                    print(responseJSON)
                }
            }
            //            semaphore.signal()
        })
        
        dataTask.resume()
        //        semaphore.wait()
    }
    
    func queryChangeLogsForDeletes(){
        let bodyJSON: [String: String] = [
            "token": NIMBUS.Devices?.sessionToken ?? "",
            "lastSync": lastSuccessfulSyncDOWN?.convertToISOString() ?? ""
        ]

        let postData = try? JSONSerialization.data(withJSONObject: bodyJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: changeLogPaths.getDeletes)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        //        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let queryResponse = genericResponse(json: responseJSON)
                    self.fetchedDeleteLogs = self.convertToJSONLogs(json: queryResponse.results)
//                    print(responseJSON)
                }
            }
            //            semaphore.signal()
        })
        
        dataTask.resume()
        //        semaphore.wait()
    }
    
}

