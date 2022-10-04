//
//  OrderViewCustomerLoyaltyCardsTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-01.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

protocol OrderViewCustomerLoyaltyCardsDelegate {
    func setCustomerCards(customerLoyaltyCards: [nimbusOrderCreationFunctions.orderLoyaltyCards])
}

class OrderViewCustomerLoyaltyCardsTableViewController: UITableViewController, OrderViewCustomerLoyaltyCardsDelegate {
    var customer: Customer?{
        didSet {
            
        }
    }
    
    var customerLoyaltyCards = [nimbusOrderCreationFunctions.orderLoyaltyCards](){
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var quantityCards: [nimbusOrderCreationFunctions.orderLoyaltyCards]{
        get{
            return customerLoyaltyCards.filter({$0.card.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Quantity})
        }
    }
    
    var amountCards: [nimbusOrderCreationFunctions.orderLoyaltyCards]{
        get{
            return customerLoyaltyCards.filter({$0.card.programType == NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard})
        }
    }
    
    var percentageCards: [nimbusOrderCreationFunctions.orderLoyaltyCards]{
        get{
            return customerLoyaltyCards.filter({$0.card.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Coupon})
        }
    }
    
    var tallyCards: [nimbusOrderCreationFunctions.orderLoyaltyCards]{
        get{
            return customerLoyaltyCards.filter({$0.card.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Tally})
        }
    }
    
    var loyaltyCardManagerDelegate: LoyaltyCardManagerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(OrderViewCustomerLoyaltyCardsTableViewCell.self, forCellReuseIdentifier: "orderLoyaltyCardsListTableViewCell")
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.tableView.tableFooterView = UIView()
        
        NIMBUS.OrderCreation?.orderViewCustomerLoyaltyCardsDelegate = self
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return quantityCards.count
        } else if section == 1 {
            return amountCards.count
        } else if section == 2 {
            return percentageCards.count
        } else {
            return tallyCards.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderLoyaltyCardsListTableViewCell", for: indexPath) as! OrderViewCustomerLoyaltyCardsTableViewCell
        
        if indexPath.section == 0 {
            let indexLoyaltyCard = quantityCards[indexPath.row]
            cell.initCell(card: indexLoyaltyCard)
        } else if indexPath.section == 1 {
            let indexLoyaltyCard = amountCards[indexPath.row]
            cell.initCell(card: indexLoyaltyCard)
        } else if indexPath.section == 2 {
            let indexLoyaltyCard = percentageCards[indexPath.row]
            cell.initCell(card: indexLoyaltyCard)
        } else {
            let indexLoyaltyCard = tallyCards[indexPath.row]
            cell.initCell(card: indexLoyaltyCard)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func setCustomerCards(customerLoyaltyCards: [nimbusOrderCreationFunctions.orderLoyaltyCards]){
        self.customerLoyaltyCards = customerLoyaltyCards
    }
}
