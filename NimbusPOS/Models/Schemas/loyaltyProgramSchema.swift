//
//  loyaltyProgramSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-29.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct programProduct: Codable {
    var productId: String?
    var sizeCodes: [String]?
}

struct programTypes: Codable {
    var type: String?
    var quantity: Int16?
    var creditPercentage: Float?
    var creditAmount: Float?
    var tally: Int16?
}

struct programCategories: Codable {
    var name: String?
}

struct loyaltyProgramSchema: Codable {
    var _id: String?
    var businessId: String?
    var name: String?
    var programType: programTypes?
    var appliesTo: String?
    var products: [programProduct]?
    var categories: [programCategories]?
    var price: Float?
    var expiryDays: Int16?
    var expiryDate: Date?
    var status: String?
    var taxRule: String?
    
//    var purchaseLoyalty: productSchema?
    func getProgramAsProduct() -> productSchema {
        var programProduct = productSchema()
        
        programProduct._id = self._id
        programProduct.name = self.name
        programProduct.businessId = self.businessId
        programProduct.categories = [(NIMBUS.Library?.LoyaltyPrograms.programAsProductCategoryLabel)!]
        programProduct.sizes = { () -> [productSize] in
            var programProductSize = productSize()
            let businessSizes = NIMBUS.Products?.getProductSizeLabels()
            programProductSize.code = businessSizes?[0].code ?? "R"
            programProductSize.price = self.price
            return [programProductSize]
        }()
        programProduct.taxRule = self.taxRule
        programProduct.updatedAt = Date()
        
        return programProduct
    }
    
    func getProgramColor() -> UIColor {
        if let program = self.programType?.type {
            switch program {
            case (NIMBUS.Library?.LoyaltyPrograms.Types.Quantity)!:
                return (NIMBUS.LoyaltyPrograms?.loyaltyTypes[1].color)!
            case (NIMBUS.Library?.LoyaltyPrograms.Types.Coupon)!:
                return (NIMBUS.LoyaltyPrograms?.loyaltyTypes[2].color)!
            case (NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard)!:
                return (NIMBUS.LoyaltyPrograms?.loyaltyTypes[3].color)!
            default:
                return (NIMBUS.LoyaltyPrograms?.loyaltyTypes[0].color)!
            }
        }
        return (NIMBUS.LoyaltyPrograms?.loyaltyTypes[0].color)!
    }
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject programMO: LoyaltyProgram? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let programObject = try decoder.decode(loyaltyProgramSchema.self, from: data)
                    self = programObject
                } catch {
                    print(error)
                }
            }
        } else if let programMO = programMO {
            var program = loyaltyProgramSchema()
            
            program._id = programMO.id
            program.businessId = programMO.businessId
            program.name = programMO.name
            program.appliesTo = programMO.appliesTo
            program.price = programMO.price
            program.expiryDays = programMO.expiryDays
            program.expiryDate = programMO.expiryDate as? Date
            program.status = programMO.status
            program.taxRule = programMO.taxRule
            
            program.categories = [programCategories]()
            if let programMOCategories = programMO.categories as? [String] {
                programMOCategories.forEach{category in
                    var programCat = programCategories()
                    programCat.name = category
                    program.categories?.append(programCat)
                }
            }
            
            program.programType = programTypes()
            program.programType?.type = programMO.programType
            program.programType?.tally = programMO.programTally
            program.programType?.quantity = programMO.programQuantity
            program.programType?.creditPercentage = programMO.programCreditPercent
            program.programType?.creditAmount = programMO.programCreditAmount
            
            program.products = [programProduct]()
            programMO.products?.forEach {(prod) in
                let programProductMO = prod as! LoyaltyProgramProducts
                var appendProduct = programProduct()
                appendProduct.productId = programProductMO.productId
                appendProduct.sizeCodes = programProductMO.sizeCodes as? [String]
                program.products?.append(appendProduct)
            }

            self = program
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let loyaltyProgramEntity = NSEntityDescription.entity(forEntityName: "LoyaltyProgram", in: managedContext)!
            let loyaltyProgramProductsEntity = NSEntityDescription.entity(forEntityName: "LoyaltyProgramProducts", in: managedContext)!
            
            var programMO: LoyaltyProgram
            
            if let program = NIMBUS.LoyaltyPrograms?.getLoyaltyProgram(byId: self._id ?? " "){
                managedContext.delete(program)
            }
            
            programMO = NSManagedObject(entity: loyaltyProgramEntity, insertInto: managedContext) as! LoyaltyProgram
            
            programMO.id = self._id
            programMO.businessId = self.businessId
            programMO.name = self.name
            programMO.appliesTo = self.appliesTo
            programMO.price = self.price ?? 0
            programMO.expiryDays = self.expiryDays ?? 0
            programMO.expiryDate = self.expiryDate as? NSDate
            programMO.status = self.status
            programMO.taxRule = self.taxRule
            
            if let programCategories = self.categories {
                programMO.categories = []
                programCategories.forEach{ category in
                    programMO.categories!.append(category.name ?? "")
                }
            }
            
            if let programTypeObj = self.programType {
                programMO.programType = programTypeObj.type
                programMO.programTally = programTypeObj.tally ?? 0
                programMO.programQuantity = programTypeObj.quantity ?? 0
                programMO.programCreditPercent = programTypeObj.creditPercentage ?? 0
                programMO.programCreditAmount = programTypeObj.creditAmount ?? 0
            }
            
            if let programProductsSet = self.products as? [programProduct] {
                programProductsSet.forEach{prod in
                    var programProductMO = NSManagedObject(entity: loyaltyProgramProductsEntity, insertInto: managedContext) as! LoyaltyProgramProducts
                    programProductMO.productId = prod.productId
                    programProductMO.sizeCodes = prod.sizeCodes
                    programProductMO.loyaltyProgram = programMO
                }
            }
            
            do {
                NIMBUS.Data?.loggingCoreDataChangesEnabled = enableChangeLog
                try managedContext.save()
                NIMBUS.Data?.loggingCoreDataChangesEnabled = true
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
}
