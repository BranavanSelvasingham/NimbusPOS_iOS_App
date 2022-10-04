//
//  nimbusNavigationFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-14.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

class nimbusNavigationFunctions: NimbusBase {
    var masterNavigationController: MasterViewController?
    var ordersViewController: OrderViewManager!
    
    override init(master: NimbusFramework?){
        super.init(master: master)
    }
    
    func initializeMasterNavigationController(masterNavigationController: MasterViewController){
        self.masterNavigationController = masterNavigationController
        
        ordersViewController = OrderViewManager()
        self.masterNavigationController?.addChildViewController(ordersViewController)
        self.masterNavigationController?.orderView.addSubview(ordersViewController.view)
        ordersViewController.view.frame = self.masterNavigationController?.orderView.frame ?? CGRect.zero
        ordersViewController.didMove(toParentViewController: self.masterNavigationController)
        self.masterNavigationController?.view.sendSubview(toBack: (self.masterNavigationController?.orderView)!)
    }
    
    @objc func loadOrdersView(){
        masterNavigationController?.secondaryContentView.isHidden = true
        masterNavigationController?.orderView.isHidden = false
        removeAllNonEssentialViewControllers()
    }
    
    @objc func loadOpenOrderForEdit(orderId: String){
        loadOrdersView()
        NIMBUS.OrderCreation?.loadInOpenOrder(openOrderId: orderId, openOrderMode: .UpdateOpenOrder)
    }
    
    @objc func loadOpenOrderForCheckout(orderId: String){
        loadOrdersView()
        NIMBUS.OrderCreation?.loadInOpenOrder(openOrderId: orderId, openOrderMode: .CheckoutOpenOrder)
    }
   
    @objc func loadOpenOrdersView(){
        removeAllNonEssentialViewControllers()
        let displayContent = OpenOrdersManager()
        displaySecondaryContentController(displayContent: displayContent)
    }
    
    @objc func loadOrderHistoryView(){
        removeAllNonEssentialViewControllers()
        let displayContent = OrderHistoryManager()
        displaySecondaryContentController(displayContent: displayContent)
    }
    
    @objc func loadDailyReportView(){
        removeAllNonEssentialViewControllers()
        let displayContent = DailyReportManager()
        displaySecondaryContentController(displayContent: displayContent)
    }
    
    @objc func loadCustomersView(){
        removeAllNonEssentialViewControllers()
        let displayContent = CustomersViewManager()
        displaySecondaryContentController(displayContent: displayContent)
    }
    
    @objc func loadEmployeesView(){
        removeAllNonEssentialViewControllers()
        let displayContent = EmployeesViewManager()
        displaySecondaryContentController(displayContent: displayContent)
    }
    
    @objc func loadNotesView(){
        removeAllNonEssentialViewControllers()
        let displayContent = NotesViewManager()
        displaySecondaryContentController(displayContent: displayContent)
    }
    
    @objc func loadSettingsView(){
        removeAllNonEssentialViewControllers()
        let displayContent = SettingsManager()
        displaySecondaryContentController(displayContent: displayContent)
    }
    
    @objc func loadFullHelpPageView(){
        let storyboard = UIStoryboard(name: "FullHelpPage", bundle: Bundle.main)
        let displayContentView = storyboard.instantiateViewController(withIdentifier: "FullHelpPage") as! FullHelpPage
        removeAllNonEssentialViewControllers()
        displaySecondaryContentController(displayContent: displayContentView)
    }
    
    private func displaySecondaryContentController(displayContent: UIViewController){
        masterNavigationController?.addChildViewController(displayContent)
        masterNavigationController?.secondaryContentView.addSubview(displayContent.view)
        displayContent.view.frame = masterNavigationController?.secondaryContentView.frame ?? CGRect.zero
        displayContent.didMove(toParentViewController: masterNavigationController)
        masterNavigationController?.view.sendSubview(toBack: (masterNavigationController?.secondaryContentView)!)
        
        masterNavigationController?.orderView.isHidden = true
        masterNavigationController?.secondaryContentView.isHidden = false
    }
    
    private func removeAllNonEssentialViewControllers(){
        let allViewControllers = masterNavigationController?.childViewControllers
        allViewControllers?.forEach{vc in
            if vc != ordersViewController {
                removeViewController(vc: vc)
            }
        }
    }
    
    private func removeLastAddedContent(){
        let recentViewController = masterNavigationController?.childViewControllers.last
        if let vc = recentViewController {
            removeViewController(vc: vc)
        }
    }
    
    private func removeViewController(vc: UIViewController){
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    func restartApp(){
        self.masterNavigationController?.goToStartOfApp()
    }
}
