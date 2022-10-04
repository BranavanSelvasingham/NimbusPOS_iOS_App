//
//  orderView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol OrderViewManagerDelegate {
    func dismissOrderTypeModal()
    func openOrderTypeModal()
    
    func dismissWaiterSelectorModal()
    func openWaiterSelectorModal()
    
    func dismissOptionsModal()
    func showOptionsModal()
    
    func setOrderType(orderType: _OrderTypes)
    
    func startCheckout()
    func exitCheckout()
    
    func openRecentOrderModal(withSelfDismiss selfDismiss: Bool)
    func closeRecentOrderModal()
    
    func setOpenOrder(openOrder: Order?)
    func setOpenOrderMode(openOrderMode: _OpenOrderModes)
}

class OrderViewManager: UIViewController, OrderViewManagerDelegate {
    var section1: UIViewWithShadow = UIViewWithShadow()
    var section2: UIViewWithShadow = UIViewWithShadow()
    let splitProportion: CGFloat = 2/3
    let topMargin: CGFloat = 20
    
    var orderCreationSectionViewController: OrderItemsSelectionManager = OrderItemsSelectionManager()
    var orderSummarySectionViewController: OrderSummaryManager = OrderSummaryManager()
    
    var orderTypeSelector: OrderTypeSelectorViewController =  OrderTypeSelectorViewController()
    var orderTypeSelectorModal: SlideOverModalView = SlideOverModalView()
    
    var orderWaiterSelector: OrderWaiterSelectorManager = OrderWaiterSelectorManager()
    var orderWaiterSelectorModal: SlideOverModalView = SlideOverModalView()
    
    //Options Menu
    var optionsModal: SlideOverModalView = SlideOverModalView()
    var optionsVC: ItemOptionsManager = ItemOptionsManager()
    
    //Checkout
    var orderCheckoutVC: OrderCheckoutManager = OrderCheckoutManager()
    var orderCheckoutView: UIView = UIView()
    
    //Most Recent Order Review
    var recentOrderVC: RecentOrderReviewManager = RecentOrderReviewManager()
    var recentOrderView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.setDefaultElevation()
        view.isHidden = true
        return view
    }()
    
    //Open Order
    var openOrder: Order?{
        didSet {
            orderSummarySectionViewController.openOrder = openOrder
        }
    }
    var openOrderMode: _OpenOrderModes? {
        didSet {
            orderSummarySectionViewController.openOrderMode = openOrderMode
        }
    }
    
    //Order Type
    var orderType: _OrderTypes? {
        didSet {
            if orderType == _OrderTypes.Express {
                orderCreationSectionViewController.showProductsView()
                orderCreationSectionViewController.enableCustomersAndLoyalty()
            } else {
                if openOrderMode != _OpenOrderModes.CheckoutOpenOrder {
                    orderCreationSectionViewController.disableCustomersAndLoyalty()
                } else {
                    orderCreationSectionViewController.enableCustomersAndLoyalty()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NIMBUS.OrderCreation?.orderViewManagerDelegate = self
        
        section1.setDefaultElevation()
//        section2.setDefaultElevation()
        
        self.view.addSubview(section1)
        self.view.addSubview(section2)
        self.view.bringSubview(toFront: section1)
        
        NIMBUS.OrderCreation?.resetOrder()

        orderCreationSectionViewController = OrderItemsSelectionManager()
        self.addChildViewController(orderCreationSectionViewController)
        self.section1.addSubview(orderCreationSectionViewController.view)
        orderCreationSectionViewController.view.frame = section1.frame
        orderCreationSectionViewController.didMove(toParentViewController: self)

        orderSummarySectionViewController = OrderSummaryManager()
        self.addChildViewController(orderSummarySectionViewController)
        self.section2.addSubview(orderSummarySectionViewController.view)
        orderSummarySectionViewController.view.frame = section2.frame
        orderSummarySectionViewController.didMove(toParentViewController: self)
        orderSummarySectionViewController.orderViewManagerDelegate = self
        
        //
        self.addChildViewController(orderTypeSelector)
        orderTypeSelector.didMove(toParentViewController: self)
        orderTypeSelector.orderViewManagerDelegate = self
        
        orderTypeSelectorModal = SlideOverModalView(frame: self.view.frame)
        orderTypeSelectorModal.addViewToModal(view: orderTypeSelector.view)
        orderTypeSelectorModal.headerTitle = "Select Order Type"
        self.view.addSubview(orderTypeSelectorModal)
        self.view.bringSubview(toFront: orderTypeSelectorModal)
        
        let closeOrderTypeSelectorTap = UITapGestureRecognizer(target: self, action: #selector(dismissOrderTypeModal))
        closeOrderTypeSelectorTap.numberOfTapsRequired = 1
        closeOrderTypeSelectorTap.cancelsTouchesInView = false
        orderTypeSelectorModal.blurView.addGestureRecognizer(closeOrderTypeSelectorTap)
        
        //
        self.addChildViewController(orderWaiterSelector)
        orderWaiterSelector.orderViewManagerDelegate = self
        orderWaiterSelector.didMove(toParentViewController: self)
        
        orderWaiterSelectorModal = SlideOverModalView(frame: self.view.frame)
        orderWaiterSelectorModal.addViewToModal(view: orderWaiterSelector.view)
        orderWaiterSelectorModal.headerTitle = "Select Waiter"
        self.view.addSubview(orderWaiterSelectorModal)
        self.view.bringSubview(toFront: orderWaiterSelectorModal)
        
        let closeOrderWaiterSelectorModalTap = UITapGestureRecognizer(target: self, action: #selector(dismissWaiterSelectorModal))
        closeOrderWaiterSelectorModalTap.numberOfTapsRequired = 1
        closeOrderWaiterSelectorModalTap.cancelsTouchesInView = false
        orderWaiterSelectorModal.blurView.addGestureRecognizer(closeOrderWaiterSelectorModalTap)
        
        loadItemOptions()
        
        loadCheckoutView()
        
        loadRecentOrderView()
    }
    
    override func viewWillLayoutSubviews() {
        let screenWidth: CGFloat = self.view.frame.width
        let screenHeight: CGFloat = self.view.frame.height - topMargin
        
        section1.frame = CGRect(origin: CGPoint(x: 0, y: topMargin), size: CGSize(width: screenWidth * splitProportion, height: screenHeight))
        section2.frame = CGRect(origin: CGPoint(x: section1.frame.maxX, y: topMargin), size: CGSize(width: screenWidth - section1.frame.width, height: screenHeight))
        
        let frame = self.view.frame
        let typeSelectorModalFrame = CGRect(origin: CGPoint(x: frame.width*0.1, y: frame.height*0.1), size: CGSize(width: frame.width * 0.8 , height: frame.height * 0.8))
        orderTypeSelectorModal.resizeView(frame: frame, customPresentFrame: typeSelectorModalFrame)
        
        let waiterSelectorModalFrame = CGRect(origin: CGPoint(x: frame.width*0.3, y: frame.height*0.1), size: CGSize(width: frame.width * 0.4, height: frame.height * 0.8))
        orderWaiterSelectorModal.resizeView(frame: frame, customPresentFrame: waiterSelectorModalFrame)
        
        self.view.addSubview(optionsModal)
        self.view.bringSubview(toFront: optionsModal)
        layoutItemOptions()
        
        layoutCheckoutView()
        
        layoutRecentOrderView()
    }
    
    func loadRecentOrderView(){
        self.addChildViewController(recentOrderVC)
        recentOrderVC.didMove(toParentViewController: self)
        recentOrderVC.orderViewManagerDelegate = self
        
        recentOrderView.frame = self.view.frame
        recentOrderVC.view.frame = recentOrderView.bounds
        recentOrderView.addSubview(recentOrderVC.view)
        
        self.view.addSubview(recentOrderView)
    }
    
    func layoutRecentOrderView(){
        recentOrderView.frame = self.view.frame
        recentOrderVC.view.frame = recentOrderView.bounds
    }
    
    func loadCheckoutView(){
        self.addChildViewController(orderCheckoutVC)
        orderCheckoutVC.didMove(toParentViewController: self)
        orderCheckoutVC.orderViewManagerDelegate = self
        
        orderCheckoutView.frame = self.view.frame
        orderCheckoutVC.view.frame = orderCheckoutView.bounds
        orderCheckoutView.addSubview(orderCheckoutVC.view)
        
        orderCheckoutView.isHidden = true
        orderCheckoutView.backgroundColor = UIColor.white
        
        self.view.addSubview(orderCheckoutView)
    }
    
    func layoutCheckoutView(){
        let frame = CGRect(origin: CGPoint(x: 0, y: topMargin), size: CGSize(width: self.view.frame.width, height: self.view.frame.height - topMargin))
        orderCheckoutView.frame = frame
        orderCheckoutVC.view.frame = orderCheckoutView.bounds
    }
    
    func loadItemOptions(){
        self.addChildViewController(optionsVC)
        optionsVC.didMove(toParentViewController: self)
        
        optionsModal = SlideOverModalView(frame: self.view.frame)
        optionsModal.addViewToModal(view: optionsVC.view)
        optionsModal.headerTitle = "Item Options"
        
        let closeOptionsModal = UITapGestureRecognizer(target: self, action: #selector(dismissOptionsModal))
        closeOptionsModal.numberOfTapsRequired = 1
        closeOptionsModal.cancelsTouchesInView = false
        optionsModal.blurView.addGestureRecognizer(closeOptionsModal)
    }
    
    func layoutItemOptions(){
        let frame = self.view.frame
        let optionsModalFrame = CGRect(origin: CGPoint(x: frame.width*splitProportion*0.1, y: frame.height*0.1), size: CGSize(width: frame.width * splitProportion * 0.8, height: frame.height * 0.8))
        optionsModal.resizeView(frame: frame, customPresentFrame: optionsModalFrame)
    }
    
    func dismissOrderTypeModal(){
        orderTypeSelectorModal.dismissModal()
    }
    
    func openOrderTypeModal(){
        orderTypeSelector.fillInExistingOrderTypeDetails()
        orderTypeSelectorModal.presentModal()
    }
    
    func dismissWaiterSelectorModal(){
        orderWaiterSelectorModal.dismissModal(slideAnimation: false)
    }
    
    func openWaiterSelectorModal(){
        orderWaiterSelectorModal.presentModal(slideAnimation: false)
    }
    
    func dismissOptionsModal() {
        optionsModal.dismissModal()
    }
    
    func showOptionsModal() {
        optionsVC.refreshAllViews()
        optionsModal.presentModal()
    }

    func setOrderType(orderType: _OrderTypes){
        self.orderType = orderType
    }
    
    func startCheckout(){
        self.view.bringSubview(toFront: orderCheckoutView)
        orderCheckoutView.isHidden = false
    }
    
    func exitCheckout(){
        orderCheckoutView.isHidden = true
    }
    
    func openRecentOrderModal(withSelfDismiss selfDismiss: Bool){
        recentOrderVC.loadRecentOrder(withSelfDismiss: selfDismiss)
        recentOrderView.isHidden = false
    }
    
    func closeRecentOrderModal(){
        recentOrderView.isHidden = true
    }
    
    func setOpenOrder(openOrder: Order?){
        self.openOrder = openOrder
    }
    
    func setOpenOrderMode(openOrderMode: _OpenOrderModes){
        self.openOrderMode = openOrderMode
    }
}
