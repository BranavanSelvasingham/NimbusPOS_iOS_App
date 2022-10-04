//
//  TablesListTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-04.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

protocol TablesListDelegate {
    func selectTable(table: Table)
}

class TablesListTableViewController: UITableViewController {
    var fetchedTables: [Table] = [Table](){
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var tablesListDelegate: TablesListDelegate?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshTables()
        
        self.tableView.register(TablesListTableViewCell.self, forCellReuseIdentifier: "TablesListCell")
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)

        // Add Observer
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.Tables?.managedContext)
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshTables), for: .valueChanged)
    }
    
    func pullToRefreshTables(){
        tableView.refreshControl?.beginRefreshing()
        refreshTables()
        tableView.refreshControl?.endRefreshing()
    }
    
    func refreshTables(){
        fetchedTables = NIMBUS.Tables?.fetchAllTables() ?? []
        if let selectedTable = NIMBUS.OrderCreation?.table {
            selectTableWithId(tableId: selectedTable.id ?? " ")
        }
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Table.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshTables)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tables"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedTables.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TablesListCell", for: indexPath) as! TablesListTableViewCell
        let indexTable = fetchedTables[indexPath.row]
        cell.initCell(table: indexTable)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! TablesListTableViewCell
        tablesListDelegate?.selectTable(table: selectedCell.table!)
    }
    
    func selectTableWithId(tableId: String){
        if let indexRow = fetchedTables.index(where:{$0.id == tableId}) {
            tableView.selectRow(at: IndexPath(row: indexRow, section: 0), animated: false, scrollPosition: .middle)
        }
    }

}
