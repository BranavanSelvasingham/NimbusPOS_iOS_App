//
//  nimbusOrderManagementFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-12.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusOrderManagementFunctions: NimbusBase {
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    let orderServer = OrderAPIs()
    
//    class orderHistoryViewComponents {
//        var orderHistoryTable: UITableView?
//
//        func refreshView(){
//            orderHistoryTable?.reloadData()
//        }
//    }
//
//    let orderHistoryView = orderHistoryViewComponents()
//
//    func initializeOrderHistoryView (orderHistoryTable: UITableView){
//        self.orderHistoryView.orderHistoryTable = orderHistoryTable
//    }
    
    func syncOrderServerDataToLocal(){
        orderServer.getAllLocalHistoryOrders()
    }

    func deleteAllOutOfHistoryScopeLocalOrders(){
        let orderHistoryLimit: Int = NIMBUS.Data?.localOrderHistoryLimit ?? 7
        let scopeLimitDate: Date = Date().startOfDay.addingTimeInterval(-TimeInterval(1*60*60*24*orderHistoryLimit))
        let scopeLimit: NSDate = scopeLimitDate as NSDate
        let outOfScopePredicate = NSPredicate(format: "createdAt < %@", scopeLimit)
        let outOfScopeOrders = getOrders(fetchPredicate: outOfScopePredicate)
        
        outOfScopeOrders.forEach{ order in
            managedContext.delete(order)
        }
    }
    
    func processServerChangeLog(log: serverChangeLog){
        orderServer.processChangeLog(log: log)
    }
    
    func getOrders(fetchPredicate: NSPredicate? = nil, sorting: ComparisonResult = .orderedDescending) -> [Order] {
        var fetchOrders = [Order]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Order")
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = fetchPredicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            fetchOrders = try managedContext.fetch(fetchRequest) as! [Order]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if fetchOrders.count > 1 {
            fetchOrders = fetchOrders.sorted(by: {$0.createdAt?.compare($1.createdAt as! Date) == sorting})
        }
        
        return fetchOrders
    }
    
    func getLatestUniqueOrderDailyNumberOrder() -> Order?{
        let beginningOfToday = Date().startOfDay
        let predicate = NSPredicate(format: "createdAt > %@", beginningOfToday as NSDate)
        var fetchOrders = getOrders(fetchPredicate: predicate)
        
        fetchOrders = fetchOrders.sorted(by: {$0.createdAt?.compare($1.createdAt as! Date) == ComparisonResult.orderedDescending})
        
        return fetchOrders.first
    }
    
    func getLatestUniqueOrderNumberOrder() -> Order? {
        var fetchOrders = getOrders()
        fetchOrders = fetchOrders.sorted(by: {$0.createdAt?.compare(($1.createdAt as? Date) ?? Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending})
        return fetchOrders.first
    }
    
    func getMostRecentOrderForToday() -> Order? {
        let beginningOfToday = Date().startOfDay
        let predicate = NSPredicate(format: "updatedAt > %@", beginningOfToday as NSDate)
        var fetchOrders = getOrders(fetchPredicate: predicate)
        
        fetchOrders = fetchOrders.sorted(by: {$0.updatedAt?.compare($1.updatedAt as! Date) == ComparisonResult.orderedDescending})
        
        return fetchOrders.first
    }
    
    func getMostRecentOrder() -> Order? {
        var fetchOrders = getOrders()
        
        fetchOrders = fetchOrders.sorted(by: {$0.updatedAt?.compare(($1.updatedAt as? Date) ?? Date(timeIntervalSince1970: 0)) == ComparisonResult.orderedDescending})
        
        return fetchOrders.first
    }
    
    func searchForOrder(searchText: String, searchScope: String) -> [Order] {
        var fetchPredicate: NSPredicate?
        var compoundPredicate = [NSPredicate]()
        
        switch searchScope{
            case "Order#":
                if let orderNum = Int64(searchText) {
                    compoundPredicate.append(NSPredicate(format: "uniqueOrderNumber = %i", orderNum))
                }
            case "Daily#":
                if let dailyNum = Int32(searchText) {
                    compoundPredicate.append(NSPredicate(format: "dailyOrderNumber = %i", dailyNum))
                }
            case "Customer":
                break
            default:
                break
        }
        
        let nonOpenOrdersPredicate: NSPredicate = NSPredicate(format: "status != %@", (NIMBUS.Library?.OrderStatus.Created)!)
        compoundPredicate.append(nonOpenOrdersPredicate)
        
        fetchPredicate = NSCompoundPredicate(type: .and, subpredicates: compoundPredicate)
        
        return getOrders(fetchPredicate: fetchPredicate)
        
    }
    
    func getOpenOrdes() -> [Order] {
        let openPredicate: NSPredicate = NSPredicate(format: "status = %@", (NIMBUS.Library?.OrderStatus.Created)!)
        
        return getOrders(fetchPredicate: openPredicate, sorting: ComparisonResult.orderedDescending)
    }
    
    func getOpenOrderForTable(tableId: String) -> [Order]? {
        var fetchOrders = [Order]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Order")
        fetchRequest.returnsObjectsAsFaults = false
        var compoundPredicate = [NSPredicate]()
        compoundPredicate.append(NSPredicate(format: "tableId = %@", tableId))
        compoundPredicate.append(NSPredicate(format: "status = %@", (NIMBUS.Library?.OrderStatus.Created)!))
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: compoundPredicate)
        
        do {
            fetchOrders = try managedContext.fetch(fetchRequest) as! [Order]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        fetchOrders = fetchOrders.sorted(by: {$0.createdAt?.compare($1.createdAt as! Date) == ComparisonResult.orderedDescending})

        return fetchOrders
    }
    
    func getOrder(byId orderId: String) -> Order? {
        let idPredicate = NSPredicate(format: "id = %@", orderId)
        let fetchOrders = getOrders(fetchPredicate: idPredicate)
        return fetchOrders.first
    }
    
    func deleteOrder(orderId: String){
        if let doc = NIMBUS.OrderManagement?.getOrder(byId: orderId){
            managedContext.delete(doc)
        }
    }
    
    func cancelOrder(orderId: String){
        if let order = getOrder(byId: orderId) {
            order.status = _OrderStatus.Cancelled.rawValue
            self.saveChangesToContext()
            
            NIMBUS.LoyaltyCards?.cancelOrderLoyaltyItems(order: order)
        }
    }
    
    func printOrder(orderId: String){
        let order = NIMBUS.OrderManagement?.getOrder(byId: orderId)
        let orderAsStruct = orderSchema(withManagedObject: order)
        NIMBUS.Print?.printOrderReceipt(order: orderAsStruct, openDrawer: false)
    }
    
    func printOrderKitchenSlip(orderId: String){
        let order = NIMBUS.OrderManagement?.getOrder(byId: orderId)
        let orderAsStruct = orderSchema(withManagedObject: order)
        NIMBUS.Print?.printOrderKitchenSlip(order: orderAsStruct)
    }
    
    func uploadOrder(orderMO: Order) -> Bool {
        return orderServer.uploadOrder(orderMO: orderMO)
    }
    
    func purgeOutOfLocalHistoryLimitOrders(){
        let orderHistoryLimit: Int = NIMBUS.Data?.localOrderHistoryLimit ?? 7
        let syncOrdersAsOfDate: Date = Date().startOfDay.addingTimeInterval(-TimeInterval(1*60*60*24*orderHistoryLimit))
        
        let outOfScopePredicate = NSPredicate(format: "createdAt < %@", syncOrdersAsOfDate as NSDate)
        let outOfScopeOrders = getOrders(fetchPredicate: outOfScopePredicate)
        
        DispatchQueue.main.async {
            outOfScopeOrders.forEach{order in
                self.managedContext.delete(order)
            }
        }
    }
    
}
