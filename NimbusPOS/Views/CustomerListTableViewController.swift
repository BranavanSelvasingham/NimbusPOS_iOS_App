//
//  CustomerListTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class CustomerListTableViewController: UIViewController {

    var customerViewManagerDelegate: CustomersViewManagerDelegate?
    
    let searchScopes = [0: "name", 1: "phone", 2: "email"]
    
    var customerSearchBar: UISearchBar = UISearchBar()
    var tableView: UITableView = UITableView()
    
    var fetchedCustomers = [Customer](){
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchForCustomer_Text: String = "" {
        didSet {
            refreshCustomers()
        }
    }
    var searchForCustomer_scopeIndex: Int = 0 {
        didSet{
            refreshCustomers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CustomerListTableViewCell.self, forCellReuseIdentifier: "customerTableViewCell")
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.view.addSubview(tableView)
    
        customerSearchBar.delegate = self
        customerSearchBar.scopeButtonTitles = ["Name", "Phone", "Email"]
        customerSearchBar.showsScopeBar = true
        customerSearchBar.searchBarStyle = .minimal
        customerSearchBar.scopeBarBackgroundImage = UIImage.imageWithColor(color: UIColor.clear)
        
        self.view.addSubview(customerSearchBar)
        
        refreshCustomers()
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.Customers?.managedContext)
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshCustomers), for: .valueChanged)
    }
    
    override func viewWillLayoutSubviews() {
        let tableOrigin: CGPoint = CGPoint(x: 0, y: 90)
        let tableSize: CGSize = CGSize(width: self.view.frame.width, height: self.view.frame.height - tableOrigin.y)
        self.tableView.frame = CGRect(origin: tableOrigin, size: tableSize)
        self.customerSearchBar.frame = CGRect(origin: .zero, size: CGSize(width: self.view.frame.width, height: tableOrigin.y))
    }
    
    func refreshCustomers(){
        tableView.refreshControl?.beginRefreshing()
        fetchedCustomers = NIMBUS.Customers?.getAllMatchingCustomers(searchText: searchForCustomer_Text, searchScope: searchScopes[searchForCustomer_scopeIndex]!) ?? []
        tableView.refreshControl?.endRefreshing()
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Customer.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshCustomers)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CustomerListTableViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - Table view data source

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedCustomers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerTableViewCell", for: indexPath) as! CustomerListTableViewCell
        let indexCustomer = fetchedCustomers[indexPath.row]
        cell.initCell(customer: indexCustomer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomerListTableViewCell
        customerViewManagerDelegate?.customerSelected(customer: cell.customer!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func highlightCustomerRow(customerId: String){
        let indexOfCustomerInArray = fetchedCustomers.index(where: { (customer) -> Bool in
            customer.id == customerId
        })
        if let indexOfCustomerInArray = indexOfCustomerInArray{
            let index = IndexPath(row: indexOfCustomerInArray, section: 0)
            self.tableView.selectRow(at: index, animated: true, scrollPosition: .middle)
        }
    }
}

extension CustomerListTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchForCustomer_scopeIndex = selectedScope
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchForCustomer_Text = searchBar.text ?? ""
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchForCustomer_Text = ""
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchForCustomer_Text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchForCustomer_Text = searchBar.text ?? ""
    }
    
}
