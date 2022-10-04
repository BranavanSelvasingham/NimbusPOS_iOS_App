//
//  customerManagementDetailView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-18.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

class CustomerDetailView: UIViewController, LoyaltyCardManagerDelegate{
    var customer: Customer? {
        didSet{
            customerAttributesViewController.customer = customer
            customerLoyaltyCardsViewController.customer = customer
        }
    }
    
    var customerViewManagerDelegaete: CustomersViewManagerDelegate?
    var customerDetailScrollView: UIScrollView = UIScrollView()
    var customerAttributesView: UIView = UIView()
    var customerAttributesViewController: CustomerAttributesViewController = CustomerAttributesViewController()
    var customerCardsView: UIView = UIView()
    var customerLoyaltyCardsViewController: LoyaltyCardsListTableView = LoyaltyCardsListTableView()
    
    var cardModal: SlideOverModalView = SlideOverModalView()
    var cardViewController: LoyaltyCardViewController = LoyaltyCardViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChildViewController(customerAttributesViewController)
        customerAttributesViewController.view.frame = self.customerAttributesView.bounds
        self.customerAttributesView.addSubview(customerAttributesViewController.view)
        customerAttributesViewController.didMove(toParentViewController: self)
        self.customerDetailScrollView.addSubview(customerAttributesView)
        
        self.addChildViewController(customerLoyaltyCardsViewController)
        customerLoyaltyCardsViewController.loyaltyCardManagerDelegate = self
        customerLoyaltyCardsViewController.view.frame = self.customerCardsView.bounds
        self.customerCardsView.addSubview(customerLoyaltyCardsViewController.view)
        customerLoyaltyCardsViewController.didMove(toParentViewController: self)
        self.customerDetailScrollView.addSubview(customerCardsView)
        
        customerCardsView.layer.borderColor = UIColor.lightGray.cgColor
        customerCardsView.layer.borderWidth = 1
        
        self.view.addSubview(customerDetailScrollView)
        
        cardViewController = LoyaltyCardViewController()
        self.addChildViewController(cardViewController)
        cardModal = SlideOverModalView(frame: self.view.frame)
        cardModal.addViewToModal(view: cardViewController.view)
        cardModal.headerTitle = "Loyalty Card"

        let dismissButton = UIBarButtonItem(image: UIImage(named: "ic_clear"), style: .plain, target: self, action: #selector(dismissCardModal))
        cardModal.rightButtonBarActionButtons = [dismissButton]

        cardViewController.didMove(toParentViewController: self)

        self.view.addSubview(cardModal)
        self.view.bringSubview(toFront: cardModal)
    }
    
    override func viewWillLayoutSubviews(){
        let gaps: CGFloat = 10
        customerDetailScrollView.frame = self.view.frame
        customerAttributesView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width/2, height: 300))
        customerCardsView.frame = CGRect(origin: CGPoint(x: gaps, y: customerAttributesView.frame.height + 2 * gaps), size: CGSize(width: self.view.frame.width - 2 * gaps, height: self.view.frame.height - 100))
        
        cardModal.resizeView(frame: self.view.frame)
        
        updateScrollViewContentHeight()
    }
    
    func updateScrollViewContentHeight(){
        var contentRect = CGRect.zero
        for view in customerDetailScrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        customerDetailScrollView.contentSize.height = contentRect.size.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func openCard(card: LoyaltyCard){
        cardViewController.card = card
        cardModal.presentModal()
    }
    
    func dismissCardModal(){
        cardModal.dismissModal()
    }
    

}
