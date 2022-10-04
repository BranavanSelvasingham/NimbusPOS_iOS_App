//
//  addOnsOptions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddOnsOptionsView: UIViewController{
    var selectedAddOnsList = [orderItemAddOns]()
    var associatedAddOnsList = [orderItemAddOns]()
    var genericAddOnsList = [orderItemAddOns]()
    
    var addOnsTableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        addOnsTableView.delegate = self
        addOnsTableView.dataSource = self
        
        addOnsTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        addOnsTableView.register(addOnsItemSelectedAddOns.self, forCellReuseIdentifier: "selectedAddOnsCell")
        addOnsTableView.register(addOnsItemAssociatedAddOns.self, forCellReuseIdentifier: "associatedAddOnsCell")
        addOnsTableView.register(addOnsItemGeneralAddOns.self, forCellReuseIdentifier: "generalAddOnsCell")
        
        self.addOnsTableView.estimatedRowHeight = 50
        self.addOnsTableView.rowHeight = UITableViewAutomaticDimension
        self.view.addSubview(addOnsTableView)
        
        refreshAddOnsData()
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.Products?.managedContext)
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = ProductAddOn.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshAddOnsData)
    }
    
    override func viewWillLayoutSubviews() {
        addOnsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: addOnsTableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addOnsTableView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addOnsTableView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addOnsTableView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addOnsTableView.reloadData()
    }
    
}

extension AddOnsOptionsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSectionTitle(forSection: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return getNumberOfRowsInSelectedAddOns(tableView: tableView, numberOfRowsInSection: section)
        } else if section == 1 {
            return getNumberOfRowsInAssociatedAddOns(tableView: tableView, numberOfRowsInSection: section)
        } else {
            return getNumberOfRowsInGeneralAddOns(tableView: tableView, numberOfRowsInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getItemSelectedAddOnCells(tableView: tableView, cellForRowAt: indexPath)
        } else if indexPath.section == 1 {
            return getItemAssociatedAddOnCells(tableView: tableView, cellForRowAt: indexPath)
        } else {
            return getGeneralAddOnCells(tableView: tableView, cellForRowAt: indexPath)
        }
    }
}

extension AddOnsOptionsView: UITableViewDelegate {

}

extension AddOnsOptionsView {
    func getSectionTitle(forSection section: Int)->String {
        let sectionTitles = ["Selected Add-Ons: (click to remove)", "Associated Add-Ons:", "General Add-Ons:"]
        return sectionTitles[section]
    }
    
    func getNumberOfRowsInSelectedAddOns(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedAddOnsList.count
    }
    
    func getNumberOfRowsInAssociatedAddOns(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.associatedAddOnsList.count
    }

    func getNumberOfRowsInGeneralAddOns(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.genericAddOnsList.count
    }
    
    func getItemSelectedAddOnCells(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedAddOnsCell", for: indexPath) as! addOnsItemSelectedAddOns
        let indexAddOnItem = selectedAddOnsList[indexPath.row]
        cell.initCell(cellAddOnItem: indexAddOnItem, cellIndexPath: indexPath)
        return cell
    }

    func getItemAssociatedAddOnCells(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "associatedAddOnsCell", for: indexPath) as! addOnsItemAssociatedAddOns
        let indexAddOnItem = associatedAddOnsList[indexPath.row]
        cell.initCell(cellAddOnItem: indexAddOnItem, cellIndexPath: indexPath)
        return cell
    }
    
    func getGeneralAddOnCells(tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalAddOnsCell", for: indexPath) as! addOnsItemGeneralAddOns
        let indexAddOnItem = genericAddOnsList[indexPath.row]
        cell.initCell(cellAddOnItem: indexAddOnItem, cellIndexPath: indexPath)
        return cell
    }
    
    func refreshAddOnsData(){
        self.selectedAddOnsList = NIMBUS.OrderCreation?.getItemSelectedAddOns() ?? []
        self.associatedAddOnsList = NIMBUS.OrderCreation?.getItemAssociatedAddOns() ?? []
        self.genericAddOnsList = NIMBUS.OrderCreation?.getItemUnassociatedAddOns() ?? []
        self.addOnsTableView.reloadData()
    }
}
