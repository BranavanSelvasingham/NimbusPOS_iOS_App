//
//  OrderItemsTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-09.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

class OrderItemsTableViewController: UITableViewController {
    var orderSummaryManagerDelegate: OrderSummaryManagerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(OrderItemCell.self, forCellReuseIdentifier: "orderItemsCell")
        self.tableView.register(OrderLoyaltyProgramItemCell.self, forCellReuseIdentifier: "loyaltyOrderItemsCell")
        
        self.tableView.estimatedRowHeight = 300
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .singleLineEtched
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        self.tableView.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NIMBUS.OrderCreation?.getOrderItemsForSelectedSeat().count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indexOrderItem = NIMBUS.OrderCreation?.getOrderItemAtIndexPathForSelectedSeat(index: indexPath)
        
        if indexOrderItem?.isLoyaltyProgram == true{
            let cell = tableView.dequeueReusableCell(withIdentifier: "loyaltyOrderItemsCell", for: indexPath) as! OrderLoyaltyProgramItemCell
            cell.initCell(cellOrderItem: indexOrderItem!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderItemsCell", for: indexPath) as! OrderItemCell
            cell.initCell(cellOrderItem: indexOrderItem!)
            cell.orderSummaryManagerDelegate = self.orderSummaryManagerDelegate
            return cell
        }
    }
    
    
    
}
