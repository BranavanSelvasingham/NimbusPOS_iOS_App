//
//  orderTablesView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-20.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreGraphics

class OrderTablesView: UIViewController, TablesListDelegate{
    
    var headerView: UIView = UIView()
    var contentView: UIView = UIView()
    
    var tablesListVC: TablesListTableViewController = TablesListTableViewController()
    
    override func viewDidLoad() {
        
        self.view.addSubview(headerView)
        self.view.addSubview(contentView)
        
        self.view.backgroundColor = UIColor.white
        
        self.addChildViewController(tablesListVC)
        self.contentView.addSubview(tablesListVC.view)
        tablesListVC.view.frame = contentView.frame
        tablesListVC.didMove(toParentViewController: self)
        tablesListVC.tablesListDelegate = self
    }
    
    override func viewWillLayoutSubviews() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 10).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func selectTable(table: Table) {
        NIMBUS.OrderCreation?.table = table
    }
}
