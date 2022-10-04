//
//  OpenOrderSlipViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-28.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class OpenOrderSlipViewController: UIViewController {
    var order: Order? {
        didSet {
            orderReceiptViewController.orderMO = order
        }
    }
    
    var orderReceiptViewController: OrderReceiptViewController = OrderReceiptViewController()
    
    let footerView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.setDefaultElevation()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return view
    }()
    
    let deleteButton: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_delete_white"), for: .normal)
        button.addTarget(self, action: #selector(deleteOrder), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let printButton: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_print_white"), for: .normal)
        button.addTarget(self, action: #selector(printOrder), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let editButton: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_edit_white"), for: .normal)
        button.addTarget(self, action: #selector(editOrder), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let checkoutButton: MDCButton = {
        let button = MDCButton()
        button.setTitle("Checkout", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(checkoutOrder), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadReceipt()
        loadFooter()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutReceipt()
        layoutFooter()
    }
    
    func loadFooter(){
        self.view.addSubview(footerView)
        self.view.bringSubview(toFront: footerView)
        footerView.backgroundColor = UIColor.darkGray
        
        self.footerView.addSubview(printButton)
        self.footerView.addSubview(deleteButton)
        self.footerView.addSubview(editButton)
        self.footerView.addSubview(checkoutButton)
    }
    
    func layoutFooter(){
//        let receiptView = orderReceiptViewController.receiptView
//        let topConstraint = NSLayoutConstraint(item: footerView, attribute: .top, relatedBy: .equal, toItem: receiptView, attribute: .bottom, multiplier: 1, constant: 30)
//        topConstraint.priority = 1
//        topConstraint.isActive = true
//        NSLayoutConstraint(item: footerView, attribute: .top, relatedBy: .lessThanOrEqual, toItem: view, attribute: .bottom, multiplier: 1, constant: 300).isActive = true
        
        NSLayoutConstraint(item: footerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: footerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: footerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -5).isActive = true
        
        NSLayoutConstraint(item: printButton, attribute: .centerY, relatedBy: .equal, toItem: footerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printButton, attribute: .leading, relatedBy: .equal, toItem: footerView, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        
        NSLayoutConstraint(item: editButton, attribute: .centerY, relatedBy: .equal, toItem: footerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: editButton, attribute: .leading, relatedBy: .equal, toItem: printButton, attribute: .trailing, multiplier: 1, constant: 20).isActive = true
        
        NSLayoutConstraint(item: checkoutButton, attribute: .centerY, relatedBy: .equal, toItem: footerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: checkoutButton, attribute: .leading, relatedBy: .equal, toItem: editButton, attribute: .trailing, multiplier: 1, constant: 20).isActive = true
        
        NSLayoutConstraint(item: deleteButton, attribute: .centerY, relatedBy: .equal, toItem: footerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: deleteButton, attribute: .trailing, relatedBy: .equal, toItem: footerView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
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
        NSLayoutConstraint(item: receiptView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .bottom, relatedBy: .equal, toItem: footerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
    }
    
    func deleteOrder(){
        if let orderId = order?.id {
            NIMBUS.OrderManagement?.cancelOrder(orderId: orderId)
        }
    }
    
    func printOrder(){
        if let orderId = order?.id {
            NIMBUS.OrderManagement?.printOrderKitchenSlip(orderId: orderId)
        }
    }
    
    func editOrder(){
        if let orderId = order?.id {
            NIMBUS.Navigation?.loadOpenOrderForEdit(orderId: orderId)
        }
    }
    
    func checkoutOrder(){
        if let orderId = order?.id {
            NIMBUS.Navigation?.loadOpenOrderForCheckout(orderId: orderId)
        }
    }
    
}
