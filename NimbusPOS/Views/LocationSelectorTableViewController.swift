//
//  LocationSelectorTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

protocol locationSelectorProtocol {
    func locationSelected(location: Location)
}

class LocationSelectorTableViewController: UITableViewController {
    
    var allLocations = [Location]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var locationSelectorDelegate: locationSelectorProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.Location?.managedContext)
        
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshLocationsList), for: .valueChanged)
        
        refreshLocationsList()
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Location.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshLocationsList)
    }
    
    func refreshLocationsList(){
        allLocations = NIMBUS.Location?.getAllLocations() ?? []
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationSelectorCell", for: indexPath) as! LocationSelectorTableViewCell
        cell.initCell(location: allLocations[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = allLocations[indexPath.row]
        locationSelectorDelegate?.locationSelected(location: selectedLocation)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let cell = cell as! LocationSelectorTableViewCell
//        if let deviceLocationId = NIMBUS.Location?.getLocationId() {
//            if deviceLocationId == cell.location?.id {
//                cell.isUserInteractionEnabled = false
//                cell.backgroundColor = UIColor.lightGray
//            }
//        }
//    }
}
