//
//  OrderWaiterSelectorManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-09.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class OrderWaiterSelectorManager: UIViewController, EmployeesViewManagerDelegate, EmployeeAuthenticateDelegate {
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    
    var employeesTableViewController: EmployeeListTableViewController = EmployeeListTableViewController()
    var employeeListView: UIViewWithShadow = UIViewWithShadow()
    
    var employeeAuthenticateViewController: EmployeeAuthenticateViewController = EmployeeAuthenticateViewController()
    var employeeAuthenticateView: UIView = UIView()
    
    var backButton: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_keyboard_arrow_left_48pt"), for: .normal)
        button.addTarget(self, action: #selector(showEmployeeListView), for: .touchUpInside)
        button.backgroundColor = UIColor.clear
        button.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 75).isActive = true
        button.widthAnchor.constraint(equalToConstant: 75).isActive = true
        return button
    }()
    
    var selectedEmployee: Employee? {
        didSet{
            showEmployeeAuthenticateView()
        }
    }
    
    override func viewDidLoad() {
        employeesTableViewController = EmployeeListTableViewController()
        employeesTableViewController.employeeViewManagerDelegate = self
        self.addChildViewController(employeesTableViewController)
        employeesTableViewController.didMove(toParentViewController: self)
        
        employeeAuthenticateViewController = EmployeeAuthenticateViewController()
        employeeAuthenticateViewController.authenticationRequestorDelegate = self
        self.addChildViewController(employeeAuthenticateViewController)
        employeeAuthenticateViewController.didMove(toParentViewController: self)
        
        employeeListView.addSubview(employeesTableViewController.view)
        employeeAuthenticateView.addSubview(employeeAuthenticateViewController.view)
        self.view.addSubview(employeeListView)
        self.view.addSubview(employeeAuthenticateView)
        self.view.bringSubview(toFront: employeeListView)
        
        employeeListView.setDefaultElevation()
        
        employeeAuthenticateView.addSubview(backButton)
        employeeAuthenticateView.bringSubview(toFront: backButton)
    }

    func showEmployeeAuthenticateView(){
        employeeAuthenticateViewController.employee = selectedEmployee
        employeeListView.isHidden = true
    }
    
    func showEmployeeListView(){
        self.employeeListView.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        employeeListView.frame = self.view.frame
        employeeAuthenticateView.frame = self.view.frame
        employeesTableViewController.view.frame = employeeListView.frame
        employeeAuthenticateViewController.view.frame = employeeAuthenticateView.frame
        
        NSLayoutConstraint(item: backButton, attribute: .top, relatedBy: .equal, toItem: employeeAuthenticateView, attribute: .top, multiplier: 1, constant: 150).isActive = true
        NSLayoutConstraint(item: backButton, attribute: .leading, relatedBy: .equal, toItem: employeeAuthenticateView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    }
    
    func employeeSelected(employee: Employee) {
        self.selectedEmployee = employee
        showEmployeeAuthenticateView()
    }
    
    func employeeAuthenticated(employee: Employee) {
        NIMBUS.OrderCreation?.waiter = employee
        orderViewManagerDelegate?.dismissWaiterSelectorModal()
    }
    
    func employeeAuthenticationAborted() {
        
    }
    
    func employeeAuthenticationFailed() {
        
    }
    
    func employeeLoggedOut(employee: Employee?) {
        NIMBUS.OrderCreation?.waiter = nil
        showEmployeeListView()
    }
}
