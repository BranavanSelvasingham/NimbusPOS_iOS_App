//
//  OrderHistoryListViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class OrderHistoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    var orderListManagerDelegate: OrderHistoryManagerDelegate?
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(OrderHistoryListCell.self, forCellReuseIdentifier: "orderHistoryListCell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        return tableView
    }()
    
    var selectedOrder: Order? {
        didSet {
            updateSelectedOrder()
        }
    }
    
    var orderSearchBar: UISearchBar = {
        let orderSearchBar = UISearchBar()
        orderSearchBar.scopeButtonTitles = ["Order#", "Daily#", "Customer"]
        orderSearchBar.showsScopeBar = true
        orderSearchBar.searchBarStyle = .minimal
        orderSearchBar.scopeBarBackgroundImage = UIImage.imageWithColor(color: UIColor.clear)
        return orderSearchBar
    }()
    
    let searchScopes = [0: "Order#", 1: "Daily#", 2: "Customer"]
    
    var searchForOrder_Text: String = "" {
        didSet {
            refreshOrdersList()
        }
    }
    
    var searchForOrder_ScopeIndex: Int = 0 {
        didSet{
            refreshOrdersList()
        }
    }
    
    var fetchedOrders: [Order] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        orderSearchBar.delegate = self
        
        refreshOrdersList()
        
        self.view.addSubview(tableView)
        self.view.addSubview(orderSearchBar)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange),
                                       name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: NIMBUS.OrderCreation?.managedContext)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        orderSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderSearchBar, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderSearchBar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderSearchBar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderSearchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: orderSearchBar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Order.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription,
                                                                    notification: notification,
                                                                    callFunction: self.ordersUpdated)
    }
    
    func refreshOrdersList(){
        self.fetchedOrders = NIMBUS.OrderManagement?.searchForOrder(searchText: searchForOrder_Text, searchScope: searchScopes[searchForOrder_ScopeIndex]!) ?? []
    }
    
    func ordersUpdated(){
        refreshOrdersList()
        updateSelectedOrder()
    }
    
    func updateSelectedOrder(){
        if let selectedOrder = selectedOrder {
            orderListManagerDelegate?.orderSelected(order: selectedOrder)
        }
    }

    //Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderHistoryListCell", for: indexPath) as! OrderHistoryListCell
        let indexOrderItem = fetchedOrders[indexPath.row]
        cell.initCell(cellOrder: indexOrderItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOrder = fetchedOrders[indexPath.row]
    }


    //Search Bar
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchForOrder_ScopeIndex = selectedScope
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchForOrder_Text = searchBar.text ?? ""
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchForOrder_Text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchForOrder_Text = searchBar.text ?? ""
    }
}
