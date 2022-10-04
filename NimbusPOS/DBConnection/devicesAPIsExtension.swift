//
//  devicesAPIsExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-27.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents.MDCSnackbarMessage

class DeviceAPIs: APIs {
    let devicesPaths = deviceAPIPaths()
    
    var deviceNumber: Int {
        get {
            return UserDefaults.standard.integer(forKey: "deviceNumber")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "deviceNumber")
            UserDefaults.standard.synchronize()
        }
    }
    
    struct deviceAPIPaths {
        let baseSubRoute = "/api/device"
        let registerDevicePath: String
        let updateDeviceLocationPath: String
        let getDeviceOrderIdPrefixPath: String
        
        init () {
            let basePaths = APIs()
            registerDevicePath = basePaths.baseURL + baseSubRoute + "/registerDevice"
            updateDeviceLocationPath = basePaths.baseURL + baseSubRoute +  "/updateDeviceLocation"
            getDeviceOrderIdPrefixPath = basePaths.baseURL + baseSubRoute + "/getDeviceNumber"
        }
    }
    
    func registerDevice(deviceId: String) {
        let registerDeviceJSON: [String: String] = [
            "deviceId": deviceId,
            "token": authenticationToken
        ]

        let postData = try? JSONSerialization.data(withJSONObject: registerDeviceJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: devicesPaths.registerDevicePath)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers as! [String : String]
        request.httpBody = postData as! Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
//                let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
//                if let responseJSON = responseJSON as? [String: Any] {
//                    let responseData = genericResponse(json: responseJSON)
//                }
                self.getDeviceNumber(deviceId: deviceId)
            }
        })
        
        dataTask.resume()
    }
    
    func getDeviceNumber(deviceId: String){
        let getDevicePrefixJSON: [String: String] = [
            "deviceId": deviceId,
            "token": authenticationToken
        ]
        
        let postData = try? JSONSerialization.data(withJSONObject: getDevicePrefixJSON, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: devicesPaths.getDeviceOrderIdPrefixPath)! as URL,
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
                    let responseData = genericResponse(json: responseJSON)
//                    print("device number result")
//                    print(responseData.results[0])
                    self.deviceNumber = responseData.results[0]["deviceNumber"] as? Int ?? 1
//                    print(self.deviceNumber)
                }
            }
        })
        
        dataTask.resume()
    }
}

