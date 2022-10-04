//
//  orderCustomerView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-20.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class OrderCustomersView: UIViewController, CustomersViewManagerDelegate {
    var headerView: UIViewWithShadow = UIViewWithShadow()
    let headerHeight: CGFloat = 60
    var contentView: UIView = UIView()
    
    var clearCustomerButton: UIButton = UIButton()
    var createCustomerButton: UIButton = UIButton()
    var customerNameLabel: UILabel = UILabel()

    var searchCustomersView: UIView = UIView()
    var selectedCustomerDetailView: UIView = UIView()
    var selectedCustomerCardsView: UIView = UIView()
    
    var customerCreateViewController: NewCustomerViewController = NewCustomerViewController()
    var customerCreateModal: SlideOverModalView = SlideOverModalView()
    
    var customerSearchViewController: CustomerListTableViewController = CustomerListTableViewController()
    var customerAttributesViewController: CustomerAttributesViewController = CustomerAttributesViewController()
    var customerCardsViewController: OrderViewCustomerLoyaltyCardsTableViewController = OrderViewCustomerLoyaltyCardsTableViewController()
    
    var selectedCustomer: Customer? {
        didSet {
            if selectedCustomer != nil {
                showSelectedCustomerView()
                NIMBUS.OrderCreation?.customer = selectedCustomer
                customerCardsViewController.customer = selectedCustomer
                customerAttributesViewController.customer = selectedCustomer
                customerNameLabel.text = selectedCustomer?.name
            } else {
                NIMBUS.OrderCreation?.clearCustomerInfo()
                customerNameLabel.text = ""
                showCustomerSearchView()
            }
        }
    }
    
    override func viewDidLoad() {
        clearCustomerButton.setImage(UIImage(named: "ic_clear_36pt"), for: .normal)
        clearCustomerButton.addTarget(self, action: #selector(clearCustomer), for: .touchUpInside)
        clearCustomerButton.contentMode = .center
//        clearCustomerButton.setBackgroundColor(UIColor.clear)
        
        createCustomerButton.setImage(UIImage(named: "ic_person_add_36pt"), for: .normal)
        createCustomerButton.addTarget(self, action: #selector(newCustomer), for: .touchUpInside)
        createCustomerButton.contentMode = .center
//        createCustomerButton.setBackgroundColor(UIColor.clear)
        
        customerNameLabel.font = MDCTypography.titleFont()
        customerNameLabel.textAlignment = .center
        
        headerView.backgroundColor = UIColor.clear
        contentView.addSubview(createCustomerButton)
        
        headerView.addSubview(clearCustomerButton)
        headerView.addSubview(customerNameLabel)
        contentView.addSubview(headerView)
        contentView.addSubview(searchCustomersView)
        contentView.addSubview(selectedCustomerDetailView)
        contentView.addSubview(selectedCustomerCardsView)
        
        contentView.sendSubview(toBack: headerView)
        self.view.addSubview(contentView)
        
        selectedCustomerDetailView.layer.borderColor = UIColor.lightGray.cgColor
        selectedCustomerDetailView.layer.borderWidth = 1
        
        selectedCustomerCardsView.layer.borderColor = UIColor.lightGray.cgColor
        selectedCustomerCardsView.layer.borderWidth = 1
    
        self.addChildViewController(customerSearchViewController)
        customerSearchViewController.customerViewManagerDelegate = self
        self.searchCustomersView.addSubview(customerSearchViewController.view)
        customerSearchViewController.view.frame = searchCustomersView.frame
        customerSearchViewController.didMove(toParentViewController: self)
        
        self.addChildViewController(customerAttributesViewController)
        self.selectedCustomerDetailView.addSubview(customerAttributesViewController.view)
        customerAttributesViewController.view.frame = selectedCustomerDetailView.frame
        customerAttributesViewController.didMove(toParentViewController: self)
        
        self.addChildViewController(customerCardsViewController)
        self.selectedCustomerCardsView.addSubview(customerCardsViewController.view)
        customerCardsViewController.view.frame = selectedCustomerCardsView.frame
        customerCardsViewController.didMove(toParentViewController: self)
        
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headerView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: headerHeight).isActive = true
        
        clearCustomerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: clearCustomerButton, attribute: .width, relatedBy: .equal, toItem: headerView, attribute: .height, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: clearCustomerButton, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: clearCustomerButton, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: clearCustomerButton, attribute: .bottom, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        createCustomerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: createCustomerButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: headerHeight).isActive = true
        NSLayoutConstraint(item: createCustomerButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: headerHeight).isActive = true
        NSLayoutConstraint(item: createCustomerButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: createCustomerButton, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        customerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: customerNameLabel, attribute: .height, relatedBy: .equal, toItem: headerView, attribute: .height, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customerNameLabel, attribute: .width, relatedBy: .equal, toItem: headerView, attribute: .width, multiplier: 0.5, constant: 0).isActive = true
        NSLayoutConstraint(item: customerNameLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customerNameLabel, attribute: .centerX, relatedBy: .equal, toItem: headerView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        searchCustomersView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: searchCustomersView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: searchCustomersView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.7, constant: 0).isActive = true
        NSLayoutConstraint(item: searchCustomersView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: searchCustomersView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        selectedCustomerDetailView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: selectedCustomerDetailView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: selectedCustomerDetailView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.5, constant: 0).isActive = true
        NSLayoutConstraint(item: selectedCustomerDetailView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: selectedCustomerDetailView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        selectedCustomerCardsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: selectedCustomerCardsView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: selectedCustomerCardsView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.5, constant: 0).isActive = true
        NSLayoutConstraint(item: selectedCustomerCardsView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: selectedCustomerCardsView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        
        customerCreateModal.resizeView(frame: self.view.frame)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if selectedCustomer == nil {
            showCustomerSearchView()
        } else {
            showSelectedCustomerView()
        }
    }
    
    func clearCustomer() {
        selectedCustomer = nil
    }
    
    func newCustomer(){
        customerCreateModal.presentModal()
    }
    
    func showCustomerSearchView(){
        searchCustomersView.isHidden = false
        selectedCustomerDetailView.isHidden = true
        selectedCustomerCardsView.isHidden = true
        
        clearCustomerButton.isHidden = true
        createCustomerButton.isHidden = false
    }
    
    func showSelectedCustomerView(){
        searchCustomersView.isHidden = true
        selectedCustomerDetailView.isHidden = false
        selectedCustomerCardsView.isHidden = false
        
        clearCustomerButton.isHidden = false
        createCustomerButton.isHidden = true
    }
    
    func customerSelected(customer: Customer) {
        selectedCustomer = customer
    }
    
    func highlightCustomer(customerId: String) {
        if let customer = NIMBUS.Customers?.getCustomerById(id: customerId){
            customerSearchViewController.highlightCustomerRow(customerId: customerId)
            customerSelected(customer: customer)
        }
    }
    
    func dismissNewCustomerModal(){
        customerCreateModal.dismissModal()
    }
    
    func saveNewCustomer(){
        customerCreateViewController.createNewCustomer()
    }
}
