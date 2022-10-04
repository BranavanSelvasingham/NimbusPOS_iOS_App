//
//  businessSchema.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2017-12-27.
//  Copyright © 2017 Nimbus POS Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct businessSchema: Codable {
    var _id: String?
    var name: String?
    var phone: String?
    var email: String?
    var configuration: businessConfiguration?
    var payroll: businessPayroll?
//    var devices: [deviceSession]?
    var billing: businessBilling?
    
    struct businessProductSize: Codable {
        var code: String?
        var label: String?
        var preferred: Bool?
        var available: Bool?
        var order: Int16?
        
        init(json: [String: Any] = [:]){
            if !json.isEmpty{
                self.code = json["code"] as? String
                self.label = json["label"] as? String
                self.preferred = json["preferred"] as? Bool
                self.available = json["available"] as? Bool
                self.order = json["order"] as? Int16
            }
        }
    }

    struct businessConfiguration: Codable {
        var sizes: [businessProductSize]?
        var emailHoursReminder: Bool?
        var disableEmployeeTimeAdjust: Bool?
        var enableWaiterPinLock: Bool?
        var adminPin: String?
        var allowPOSAddOnCreation: Bool?
        var trackTips: Bool?
        var autoEnrollNewDevice: Bool?
        
        init(json: [String: Any] = [:]){
            if !json.isEmpty{
                self.sizes = json["sizes"] as? [businessProductSize]
                self.emailHoursReminder = json["emailHoursReminder"] as? Bool
                self.disableEmployeeTimeAdjust = json["disableEmployeeTimeAdjust"] as? Bool
                self.enableWaiterPinLock = json["enableWaiterPinLock"] as? Bool
                self.adminPin = json["adminPin"] as? String
                self.allowPOSAddOnCreation = json["allowPOSAddOnCreation"] as? Bool
                self.trackTips = json["trackTips"] as? Bool
                self.autoEnrollNewDevice = json["autoEnrollNewDevice"] as? Bool
            }
        }
    }

    struct businessPayroll: Codable {
        var referenceStartDate: Date?
        var frequencyType: String?
        
        init(json: [String: Any] = [:]){
            if !json.isEmpty{
                self.referenceStartDate = Date().convertFromISOString(isoDate: json["referenceStartDate"] as? String ?? "")
                self.frequencyType = json["frequencyType"] as? String
            }
        }
    }

//    struct deviceSession: Codable {
//        var appId: String?
//    //    var deviceInfo: NSObject?
//        var label: String?
//        var posEnabled: Bool?
//        var selectedLocation: String?
//
//        init(json: [String: Any] = [:]){
//            if !json.isEmpty{
//                self.appId = json["appId"] as? String
//            //    self.deviceInfo = json["deviceInfo"] as? NSObject
//                self.label = json["label"] as? String
//                self.posEnabled = json["posEnabled"] as? Bool
//                self.selectedLocation = json["selectedLocation"] as? String
//            }
//        }
//    }

    struct businessBilling: Codable {
        var stripeCustomerId: String?
        
        init(json: [String: Any] = [:]){
            if !json.isEmpty{
                self.stripeCustomerId = json["stripeCustomerId"] as? String
            }
        }
    }
    
    init (withJSONDataObject json: [String: Any] = [:], withManagedObject businessMO: Business? = nil){
        if !json.isEmpty {
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601UTC)
                do {
                    let businessObject = try decoder.decode(businessSchema.self, from: data)
                    self = businessObject
                } catch {
                    print(error)
                }
            }
        } else if let businessMO = businessMO {
            var business = businessSchema()
            
            business._id = businessMO.id
            business.name = businessMO.name
            business.phone = businessMO.phone
            business.email = businessMO.email
            
            var configuration = businessConfiguration()
            configuration.emailHoursReminder = businessMO.configurationEmailHoursReminder
            configuration.disableEmployeeTimeAdjust = businessMO.configurationDisableEmployeeTimeAdjust
            configuration.enableWaiterPinLock = businessMO.configurationEnableWaiterPinLock
            configuration.adminPin = businessMO.configurationAdminPin
            configuration.allowPOSAddOnCreation = businessMO.configurationAllowPOSAddOnCreation
            configuration.trackTips = businessMO.configurationTrackTips
            configuration.autoEnrollNewDevice = businessMO.configurationAutoEnrollNewDevice
            
            configuration.sizes = [businessProductSize]()
            
            businessMO.configurationSizes?.forEach {size in
                let sizeSet = size as! Business_SetProductSizes
                var bizSize = businessProductSize()
                bizSize.available = sizeSet.available
                bizSize.code = sizeSet.code
                bizSize.label = sizeSet.label
                bizSize.order = sizeSet.order
                bizSize.preferred = sizeSet.preferred
                configuration.sizes?.append(bizSize)
            }
            
            business.configuration = configuration
            
            var payroll = businessPayroll()
            
            payroll.frequencyType = businessMO.payrollFrequencyType
            if let payrollStartDate = businessMO.payrollReferenceStartDate {payroll.referenceStartDate = payrollStartDate as Date}
            
            business.payroll = payroll
            
            var billing = businessBilling()
            
            billing.stripeCustomerId = businessMO.billingStripeCustomerId
            
            business.billing = billing
            
            self = business
        }
    }
    
    func saveToCoreData(enableChangeLog: Bool = true){
        DispatchQueue.main.async {
            let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
            let managedContext = appDelegate.persistentContainer.viewContext
        
            let businessEntity = NSEntityDescription.entity(forEntityName: "Business", in: managedContext)!
            let businessConfigurationSizes = NSEntityDescription.entity(forEntityName: "Business_SetProductSizes", in: managedContext)!
        
            var business: Business
        
            if let biz = NIMBUS.Business?.getBusiness(){
                managedContext.delete(biz)
            }
        
            business = NSManagedObject(entity: businessEntity, insertInto: managedContext) as! Business
            
            business.id = self._id
            business.name = self.name
            business.phone = self.phone
            business.email = self.email
        
            business.configurationAdminPin = self.configuration?.adminPin ?? ""
            business.configurationAllowPOSAddOnCreation = self.configuration?.allowPOSAddOnCreation ?? false
            business.configurationAutoEnrollNewDevice = self.configuration?.autoEnrollNewDevice ?? false
            business.configurationDisableEmployeeTimeAdjust = self.configuration?.disableEmployeeTimeAdjust ?? false
            business.configurationEmailHoursReminder = self.configuration?.emailHoursReminder ?? false
            business.configurationEnableWaiterPinLock = self.configuration?.enableWaiterPinLock ?? false
            business.configurationTrackTips = self.configuration?.trackTips ?? false
        
            business.payrollReferenceStartDate = self.payroll?.referenceStartDate as? NSDate
            business.payrollFrequencyType = self.payroll?.frequencyType
        
            business.billingStripeCustomerId = self.billing?.stripeCustomerId
        
            self.configuration?.sizes?.forEach {setSize in
                let size = NSManagedObject(entity: businessConfigurationSizes, insertInto: managedContext) as! Business_SetProductSizes
                size.order = setSize.order ?? 0
                size.available = setSize.available ?? false
                size.code = setSize.code
                size.label = setSize.label
                size.preferred = setSize.preferred ?? false
                size.business = business
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
