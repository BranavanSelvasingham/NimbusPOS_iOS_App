//
//  nimbusDeviceFunctiosn.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-27.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusDeviceFunctions: NimbusBase {
    override init(master: NimbusFramework?){
        super.init(master: master)
    }

    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    let deviceAPIs = DeviceAPIs()
    let sessionAPIs = SessionAPIs()
    
    var appAuthenticated: Bool {
        get {
            return sessionAPIs.appAuthenticated
        }
    }
    
    var sessionToken: String {
        get {
            return self.sessionAPIs.sessionToken
        }
    }
    
    func loginFromDevice(username: String, password: String){
        sessionAPIs.login(username: username, password: password)
    }
    
    func checkForDeviceAuthentication(){
        sessionAPIs.checkIfSessionActive()
    }
    
    func refreshDeviceSession(){
        sessionAPIs.refreshSession()
    }
    
    func logoutFromDevice(){
        sessionAPIs.logout()
    }
    
    func registerDevice(){
        deviceAPIs.registerDevice(deviceId: deviceId)        
    }
    
    func deviceFirstStart(){
        //
    }
    
    func deviceStart(){
        //
    }
    
    func prepareDeviceForLogin(){
        
    }
    
    func getCoreInfo(delegate: DataLoadingDelegate){
        NIMBUS.Data?.dataLoadingDelegate = delegate
        NIMBUS.Data?.syncCoreServerDataToLocal()
    }
    
    func getDeviceReadyForUse(delegate: DataLoadingDelegate){
        NIMBUS.Data?.dataLoadingDelegate = delegate
        NIMBUS.Data?.syncServerDataToLocal()
    }
    
    func startFirstRunSyncProcess(){
        NIMBUS.Data?.initiateFirstRunSyncProcess()
    }
    
    func startNonFirstRunSyncProcess(){
        NIMBUS.Data?.initiateNonFirstRunSyncProcess()
    }
    
    func locationLevelReset(){
        
    }
    
    func refreshLocationSpecificData(){
        
    }
    
    func changeDeviceLocation(newLocation: Location){
        locationLevelReset()
        NIMBUS.Location?.setLocation(selectedLocation: newLocation)
        refreshLocationSpecificData()
    }
}

