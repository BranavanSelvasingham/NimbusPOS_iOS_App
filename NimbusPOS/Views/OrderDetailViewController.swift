//
//  OrderHistoryDetailViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class OrderDetailViewController: UIViewController {
    var order: Order? {
        didSet {
            refreshOrder()
        }
    }
    var orderHistoryManagerDelegate: OrderHistoryManagerDelegate?
    
    var orderReceiptViewController: OrderReceiptViewController = OrderReceiptViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gray
        loadReceipt()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        layoutReceipt()
    }
    
    func loadReceipt(){
        self.addChildViewController(orderReceiptViewController)
        orderReceiptViewController.didMove(toParentViewController: self)
        self.view.addSubview(orderReceiptViewController.view)
    }
    
    func layoutReceipt(){
        let receiptView = orderReceiptViewController.view!
        receiptView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: receiptView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func deleteOrder(){
        if let orderId = order?.id {
            NIMBUS.OrderManagement?.cancelOrder(orderId: orderId)
        }
    }
    
    func refreshOrder(){
        orderReceiptViewController.orderMO = order
    }
}
