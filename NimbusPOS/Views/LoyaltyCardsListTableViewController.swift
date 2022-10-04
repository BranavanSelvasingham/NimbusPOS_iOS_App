//
//  loyaltyCardsListTableViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-21.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

protocol LoyaltyCardManagerDelegate {
    func openCard(card: LoyaltyCard)
}

class LoyaltyCardsListTableView: UITableViewController, LoyaltyCardManagerDelegate {
    var customer: Customer?{
        didSet {
            refreshLoyaltyCards()
        }
    }
    
    var fetchedCustomerCards = [LoyaltyCard]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var quantityCards: [LoyaltyCard]{
        get{
            return fetchedCustomerCards.filter({$0.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Quantity})
        }
    }
    
    var amountCards: [LoyaltyCard]{
        get{
            return fetchedCustomerCards.filter({$0.programType == NIMBUS.Library?.LoyaltyPrograms.Types.GiftCard})
        }
    }
    
    var percentageCards: [LoyaltyCard]{
        get{
            return fetchedCustomerCards.filter({$0.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Coupon})
        }
    }
    
    var tallyCards: [LoyaltyCard]{
        get{
            return fetchedCustomerCards.filter({$0.programType == NIMBUS.Library?.LoyaltyPrograms.Types.Tally})
        }
    }
    
    var loyaltyCardManagerDelegate: LoyaltyCardManagerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchedCustomerCards = NIMBUS.LoyaltyCards?.fetchAllCustomerLoyaltyCards(customerMO: customer) ?? []
        
        self.tableView.register(LoyaltyCardsListTableViewCell.self, forCellReuseIdentifier: "loyaltyCardsListTableViewCell")
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)

        // Add Observer
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.LoyaltyCards?.managedContext)
        
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshLoyaltyCards), for: .valueChanged)
    }

    func refreshLoyaltyCards(){
        self.tableView.refreshControl?.beginRefreshing()
        self.fetchedCustomerCards = NIMBUS.LoyaltyCards?.fetchAllCustomerLoyaltyCards(customerMO: customer) ?? []
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = LoyaltyCard.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshLoyaltyCards)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func openCard(card: LoyaltyCard){
        loyaltyCardManagerDelegate?.openCard(card: card)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Quantity-Based Cards (x \(quantityCards.count))"
        } else if section == 1 {
            return "Amount-Based Cards (x \(amountCards.count))"
        } else if section == 2 {
            return "Percentage-Based Cards (x \(percentageCards.count))"
        } else {
            return "Tally Cards (x \(tallyCards.count))"
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "loyaltyCardsListTableViewCell", for: indexPath) as! LoyaltyCardsListTableViewCell
        
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
        cell.loyaltyCardManagerDelegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
