//
//  OrderItemsSelectionManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-03.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

protocol OrderItemsSelectionManagerDelegate {
    func showTableView()
    func showProductsView()
    func showCustomersView()
    func showLoyaltyView()
}

class OrderItemsSelectionManager: UIViewController, OrderItemsSelectionManagerDelegate {
    var headerView: UIViewWithShadow = UIViewWithShadow()
    var contentView: UIView = UIView()
    var segmentedViewSelector: UISegmentedControl = UISegmentedControl()
    let segments: [String] = ["Tables", "Products", "Customers", "Loyalty"]
    
    let tablesVC = OrderTablesView()
    
    let productsVC = OrderProductsViewManager()
    
    let customersVC = OrderCustomersView()
    
    let loyaltyVC = OrderLoyaltyView()
    
    //Open Order
    var openOrderMode: _OpenOrderModes? {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NIMBUS.OrderCreation?.orderItemsSelectionManagerDelegate = self
        
        segmentedViewSelector.insertSegment(withTitle: segments[0], at: 0, animated: true)
        segmentedViewSelector.insertSegment(withTitle: segments[1], at: 1, animated: true)
        segmentedViewSelector.insertSegment(withTitle: segments[2], at: 2, animated: true)
        segmentedViewSelector.insertSegment(withTitle: segments[3], at: 3, animated: true)
        
        headerView.setDefaultElevation()
        
        headerView.addSubview(segmentedViewSelector)
        self.view.addSubview(headerView)
        self.view.addSubview(contentView)
        self.view.bringSubview(toFront: headerView)
        
        segmentedViewSelector.addTarget(self, action: #selector(segmentedControlValueChange), for: .valueChanged)
        
        segmentedViewSelector.selectedSegmentIndex = 1
        loadAllViews()
        showProductsView()
    }
    
    override func viewWillLayoutSubviews() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 55).isActive = true
        
        segmentedViewSelector.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: segmentedViewSelector, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: segmentedViewSelector, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: segmentedViewSelector, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.width, multiplier: 0.66, constant: 0).isActive = true
        NSLayoutConstraint(item: segmentedViewSelector, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.height, multiplier: 0.8, constant: 0).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func segmentedControlValueChange(){
        
        switch segmentedViewSelector.selectedSegmentIndex
        {
            case 0:
                showTableView()
            case 1:
                showProductsView()
            case 2:
                showCustomersView()
            case 3:
                showLoyaltyView()
            default: break
        }
    }
    
    func loadAllViews(){
        self.addChildViewController(tablesVC)
        self.contentView.addSubview(tablesVC.view)
        tablesVC.view.frame = contentView.frame
        tablesVC.didMove(toParentViewController: self)
        
        self.addChildViewController(productsVC)
        self.contentView.addSubview(productsVC.view)
        productsVC.view.frame = contentView.frame
        productsVC.didMove(toParentViewController: self)
        
        self.addChildViewController(customersVC)
        self.contentView.addSubview(customersVC.view)
        customersVC.view.frame = contentView.frame
        customersVC.didMove(toParentViewController: self)
        
        self.addChildViewController(loyaltyVC)
        self.contentView.addSubview(loyaltyVC.view)
        loyaltyVC.view.frame = contentView.frame
        loyaltyVC.didMove(toParentViewController: self)
    }
    
    func showTableView(){
        contentView.bringSubview(toFront: tablesVC.view)
        tablesVC.view.isHidden = false
        productsVC.view.isHidden = true
        customersVC.view.isHidden = true
        loyaltyVC.view.isHidden = true
        
        if segmentedViewSelector.selectedSegmentIndex != 0 {
            segmentedViewSelector.selectedSegmentIndex = 0
        }
    }
    
    func showProductsView(){
        contentView.bringSubview(toFront: productsVC.view)
        tablesVC.view.isHidden = true
        productsVC.view.isHidden = false
        customersVC.view.isHidden = true
        loyaltyVC.view.isHidden = true
        
        if segmentedViewSelector.selectedSegmentIndex != 1 {
            segmentedViewSelector.selectedSegmentIndex = 1
        }
    }
    
    func showCustomersView(){
        contentView.bringSubview(toFront: customersVC.view)
        tablesVC.view.isHidden = true
        productsVC.view.isHidden = true
        customersVC.view.isHidden = false
        loyaltyVC.view.isHidden = true
        
        if segmentedViewSelector.selectedSegmentIndex != 2 {
            segmentedViewSelector.selectedSegmentIndex = 2
        }
    }
    
    func showLoyaltyView(){
        contentView.bringSubview(toFront: loyaltyVC.view)
        tablesVC.view.isHidden = true
        productsVC.view.isHidden = true
        customersVC.view.isHidden = true
        loyaltyVC.view.isHidden = false
        
        if segmentedViewSelector.selectedSegmentIndex != 3 {
            segmentedViewSelector.selectedSegmentIndex = 3
        }
    }
    
    func disableCustomersAndLoyalty(){
        segmentedViewSelector.setEnabled(false, forSegmentAt: 2)
        segmentedViewSelector.setEnabled(false, forSegmentAt: 3)
    }
    
    func enableCustomersAndLoyalty(){
        segmentedViewSelector.setEnabled(true, forSegmentAt: 2)
        segmentedViewSelector.setEnabled(true, forSegmentAt: 3)
    }
}
