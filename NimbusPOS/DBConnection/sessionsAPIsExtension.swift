//
//  sessionsAPIsExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-28.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MaterialSnackbar

class SessionAPIs: APIs {
    let sessionPaths = sessionAPIPaths()
    var sessionToken: String {
        get {
            return UserDefaults.standard.string(forKey: "token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
            UserDefaults.standard.synchronize()
            
            checkIfSessionActive(freshToken: newValue)
        }
    }
    
    var appAuthenticated: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "appAuthenticated")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "appAuthenticated")
            UserDefaults.standard.synchronize()
            
            if newValue == true {
                let appAuthenticationAttempt: notificationAppAuthenticationAttempt = notificationAppAuthenticationAttempt(appAuthenticationSuccessful: true, message: "Session active")
                NotificationCenter.default.post(name: .onAppAuthenticationAttempt, object: appAuthenticationAttempt)
            } else {
                let appAuthenticationAttempt: notificationAppAuthenticationAttempt = notificationAppAuthenticationAttempt(appAuthenticationSuccessful: false, message: "Session inactive. Re-Authenticate.")
                NotificationCenter.default.post(name: .onAppAuthenticationAttempt, object: appAuthenticationAttempt)
            }
        }
    }
    
    struct sessionAPIPaths {
        let baseSubRoute = "/api/session"
        let loginPath: String
        let isSessionActivePath: String
        let logoutPath: String
        let refreshSessionPath: String
        
        init () {
            let basePaths = APIs()
            loginPath = basePaths.baseURL + baseSubRoute + "/login"
            isSessionActivePath = basePaths.baseURL + baseSubRoute + "/isSessionActive"
            logoutPath = basePaths.baseURL + baseSubRoute +  "/logout"
            refreshSessionPath = basePaths.baseURL + baseSubRoute + "/refreshSession"
        }
    }
    
    struct loginResponseData{
        let message: String?
        let token: String?
        let success: Bool
        
        init (json: [String: Any]){
            self.message = (json["message"] as? String) ?? ""
            self.token = (json["token"] as? String) ?? nil
            self.success = (json["success"] as? Bool) ?? false
        }
    }
    
    struct createResponse {
        let _id: String?
        let message: String?
        
        init(json: [String: String]){
            self._id = (json["_id"] as? String) ?? ""
            self.message = (json["message"] as? String) ?? ""
        }
    }
    
    func login(username: String, password: String){
        getSessionToken(username: username, password: password)
    }
    
    func logout(){
        logoutSession()
    }
    
    func refreshSession(){
        refreshToken()
    }
    
    func getSessionToken(username: String, password: String){
        let loginJSON: [String: String] = [
            "username": username,
            "password": password
        ]
        
        let postData = try? JSONSerialization.data(withJSONObject: loginJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: sessionPaths.loginPath)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                let loginAttemptNotification: notificationLoginAttempt = notificationLoginAttempt(loginSuccessful: false, message: "Error trying to activate session.")
                NotificationCenter.default.post(name: .onResultsFromLoginAttempt, object: loginAttemptNotification)
            } else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let responseData = loginResponseData(json: responseJSON)
                    if let token = responseData.token {
                        self.sessionToken = token
                        let loginAttemptNotification: notificationLoginAttempt = notificationLoginAttempt(loginSuccessful: true, message: "Login Successful")
                        NotificationCenter.default.post(name: .onResultsFromLoginAttempt, object: loginAttemptNotification)
                    } else {
                        let loginAttemptNotification: notificationLoginAttempt = notificationLoginAttempt(loginSuccessful: false, message: "Login Failed")
                        NotificationCenter.default.post(name: .onResultsFromLoginAttempt, object: loginAttemptNotification)
                    }
                } else {
                    let loginAttemptNotification: notificationLoginAttempt = notificationLoginAttempt(loginSuccessful: false, message: "Login Failed")
                    NotificationCenter.default.post(name: .onResultsFromLoginAttempt, object: loginAttemptNotification)
                }
            }
        })
        dataTask.resume()
    }
    
    func checkIfSessionActive(freshToken: String? = nil){
        var token: String
        
        if let freshToken = freshToken {
            token = freshToken
        } else {
            token = self.sessionToken
        }
        
        let logoutJSON: [String: String] = [
            "token": token
        ]
        
        let postData = try? JSONSerialization.data(withJSONObject: logoutJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: sessionPaths.isSessionActivePath)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                let appAuthenticationAttempt: notificationAppAuthenticationAttempt = notificationAppAuthenticationAttempt(appAuthenticationSuccessful: false, message: "There was an error trying to activate app instance")
                NotificationCenter.default.post(name: .onAppAuthenticationAttempt, object: appAuthenticationAttempt)
            } else {
                let rawResponseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = rawResponseJSON as? [String: Any] {
                    let sessionResponse = genericResponse(json: responseJSON)
                    self.appAuthenticated = sessionResponse.success
                } else {
                    let appAuthenticationAttempt: notificationAppAuthenticationAttempt = notificationAppAuthenticationAttempt(appAuthenticationSuccessful: false, message: "Could not activate session")
                    NotificationCenter.default.post(name: .onAppAuthenticationAttempt, object: appAuthenticationAttempt)
                }
            }
        })
        dataTask.resume()
    }
    
    func logoutSession(){
        let logoutJSON: [String: String] = [
            "token": self.sessionToken
        ]
        
        let postData = try? JSONSerialization.data(withJSONObject: logoutJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: sessionPaths.logoutPath)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    let sessionResponse = genericResponse(json: responseJSON)
                    if sessionResponse.success == true {
                        self.appAuthenticated = false
                        self.sessionToken = ""
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    func refreshToken(){
        let logoutJSON: [String: String] = [
            "token": self.sessionToken
        ]
        
        let postData = try? JSONSerialization.data(withJSONObject: logoutJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: sessionPaths.refreshSessionPath)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if let token = responseJSON["token"] {
                        let responseData = loginResponseData(json: responseJSON)
                        if let token = responseData.token {
                            self.sessionToken = token
                        }
                        
                        self.checkIfSessionActive()
                    }
                } else {
                    print("error tryig to convert json")
                }
            }

        })
        dataTask.resume()
    }
}
