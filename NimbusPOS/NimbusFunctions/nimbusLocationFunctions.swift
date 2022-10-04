//
//  nimbusLocationFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData

class nimbusLocationFunctions: NimbusBase {
    
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let locationsOnServer = LocationAPIs()
    
    func syncLocationServerDataToLocal(){
        locationsOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        locationsOnServer.processChangeLog(log: log)
    }
    
    func getLocationId () -> String {
        return UserDefaults.standard.string(forKey: "locationId") ?? ""
    }
    
    func getAllLocations() -> [Location] {
        var fetchedLocation = [Location]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            fetchedLocation = try managedContext.fetch(fetchRequest) as! [Location]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchedLocation
    }
    
    func getLocationById(locationId: String) -> Location? {
        var fetchedLocation = [Location]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", locationId)
        
        do {
            fetchedLocation = try managedContext.fetch(fetchRequest) as! [Location]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchedLocation.first
    }
    
    func getLocation() -> Location? {
        var fetchedLocation = [Location]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", getLocationId())
        
        do {
            fetchedLocation = try managedContext.fetch(fetchRequest) as! [Location]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchedLocation.first
    }
    
    func getLocationName() -> String {
        let location = getLocation()
        
        return location?.name ?? ""
    }
    
    func getLocationAddress() -> addressSchema {
        var address = addressSchema()
        let location = getLocation()
        
        address.street = location?.addressStreet
        address.city = location?.addressCity
        address.state = location?.addressState
        address.pin = location?.addressPin
        address.country = location?.addressCountry
        
        return address
    }
    
    func isDeviceLocationSelected()-> Bool {
        if let _ = UserDefaults.standard.string(forKey: "locationId"){
            return true
        }
        return false
    }
    
    func setLocation(selectedLocation: Location){
        UserDefaults.standard.set(selectedLocation.id, forKey: "locationId")
        UserDefaults.standard.synchronize()
    }
    
    func clearCurrentSelectedLocation(){
        UserDefaults.standard.set(nil, forKey: "locationId")
        UserDefaults.standard.synchronize()
    }
    
    func deleteAllLocations(){
        deleteAllRecords(entityName: "Location")
    }
}
