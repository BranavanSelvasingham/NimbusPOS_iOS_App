//
//  HoursView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

protocol HoursViewDelegate {
    func dismissNewHourEntryModal()
}

class HoursView: UIViewController, HoursViewDelegate{
    var authenticatedEmployee: Employee?{
        didSet {
            hourEntryViewController.employee = authenticatedEmployee
            refreshEmployeeHours()
        }
    }
    
    var fetchedHours = [EmployeeHours](){
        didSet{
            hoursTableView.reloadData()
        }
    }
    
    let headerHeight: CGFloat = 50
    var headerView: UIViewWithShadow = UIViewWithShadow()
    var hoursTableView: UITableView = UITableView()
    var buttonBarView: UIView = UIView()
    var buttonBar: MDCButtonBar = MDCButtonBar()
    var newEntryButton: UIBarButtonItem = UIBarButtonItem()
    var hourEntryModal: SlideOverModalView = SlideOverModalView()
    var hourEntryViewController: HourEntryViewController = HourEntryViewController()
    
    override func viewDidLoad() {
        newEntryButton = UIBarButtonItem(image: UIImage(named: "ic_add"), style: .plain, target: self, action: #selector(addNewHourEntry))
        
        buttonBar.items = [newEntryButton]
        buttonBarView.addSubview(buttonBar)
        headerView.addSubview(buttonBarView)
        headerView.shadowLayer.elevation = .switch
        self.view.addSubview(headerView)
        
        self.hoursTableView.dataSource = self
        self.hoursTableView.delegate = self
        
        self.view.addSubview(hoursTableView)
        
        self.hoursTableView.register(HoursTableViewCell.self, forCellReuseIdentifier: "hoursTableViewCell")
        self.hoursTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.view.autoresizesSubviews = true
        self.hoursTableView.autoresizesSubviews = true
        
        self.view.bringSubview(toFront: headerView)
        
        let refreshControl = UIRefreshControl()
        self.hoursTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshEmployeeHours), for: .valueChanged)
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object:NIMBUS.EmployeeHours?.managedContext)
        
        //New Hour Entry Modal
        hourEntryViewController.hoursViewDelegate = self
        hourEntryModal = SlideOverModalView(frame: self.view.bounds)
        hourEntryModal.addViewToModal(view: hourEntryViewController.view)
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(dismissNewHourEntryModal))
        hourEntryModal.rightButtonBarActionButtons = [dismissButton]
        
        let saveButton = UIBarButtonItem(image: UIImage(named: "ic_save"), style: .plain, target: self, action: #selector(saveNewHourEntry))
        hourEntryModal.leftButtonBarActionButtons = [saveButton]
        
        hourEntryViewController.didMove(toParentViewController: self)
        
        self.view.addSubview(hourEntryModal)
        self.view.bringSubview(toFront: hourEntryModal)
    }
    
    func dismissNewHourEntryModal(){
        hourEntryModal.dismissModal()
    }
    
    func saveNewHourEntry(){
        hourEntryViewController.saveHourEntry()
    }
    
    func addNewHourEntry(){
        hourEntryModal.presentModal()
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = EmployeeHours.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: self.refreshEmployeeHours)
    }
    
    override func viewWillLayoutSubviews() {
        let hoursTableOrigin = CGPoint(x: 0, y: headerHeight)
        let hoursTableSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - headerHeight)
        self.hoursTableView.frame = CGRect(origin: hoursTableOrigin, size: hoursTableSize)
        
        self.headerView.frame = CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: headerHeight))
        
        buttonBarView.frame = headerView.frame
        
        let size = buttonBar.sizeThatFits(buttonBarView.frame.size)
        buttonBar.frame = CGRect(x: buttonBarView.frame.width - size.width, y: 0, width: size.width, height: buttonBarView.frame.height)
        
        hourEntryModal.resizeView(frame: self.view.bounds)
    }
    
    func refreshEmployeeHours(){
        self.fetchedHours = NIMBUS.EmployeeHours?.fetchAllEmployeeHoursby(employeeId: authenticatedEmployee?.id ?? "") ?? []
        self.hoursTableView.refreshControl?.endRefreshing()
    }
}

extension HoursView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableColumnsHeader = UIViewWithShadow(frame: CGRect(origin: .zero, size: CGSize(width: tableView.contentSize.width, height: 30)))
        
        let dateHeadingLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: tableColumnsHeader.frame.width/4, height: tableColumnsHeader.frame.height)))
        let checkInHeadingLabel = UILabel(frame: CGRect(origin: CGPoint(x: dateHeadingLabel.frame.width, y: 0), size: CGSize(width: tableColumnsHeader.frame.width/4, height: tableColumnsHeader.frame.height)))
        let checkOutHeadingLabel = UILabel(frame: CGRect(origin: CGPoint(x: dateHeadingLabel.frame.width * 2, y: 0), size: CGSize(width: tableColumnsHeader.frame.width/4, height: tableColumnsHeader.frame.height)))
        
        dateHeadingLabel.text = "Date"
        checkInHeadingLabel.text = "Check-In"
        checkOutHeadingLabel.text = "Check-Out"
        
        dateHeadingLabel.font = MDCTypography.body2Font()
        checkInHeadingLabel.font = MDCTypography.body2Font()
        checkOutHeadingLabel.font = MDCTypography.body2Font()
        
        tableColumnsHeader.addSubview(dateHeadingLabel)
        tableColumnsHeader.addSubview(checkInHeadingLabel)
        tableColumnsHeader.addSubview(checkOutHeadingLabel)
        
        tableColumnsHeader.backgroundColor = UIColor.lightGray
        
        return tableColumnsHeader
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedHours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hoursTableViewCell", for: indexPath) as! HoursTableViewCell
        let indexHour = fetchedHours[indexPath.row]
        cell.initCell(hourEntry: indexHour)
        return cell
    }

}
