//
//  EmployeeListTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

class EmployeeListTableViewController: UITableViewController {
    var selectedEmployee: Employee?
    var employeeViewManagerDelegate: EmployeesViewManagerDelegate?
    var fetchedEmployees = [Employee](){
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchedEmployees = NIMBUS.Employees?.fetchAllEmployees() ?? []
        
        self.tableView.register(EmployeeListTableViewCell.self, forCellReuseIdentifier: "employeeListTableViewCell")
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object:NIMBUS.Employees?.managedContext)
        
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshEmployees), for: .valueChanged)
    }
    
    func refreshEmployees(_ sender: Any){
        self.fetchedEmployees = NIMBUS.Employees?.fetchAllEmployees() ?? []
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Employee.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: self.refreshTable)
    }
    
    func refreshTable(){
        self.fetchedEmployees = NIMBUS.Employees?.fetchAllEmployees() ?? []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedEmployees.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeListTableViewCell", for: indexPath) as! EmployeeListTableViewCell
        let indexEmployee = fetchedEmployees[indexPath.row]
        cell.initCell(employee: indexEmployee)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! EmployeeListTableViewCell
        self.selectedEmployee = selectedCell.employee
        employeeViewManagerDelegate?.employeeSelected(employee: self.selectedEmployee!)
    }

}
