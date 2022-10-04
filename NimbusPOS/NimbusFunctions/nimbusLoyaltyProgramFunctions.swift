//
//  nimbusLoyaltyProgramFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusLoyaltyProgramFunctions: NimbusBase{
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    var fetchedLoyaltyPrograms = [LoyaltyProgram](){
        didSet{
            
        }
    }
    
    var fetchedLoyaltyProgramsAsStructs: [loyaltyProgramSchema]? {
        didSet {
            orderLoyaltyCollectionView?.reloadData()
        }
    }
    
    var orderLoyaltyCollectionView: UICollectionView?
    
    let loyaltyTypes: [loyaltyTypeStruct] = [
        loyaltyTypeStruct(name: "ALL", label: "All", color: UIColor.color(fromHexString: "bdbdbd")),
        loyaltyTypeStruct(name: (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!, label: "(#) Quantity Based", color: UIColor.color(fromHexString: "3399ff")),
        loyaltyTypeStruct(name: (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!, label: "(%) Percentage Based", color: UIColor.color(fromHexString: "006600")),
        loyaltyTypeStruct(name: (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!, label: "($) Amount Based", color: UIColor.color(fromHexString: "cc9900"))
    ]
    
    struct loyaltyTypeStruct {
        let name: String
        let label: String
        let color: UIColor
    }
    
    var loyaltyProgramsTableView: UITableView?
    
    let loyaltyProgramsOnServer = LoyaltyProgramAPIs()
    
    func syncLoyaltyProgramsServerDataToLocal(){
        loyaltyProgramsOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        loyaltyProgramsOnServer.processChangeLog(log: log)
    }

    func initializeOrderLoyaltyView(collectionView: UICollectionView){
        self.orderLoyaltyCollectionView = collectionView
        fetchLoyaltyProgramsForPurchase(type: loyaltyTypes[0].name)
    }
    
    func getLoyaltyProgramAsStruct(byId programId: String ) -> loyaltyProgramSchema? {
        var fetchLoyaltyPrograms = [LoyaltyProgram]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LoyaltyProgram")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", programId)
        
        do {
            fetchLoyaltyPrograms = try managedContext.fetch(fetchRequest) as! [LoyaltyProgram]
            let programMO = fetchLoyaltyPrograms.first

            return loyaltyProgramSchema(withManagedObject: programMO)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func getLoyaltyProgram(byId programId: String) -> LoyaltyProgram? {
        var fetchLoyaltyPrograms = [LoyaltyProgram]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LoyaltyProgram")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", programId)
        
        do {
            fetchLoyaltyPrograms = try managedContext.fetch(fetchRequest) as! [LoyaltyProgram]
            return fetchLoyaltyPrograms.first
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }

    func getAllLoyaltyPrograms(type: String = "ALL") -> [LoyaltyProgram] {
        var fetchLoyaltyPrograms = [LoyaltyProgram]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LoyaltyProgram")
        fetchRequest.returnsObjectsAsFaults = false
        
        if type == loyaltyTypes[1].name {
            fetchRequest.predicate = NSPredicate(format: "programType = %@", (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!)
        } else if type == loyaltyTypes[2].name {
            fetchRequest.predicate = NSPredicate(format: "programType = %@", (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!)
        } else if type == loyaltyTypes[3].name {
            fetchRequest.predicate = NSPredicate(format: "programType = %@", (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!)
        }
        
        do {
            fetchLoyaltyPrograms = try managedContext.fetch(fetchRequest) as! [LoyaltyProgram]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchLoyaltyPrograms
    }
    
    func fetchLoyaltyProgramsForPurchase(type: String = "ALL"){
        //Group by type if "All"
        let allPrograms = getAllLoyaltyPrograms(type: type)
        
        let allPurchaseablePrograms = allPrograms.filter({$0.programType != NIMBUS.Library?.LoyaltyPrograms.Types.Tally})
        
        var allProgramsGrouped = allPurchaseablePrograms
        if type == "ALL" {
            allProgramsGrouped = allProgramsGrouped.sorted(by: { $0.programType ?? "" > $1.programType ?? "" })
        }
        
        let allProgramsConvertedToStructs: [loyaltyProgramSchema] = allProgramsGrouped.map({loyaltyProgramSchema(withManagedObject: $0)})

        self.fetchedLoyaltyProgramsAsStructs = allProgramsConvertedToStructs
    }
    
    func getProgramName(byId programId: String) -> String? {
        var program = getLoyaltyProgram(byId: programId)
        return program?.name
    }
    
    func deleteLoyaltyProgram(loyaltyProgram: LoyaltyProgram){
        managedContext.delete(loyaltyProgram)
    }
    
    func deleteLoyaltyProgramById(programId: String){
        if let program = getLoyaltyProgram(byId: programId){
            deleteLoyaltyProgram(loyaltyProgram: program)
        }
    }
    
    func uploadProgramMO(programMO: LoyaltyProgram) -> Bool {
        return loyaltyProgramsOnServer.uploadProgramMO(programMO: programMO)
    }
    
    func deleteAllLoyaltyPrograms(){
        deleteAllRecords(entityName: LoyaltyProgram.entity().managedObjectClassName )
    }
    
}
