//
//  EmployeesViewManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol EmployeesViewManagerDelegate {
    func employeeSelected(employee: Employee)

}

class EmployeesViewManager: UIViewController, EmployeesViewManagerDelegate, EmployeeAuthenticateDelegate {
    var employeesTableViewController: EmployeeListTableViewController = EmployeeListTableViewController()
    var employeesDetailViewController: EmployeeDetailsViewController = EmployeeDetailsViewController()
    var employeeAuthenticateViewController: EmployeeAuthenticateViewController = EmployeeAuthenticateViewController()
    
    var pageView: PageView = PageView()
    
    var selectedEmployee: Employee? {
        didSet{
            showEmployeeAuthenticateView()
        }
    }
    
    override func viewDidLoad() {
        NIMBUS.EmployeeHours?.syncEmployeeHoursServerDataToLocal()
        
        pageView = PageView(frame: self.view.frame)
        pageView.leftSection.setHeaderTitle(title: "Employees")
        
//        let addNoteButton = UIBarButtonItem(image: UIImage(named: "ic_add"), style: .plain, target: self, action: #selector(addNewNote))
//        pageView.leftSection.buttonBarActionButtons = [addNoteButton]

        employeesTableViewController = EmployeeListTableViewController()
        employeesTableViewController.employeeViewManagerDelegate = self
        self.addChildViewController(employeesTableViewController)
        pageView.addTableViewToLeftSection(tableView: employeesTableViewController.view)
        employeesTableViewController.didMove(toParentViewController: self)
//
//        let deleteButton = UIBarButtonItem(image: UIImage(named: "ic_delete"), style: .plain, target: self, action: #selector(deleteSelectedNote))
//        pageView.rightSection.buttonBarActionButtons = [deleteButton]
        
        loadEmployeeDetails()
        loadEmployeeAuthenticate()
        
        self.view.addSubview(pageView)
    }
    
    func loadEmployeeDetails(){
        employeesDetailViewController = EmployeeDetailsViewController()
        employeesDetailViewController.employeeViewManagerDelegate = self
        self.addChildViewController(employeesDetailViewController)
        employeesDetailViewController.didMove(toParentViewController: self)
    }
    
    func loadEmployeeAuthenticate(){
        employeeAuthenticateViewController = EmployeeAuthenticateViewController()
        employeeAuthenticateViewController.authenticationRequestorDelegate = self
        self.addChildViewController(employeeAuthenticateViewController)
        employeeAuthenticateViewController.didMove(toParentViewController: self)
    }
    
    func showEmployeeAuthenticateView(){
        pageView.addDetailViewToRightSection(detailView: employeeAuthenticateViewController.view)
        employeeAuthenticateViewController.employee = selectedEmployee
    }
    
    func showEmployeeDetailView(){
        pageView.addDetailViewToRightSection(detailView: employeesDetailViewController.view)
        employeesDetailViewController.employeeSelected(employee: selectedEmployee!)
    }
    
    override func viewWillLayoutSubviews() {
        pageView.frame = self.view.frame
    }
    
    func employeeSelected(employee: Employee) {
        self.selectedEmployee = employee
    }
    
    func employeeAuthenticated(employee: Employee) {
        showEmployeeDetailView()
    }
    
    func employeeAuthenticationAborted() {
        
    }
    
    func employeeAuthenticationFailed() {
        
    }
    
    func employeeLoggedOut(employee: Employee?) {
        
    }
}
