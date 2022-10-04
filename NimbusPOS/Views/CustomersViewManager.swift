//
//  CustomersViewManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol CustomersViewManagerDelegate {
    func customerSelected(customer: Customer)
    func dismissNewCustomerModal()
    func highlightCustomer(customerId: String)
}

class CustomersViewManager: UIViewController, CustomersViewManagerDelegate {
    var customerListTableViewController: CustomerListTableViewController = CustomerListTableViewController()
    var customerDetailViewController: CustomerDetailView = CustomerDetailView()
    var customerCreateViewController: NewCustomerViewController = NewCustomerViewController()
    var customerCreateModal: SlideOverModalView = SlideOverModalView()
    
    var pageView: PageView = PageView()
    
    var selectedCustomer: Customer? {
        didSet{
            customerDetailViewController.customer = selectedCustomer
        }
    }
    
    override func viewDidLoad() {
        pageView = PageView(frame: self.view.frame)
        pageView.leftSection.setHeaderTitle(title: "Customers")
        
        let addCustomerButton = UIBarButtonItem(image: UIImage(named: "ic_add"), style: .plain, target: self, action: #selector(addNewCustomer))
        pageView.leftSection.buttonBarActionButtons = [addCustomerButton]
        
        customerListTableViewController = CustomerListTableViewController()
        customerListTableViewController.customerViewManagerDelegate = self
        self.addChildViewController(customerListTableViewController)
        pageView.addTableViewToLeftSection(tableView: customerListTableViewController.view)
        customerListTableViewController.didMove(toParentViewController: self)
        
        customerDetailViewController.customerViewManagerDelegaete = self
        self.addChildViewController(customerDetailViewController)
        pageView.addDetailViewToRightSection(detailView: customerDetailViewController.view)
        customerDetailViewController.didMove(toParentViewController: self)
        
        self.view.addSubview(pageView)
        
        customerCreateViewController = NewCustomerViewController()
        customerCreateViewController.customerViewManagerDelegate = self
        self.addChildViewController(customerCreateViewController)
        customerCreateModal = SlideOverModalView(frame: self.view.frame)
        customerCreateModal.addViewToModal(view: customerCreateViewController.view)
        customerCreateModal.headerTitle = "New Customer"
        
        let dismissButton = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(dismissNewCustomerModal))
        customerCreateModal.rightButtonBarActionButtons = [dismissButton]
        
        let saveNewNoteButton = UIBarButtonItem(image: UIImage(named: "ic_save"), style: .plain, target: self, action: #selector(saveNewCustomer))
        customerCreateModal.leftButtonBarActionButtons = [saveNewNoteButton]
        
        customerCreateViewController.didMove(toParentViewController: self)
        
        self.view.addSubview(customerCreateModal)
        self.view.bringSubview(toFront: customerCreateModal)
    }
    
    override func viewWillLayoutSubviews() {
        pageView.frame = self.view.frame
    }
    
    func addNewCustomer(){
        customerCreateModal.presentModal()
    }
    
    func dismissNewCustomerModal(){
        customerCreateModal.dismissModal()
    }
    
    func saveNewCustomer(){
        customerCreateViewController.createNewCustomer()
    }
    
    func customerSelected(customer: Customer) {
        self.selectedCustomer = customer
    }
    
    func highlightCustomer(customerId: String) {
        if let customer = NIMBUS.Customers?.getCustomerById(id: customerId){
            customerListTableViewController.highlightCustomerRow(customerId: customerId)
            customerSelected(customer: customer)
        }
        
    }
    
}
