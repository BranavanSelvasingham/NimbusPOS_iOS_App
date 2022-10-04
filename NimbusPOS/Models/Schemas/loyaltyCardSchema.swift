//
//  loyaltyCardSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-28.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct loyaltyCardSchema: Codable {
    var _id: String? = UUID().uuidString
    var businessId: String? = NIMBUS.Business?.getBusinessId()
    var customerId: String?
    var programId: String?
    var programType: String?
    var remainingQuantity: Int16?
    var remainingAmount: Float?
    var creditPercent: Float?
    var tally: Int16?
    var boughtOn: Date?
    var expired: Bool?
    var updatedOn: Date?
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject loyaltyCardMO: LoyaltyCard? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let loyaltyCardObject = try decoder.decode(loyaltyCardSchema.self, from: data)
                    self = loyaltyCardObject
                } catch {
                    print(error)
                }
            }
        } else if let loyaltyCardMO = loyaltyCardMO {
            var loyaltyCard = loyaltyCardSchema()
            
            loyaltyCard._id = loyaltyCardMO.id
            loyaltyCard.businessId = loyaltyCardMO.businessId
            loyaltyCard.customerId = loyaltyCardMO.customerId
            loyaltyCard.programId = loyaltyCardMO.programId
            loyaltyCard.programType = loyaltyCardMO.programType
            loyaltyCard.remainingQuantity = loyaltyCardMO.remainingQuantity
            loyaltyCard.remainingAmount = loyaltyCardMO.remainingAmount
            loyaltyCard.creditPercent = loyaltyCardMO.creditPercent
            loyaltyCard.tally = loyaltyCardMO.tally
            loyaltyCard.boughtOn = loyaltyCardMO.boughtOn as? Date
            loyaltyCard.expired = loyaltyCardMO.expired
            loyaltyCard.updatedOn = loyaltyCardMO.updatedOn as? Date
            
            self = loyaltyCard
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let loyaltyCardEntity = NSEntityDescription.entity(forEntityName: "LoyaltyCard", in: managedContext)!
            
            var loyaltyCardMO: LoyaltyCard
            
            if let card = NIMBUS.LoyaltyCards?.getLoyaltyCard(byId: self._id ?? " "){
                loyaltyCardMO = card
            } else {
                loyaltyCardMO = NSManagedObject(entity: loyaltyCardEntity, insertInto: managedContext) as! LoyaltyCard
            }
            
            loyaltyCardMO.id = self._id
            loyaltyCardMO.businessId = self.businessId
            loyaltyCardMO.customerId = self.customerId
            loyaltyCardMO.programId = self.programId
            loyaltyCardMO.programType = self.programType
            loyaltyCardMO.remainingQuantity = self.remainingQuantity ?? 0
            loyaltyCardMO.remainingAmount = self.remainingAmount ?? 0
            loyaltyCardMO.creditPercent = self.creditPercent ?? 0
            loyaltyCardMO.tally = self.tally ?? 0
            loyaltyCardMO.boughtOn = self.boughtOn as? NSDate
            loyaltyCardMO.expired = self.expired ?? false
            loyaltyCardMO.updatedOn = self.updatedOn as? NSDate

            
            do {
                NIMBUS.Data?.loggingCoreDataChangesEnabled = enableChangeLog
                try managedContext.save()
                NIMBUS.Data?.loggingCoreDataChangesEnabled = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func programName() -> String {
        return NIMBUS.LoyaltyPrograms?.getProgramName(byId: self.programId ?? "") ?? ""
    }
}
