//
//  nimbusDataFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import NotificationCenter

protocol DataLoadingDelegate {
    func coreServerDataLoaded()
    func dataLoadingCompleted()
}

class nimbusDataFunctions: NimbusBase {
    override init (master: NimbusFramework?){
        super.init(master: master)
        
        deviceSyncFrequency = _syncFrequencies.everyMinute.rawValue
        
        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(notificationForResultsFromDocumentIdListCall(notification:)), name: Notification.Name.onResultsFromDocumentIdListCall, object: nil)
        notificationCenter.addObserver(self, selector: #selector(notificationForBatchSaveToCoreData(notification:)), name: Notification.Name.onBatchSaveToCoreDataCompleted, object: nil)
    }
    
    var syncUP = nimbusSyncUPLocalChanges()
    var syncDOWN = nimbusSyncDOWNServerChanges()
    var loggingCoreDataChangesEnabled: Bool = true
    var syncStep: Int = 0
    
    var dataLoadingDelegate: DataLoadingDelegate?
    
    enum _syncFrequencies: Int {
        case everyMinute = 1
        case everyHour = 60
        case everyThreeHours = 180
        case twiceDaily = 720
        case daily = 1440
    }
    
    var dataLoadedBefore: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "dataLoadedBefore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "dataLoadedBefore")
        }
    }
    
    /*
     Description: Sync frequency in minutes
     */
    var deviceSyncFrequency: Int {
        get {
            var syncFrequency = UserDefaults.standard.integer(forKey: "deviceSyncFrequency")
            if syncFrequency == nil || syncFrequency == 0{
                syncFrequency = 60
            }
            return syncFrequency
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "deviceSyncFrequency")
            UserDefaults.standard.synchronize()
        }
    }
    
    /*
     Description: Local order history in days
     */
    var localOrderHistoryLimit: Int {
        get {
            var historyLimit = UserDefaults.standard.integer(forKey: "localOrderHistoryLimit")
            if historyLimit == nil || historyLimit == 0 {
                historyLimit = 7
            }
            return historyLimit
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "localOrderHistoryLimit")
            UserDefaults.standard.synchronize()
        }
    }
    
    enum _periodicSyncStates{
        case Active
        case Paused
        case Stopped
    }
    
    var periodicSyncStatus: _periodicSyncStates = .Stopped
    
    func initiatePeriodicSyncTask(){
        let syncFrequency: TimeInterval = TimeInterval(exactly: deviceSyncFrequency * 60) ?? 60
        if periodicSyncStatus == .Stopped {
            DispatchQueue.main.async {
                Timer.scheduledTimer(timeInterval: syncFrequency, target: self, selector: #selector(self.performPeriodicSync), userInfo: nil, repeats: false)
            }
            periodicSyncStatus = .Active
        }
    }
    
    @objc func performPeriodicSync(){
        let syncFrequency: TimeInterval = TimeInterval(exactly: deviceSyncFrequency * 60) ?? 60
        
        if periodicSyncStatus == .Active {
            self.syncUP.performSyncUP()
            self.syncDOWN.performSyncDown()
        }
        
        if periodicSyncStatus != .Stopped {
            DispatchQueue.main.async {
                Timer.scheduledTimer(timeInterval: syncFrequency, target: self, selector: #selector(self.performPeriodicSync), userInfo: nil, repeats: false)
            }
        }
        
    }
    
    func refreshLastSyncTimes(){
        syncUP.lastSuccessfulSyncUP = Date()
        syncDOWN.lastSuccessfulSyncDOWN = Date()
    }
    
    func syncCoreServerDataToLocal(){
        syncStep = 1
        startSyncServerDataToLocal()
    }
    
    func syncServerDataToLocal(){
        syncStep = 4
        startSyncServerDataToLocal()
    }
    
    @objc func notificationForResultsFromDocumentIdListCall(notification: NSNotification) {

    }
    
    @objc func notificationForBatchSaveToCoreData(notification: NSNotification) {
        let saveNotification = notification.object as! notificationBatchSaveToCoreDataCompleted
        if saveNotification.syncComplete == true {
            goToNextSyncStep()
        }
    }
    
    func goToNextSyncStep(){
        syncStep += 1
        startSyncServerDataToLocal()
    }
    
    func startSyncServerDataToLocal(){
        switch self.syncStep {
        case 1:
            NIMBUS.Business?.syncBusinessServerDataToLocal()
        case 2:
            NIMBUS.Location?.syncLocationServerDataToLocal()
        case 3:
            self.dataLoadingDelegate?.coreServerDataLoaded()
        case 4:
            NIMBUS.Categories?.syncProductCategoryServerDataToLocal()
        case 5:
            NIMBUS.AddOns?.syncProductAddOnServerDataToLocal()
        case 6:
            NIMBUS.Products?.syncProductsServerDataToLocal()
        case 7:
            NIMBUS.OrderManagement?.syncOrderServerDataToLocal()
        case 8:
            NIMBUS.Tables?.syncTablesServerDataToLocal()
        case 9:
            NIMBUS.Customers?.syncCustomerServerDataToLocal()
        case 10:
            NIMBUS.LoyaltyPrograms?.syncLoyaltyProgramsServerDataToLocal()
        case 11:
            NIMBUS.LoyaltyCards?.syncLoyaltyCardsServerDataToLocal()
        case 12:
            NIMBUS.Employees?.syncEmployeesServerDataToLocal()
        case 13:
            NIMBUS.EmployeeHours?.syncEmployeeHoursServerDataToLocal()
        case 14:
            NIMBUS.Notes?.syncNotesServerDataToLocal()
        default:
            self.syncStep = 0
            if dataLoadedBefore != true {
                dataLoadedBefore = true
            }
            self.dataLoadingDelegate?.dataLoadingCompleted()
        }
    }
    
    func initiateFirstRunSyncProcess(){
        refreshLastSyncTimes()
        if periodicSyncStatus == .Paused {
            periodicSyncStatus = .Active
        }
        initiatePeriodicSyncTask()
    }
    
    func initiateNonFirstRunSyncProcess(){
        if periodicSyncStatus == .Paused {
            periodicSyncStatus = .Active
        }
        initiatePeriodicSyncTask()
    }
    
    func clearBusinessAndLocation(){
        NIMBUS.Business?.deleteAllBusinesses()
        NIMBUS.Location?.deleteAllLocations()
        NIMBUS.Location?.clearCurrentSelectedLocation()
    }
    
    func parseNotificationManagedObjectContextDidChange(entityDescription: NSEntityDescription, notification: NSNotification, callFunction: ()->()){
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            if inserts.contains(where: {$0.entity.isKindOf(entity: entityDescription)}) {
                callFunction()
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            for update in updates {
                if update.entity.isKindOf(entity: entityDescription){
                    callFunction()
                }
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            if deletes.contains(where: {$0.entity.isKindOf(entity: entityDescription)}){
                callFunction()
            }
        }
    }
}
