//
//  ProductSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-22.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct productSize: Codable {
    var code: String?
    var price: Float?
    
    //Local Modifications
    var label: String?
    var sortPosition: Int16?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case price
        case label
        case sortPosition
    }
    
    public init(from decoder: Decoder) throws {
        let sizeValues = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try? sizeValues.decode(String.self , forKey: .code)
        price = try? sizeValues.decode(Float.self , forKey: .price)
        label = NIMBUS.Products?.getLabelForCode(code: code!)
        sortPosition = NIMBUS.Products?.getSortPosition(code: code!)
        
    }
    
    init(){
        //
    }
    
    func asDictionary()->[String: Any]{
        return [
            "code": self.code,
            "price": self.price,
            "label": self.label,
            "sortPosition": self.sortPosition
        ]
    }
}

struct productSchema: Codable {
    //conforms to mongodb store
    var _id: String?
    var name: String?
    var sortPosition: Int16?
    var description: String?
    var status: String?
    var businessId: String?
    var locations: [String]?
    var categories: [String]?
    var group: String?
    var sizes: [productSize]?
    var isVariablePrice: Bool?
    var isUnitBasedPrice: Bool?
    var unitLabel: String?
    var addOns: [String]?
    var taxRule: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    //local modifications
    var primaryCategory: String?
    var isGroupObject: Bool = false
    var productsUnderGroup: [productSchema]?
    var isExpanded: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case _id
        case name
        case sortPosition
        case description
        case status
        case businessId
        case locations
        case categories
        case group
        case sizes
        case isVariablePrice = "variablePrice"
        case isUnitBasedPrice = "unitBasedPrice"
        case unitLabel
        case addOns
        case taxRule
        case createdAt
        case updatedAt
    }
    
    public init(from decoder: Decoder) throws {
        let productValues = try decoder.container(keyedBy: CodingKeys.self)
        _id = try? productValues.decode(String.self , forKey: ._id)
        name = try? productValues.decode(String.self , forKey: .name)
        sortPosition = try? productValues.decode(Int16.self , forKey: .sortPosition)
        description = try? productValues.decode(String.self , forKey: .description)
        status = try? productValues.decode(String.self , forKey: .status)
        businessId = try? productValues.decode(String.self , forKey: .businessId)
        locations = try? productValues.decode([String].self , forKey: .locations)
        categories = try? productValues.decode([String].self , forKey: .categories)
        group = try? productValues.decode(String.self , forKey: .group)
        sizes = try? productValues.decode([productSize].self , forKey: .sizes)
        isVariablePrice = try? productValues.decode(Bool.self , forKey: .isVariablePrice)
        isUnitBasedPrice = try? productValues.decode(Bool.self , forKey: .isUnitBasedPrice)
        unitLabel = try? productValues.decode(String.self , forKey: .unitLabel)
        addOns = try? productValues.decode([String].self , forKey: .addOns)
        taxRule = try? productValues.decode(String.self , forKey: .taxRule)
        createdAt = try? productValues.decode(Date.self , forKey: .createdAt)
        updatedAt = try? productValues.decode(Date.self , forKey: .updatedAt)
    }
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject productMO: Product? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let productObject = try decoder.decode(productSchema.self, from: data)
                    self = productObject
                } catch {
                    print(error)
                }
            }
        } else if let productMO = productMO {
            var product = productSchema()
            
            product._id = productMO.id
            product.name = productMO.name
            product.sortPosition = productMO.sortPosition
            product.description = productMO.productDescription
            product.status = productMO.status
            product.businessId = productMO.businessId
            product.locations = productMO.locations as? [String]
            product.categories = productMO.categories as? [String]
            product.primaryCategory = productMO.primaryCategory
            product.group = productMO.group
            product.isVariablePrice = productMO.isVariablePrice
            product.isUnitBasedPrice = productMO.isUnitBasedPrice
            product.unitLabel = productMO.unitLabel
            product.addOns = productMO.addOns as? [String]
            product.taxRule = productMO.taxRule
            product.createdAt = productMO.createdAt as? Date
            product.updatedAt = productMO.updatedAt as? Date
            
            product.sizes = [productSize]()
            
            productMO.sizes?.forEach {pricing in
                let sizing = pricing as! Product_Sizes
                var size = productSize()
                size.code = sizing.code
                size.price = sizing.price
                size.label = sizing.label
                size.sortPosition = sizing.sortPosition
                
                product.sizes?.append(size)
            }
            
            product.sizes?.sort {$0.sortPosition! < $1.sortPosition! }
            
            self = product
        }
        
        refreshSizeSortPositions()
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let productEntity = NSEntityDescription.entity(forEntityName: "Product", in: managedContext)!
            let productSizesEntity = NSEntityDescription.entity(forEntityName: "Product_Sizes", in: managedContext)!
            
            var product: Product

            if let prod = NIMBUS.Products?.getProductById(productId: self._id ?? " ") {
                //product exists
                managedContext.delete(prod)
            }
            
            product = NSManagedObject(entity: productEntity, insertInto: managedContext) as! Product
            
            product.id = self._id
            product.name = self.name
            product.sortPosition = self.sortPosition ?? 0
            product.productDescription = self.description ?? ""
            product.status = self.status
            product.businessId = self.businessId
            product.locations = self.locations as? NSArray
            product.categories = self.categories as? NSArray ?? []
            
            if let categoryObject = product.categories?.firstObject{
                product.primaryCategory = categoryObject as? String ?? ""
                //            product.secondaryCategory = item.categories?[1] as? String ?? ""
            }
            
            product.group = self.group
            product.isVariablePrice = self.isVariablePrice ?? false
            product.isUnitBasedPrice = self.isUnitBasedPrice ?? false
            product.unitLabel = self.unitLabel ?? ""
            product.addOns = self.addOns as? NSArray
            product.taxRule = self.taxRule
            product.createdAt = self.createdAt as NSDate?
            product.updatedAt = self.updatedAt as NSDate?
            
            //create relationship objects
            self.sizes?.forEach {pricing in
                let size = NSManagedObject(entity: productSizesEntity, insertInto: managedContext) as! Product_Sizes
                size.product = product
                size.price = pricing.price!
                size.code = pricing.code
                size.label = pricing.label
                size.sortPosition = NIMBUS.Products?.getSortPosition(code: pricing.code ?? "") ?? 0
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
    
    func getCategoryColor() -> UIColor {
        let categoryName = self.categories?.first ?? " "
        
        var appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        var managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        var fetchCategories = [NSManagedObject]()
        var category: ProductCategory?
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ProductCategory")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "name == %@", categoryName)
        
        do {
            fetchCategories = try managedContext.fetch(fetchRequest) as! [ProductCategory]
            category = fetchCategories.first as? ProductCategory
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return UIColor.color(fromHexString: (category?.color ?? "bdbdbd")!)
    }
    
    mutating func refreshSizeSortPositions(){
        for (index, size) in (self.sizes ?? []).enumerated() {
            self.sizes![index].sortPosition = NIMBUS.Products?.getSortPosition(code: size.code ?? "") ?? 0
        }
    }
    
    func getSortedSizes() -> [productSize]{
        return self.sizes?.sorted(by: {($1.sortPosition ?? 0) > ($0.sortPosition ?? 0)}) ?? []
    }
    
    func isMultiSize() -> Bool {
        if (self.sizes?.count ?? 1) > 1 {
            return true
        }
        return false
    }
}
