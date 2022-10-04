//
//  OpenOrderCollectionVC.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-27.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation


class OpenOrdersCollectionVC: UICollectionViewController {
    
    var openOrderManagerDelegate: OpenOrdersManagerDelegate?
    
    var openOrders: [Order] = [] {
        didSet {
            loadOpenOrdersData()
        }
    }
    
    var openOrdersData: [openOrderDataStruct] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    struct openOrderDataStruct {
        let order: Order
        let orderSlipController: OpenOrderSlipViewController
        let orderSlipView: UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.clear
        self.collectionView?.register(OpenOrdersCollectionViewCell.self, forCellWithReuseIdentifier: "OpenOrdersCell")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange),
                                       name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: NIMBUS.OrderCreation?.managedContext)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshOpenOrders()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Order.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription,
                                                                    notification: notification,
                                                                    callFunction: self.refreshOpenOrders)
    }
    
    func refreshOpenOrders(){
        openOrdersData = []
        openOrders = NIMBUS.OrderManagement?.getOpenOrdes() ?? []
    }
    
    func loadOpenOrdersData(){
        openOrders.forEach{ openOrder in
            let vc = OpenOrderSlipViewController()
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            vc.order = openOrder
            
            let openOrderData = openOrderDataStruct(order: openOrder, orderSlipController: vc, orderSlipView: vc.view)
            self.openOrdersData.append(openOrderData)
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return openOrdersData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OpenOrdersCell", for: indexPath) as! OpenOrdersCollectionViewCell
        let indexOpenOrderData = openOrdersData[indexPath.row]
        cell.initCell(order: indexOpenOrderData.order, receiptView: indexOpenOrderData.orderSlipView)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
