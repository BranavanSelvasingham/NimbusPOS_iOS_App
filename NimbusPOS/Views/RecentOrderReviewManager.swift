//
//  OrderReviewManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-24.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class RecentOrderReviewManager: UIViewController {
    var selfDismissTime: TimeInterval = 5
    
    func loadRecentOrder(withSelfDismiss selfDismiss: Bool = true){
        refreshOrder()
        
        if selfDismiss == true {
            activityIndicatorForCompletedOrder.progress = 1.0
            activityIndicatorForCompletedOrder.startAnimating()
            decrementActivityIndicator()
            
            DispatchQueue.main.async {
                Timer.scheduledTimer(timeInterval: self.selfDismissTime,
                                     target: self,
                                     selector: #selector(self.dismissSelf),
                                     userInfo: nil,
                                     repeats: false)
            }
        }
    }
    
    func refreshOrder(){
        order = NIMBUS.OrderManagement?.getMostRecentOrder()
    }
    
    func decrementActivityIndicator(){
        if activityIndicatorForCompletedOrder.progress > 0 {
            activityIndicatorForCompletedOrder.progress -= 0.1
            Timer.scheduledTimer(timeInterval: self.selfDismissTime/10, target: self, selector: #selector(self.decrementActivityIndicator), userInfo: nil, repeats: false)
        } else {
            activityIndicatorForCompletedOrder.progress = 1.0
            activityIndicatorForCompletedOrder.stopAnimating()
        }
    }
    
    var order: Order? {
        didSet {
            orderReceiptViewController.orderMO = order
            openOrderSlipViewController.order = order
            orderAsStruct = orderSchema(withManagedObject: order)
            checkIfThisIsOpenOrder()
        }
    }
    
    var orderAsStruct: orderSchema?{
        didSet {
            orderPayment = orderAsStruct?.payment
        }
    }
    
    var orderPayment: paymentInformation? = nil {
        didSet {
            refreshOrderPaymentDetails()
            giftCardPay = orderPayment?.giftCardTotal ?? 0
        }
    }
    
    var giftCardPay: Float = 0{
        didSet{
            if giftCardPay > 0 {
                giftCardBlock.isHidden = false
                giftCardBlock.label2.text = giftCardPay.toString(asMoney: true, toDecimalPlaces: 2)
            } else {
                giftCardBlock.isHidden = true
            }
        }
    }
    
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    
    let completedOrderContentView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.backgroundColor = UIColor.gray
        view.setDefaultElevation()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 500).isActive = true
        view.widthAnchor.constraint(equalToConstant: 900).isActive = true
        return view
    }()
    
    let openOrderContentView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.backgroundColor = UIColor.gray
        view.setDefaultElevation()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 600).isActive = true
        view.widthAnchor.constraint(equalToConstant: 500).isActive = true
        return view
    }()
    
    let blurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.75
        return view
    }()
    
    var orderReceiptViewController: OrderReceiptViewController = OrderReceiptViewController()
    var openOrderSlipViewController: OpenOrderSlipViewController = OpenOrderSlipViewController()
    
    let orderPaymentView: UIViewWithShadow = {
        let view = UIViewWithShadow(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 200)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setDefaultElevation()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let orderPaymentComponentsStackView: UIStackView = {
        let stack = UIStackView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 200)))
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 30
        return stack
    }()
    
    let orderTotalBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Order Total:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    let cashRoundingBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.subheadFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Cash Rounding:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    let giftCardBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Gift Card:"
        block.label2.text = "-$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    let paymentDueBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.display1Font()
        let amountsLabelWidth: Int = 150
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Payment Due:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    let cashGivenBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Cash Given:"
        block.label2.text = "-$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    let changeDueBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Change Due:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        return block
    }()
    
    let buttonHeaderView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return view
    }()
    
    let printButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.setImage(UIImage(named: "ic_print"), for: .normal)
        button.addTarget(self, action: #selector(printOrder), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let openCashDrawerButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.setImage(UIImage(named: "ic_open_cash_drawer"), for: .normal)
        button.addTarget(self, action: #selector(openCashDrawer), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let activityIndicatorForCompletedOrder: MDCActivityIndicator = {
        let activityIndicator = MDCActivityIndicator()
        activityIndicator.indicatorMode = .determinate
        activityIndicator.progress = 1
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        self.view.addSubview(blurView)
        self.view.addSubview(completedOrderContentView)
        self.view.addSubview(openOrderContentView)
        self.view.bringSubview(toFront: completedOrderContentView)
        self.view.bringSubview(toFront: openOrderContentView)
        self.view.sendSubview(toBack: blurView)
        
        loadReceipt()
        loadPaymentComponentsStack()
        loadButtonHeader()
        loadOpenOrderSlip()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Add Observer
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.Tables?.managedContext)
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Order.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshOrder)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        blurView.frame = self.view.frame
        
        let closeOptionsModal = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        closeOptionsModal.numberOfTapsRequired = 1
        closeOptionsModal.cancelsTouchesInView = false
        
        blurView.addGestureRecognizer(closeOptionsModal)
        
        NSLayoutConstraint(item: completedOrderContentView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: completedOrderContentView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: openOrderContentView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: openOrderContentView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        layoutReceipt()
        layoutPaymentComponentsStack()
        layoutButtonHeader()
        layoutOpenOrderSlip()
    }
    
    func loadOpenOrderSlip(){
        self.addChildViewController(openOrderSlipViewController)
        openOrderSlipViewController.didMove(toParentViewController: self)
        openOrderContentView.addSubview(openOrderSlipViewController.view)
        openOrderContentView.backgroundColor = UIColor.gray
    }
    
    func loadButtonHeader(){
        completedOrderContentView.addSubview(buttonHeaderView)
        buttonHeaderView.addSubview(printButton)
        buttonHeaderView.addSubview(openCashDrawerButton)
        buttonHeaderView.addSubview(activityIndicatorForCompletedOrder)
    }
    
    func layoutOpenOrderSlip(){
        let openOrderSlipView = openOrderSlipViewController.view!
        openOrderSlipView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: openOrderSlipView, attribute: .top, relatedBy: .equal, toItem: openOrderContentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: openOrderSlipView, attribute: .leading, relatedBy: .equal, toItem: openOrderContentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: openOrderSlipView, attribute: .trailing, relatedBy: .equal, toItem: openOrderContentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: openOrderSlipView, attribute: .bottom, relatedBy: .equal, toItem: openOrderContentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func layoutButtonHeader(){
        NSLayoutConstraint(item: buttonHeaderView, attribute: .top, relatedBy: .equal, toItem: completedOrderContentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buttonHeaderView, attribute: .leading, relatedBy: .equal, toItem: orderPaymentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: buttonHeaderView, attribute: .trailing, relatedBy: .equal, toItem: completedOrderContentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: printButton, attribute: .centerY, relatedBy: .equal, toItem: buttonHeaderView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printButton, attribute: .leading, relatedBy: .equal, toItem: buttonHeaderView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        
        NSLayoutConstraint(item: openCashDrawerButton, attribute: .centerY, relatedBy: .equal, toItem: buttonHeaderView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: openCashDrawerButton, attribute: .leading, relatedBy: .equal, toItem: printButton, attribute: .trailing, multiplier: 1, constant: 20).isActive = true
        
        NSLayoutConstraint(item: activityIndicatorForCompletedOrder, attribute: .centerY, relatedBy: .equal, toItem: buttonHeaderView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: activityIndicatorForCompletedOrder, attribute: .trailing, relatedBy: .equal, toItem: buttonHeaderView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
    }
    
    func loadPaymentComponentsStack(){
        orderPaymentComponentsStackView.addArrangedSubview(orderTotalBlock)
        orderPaymentComponentsStackView.addArrangedSubview(cashRoundingBlock)
        orderPaymentComponentsStackView.addArrangedSubview(giftCardBlock)
        orderPaymentComponentsStackView.addArrangedSubview(paymentDueBlock)
        orderPaymentComponentsStackView.addArrangedSubview(cashGivenBlock)
        orderPaymentComponentsStackView.addArrangedSubview(changeDueBlock)
        orderPaymentView.addSubview(orderPaymentComponentsStackView)
        completedOrderContentView.addSubview(orderPaymentView)
    }
    
    func layoutPaymentComponentsStack(){
        NSLayoutConstraint(item: orderPaymentView, attribute: .top, relatedBy: .equal, toItem: buttonHeaderView, attribute: .bottom, multiplier: 1, constant: 1).isActive = true
        NSLayoutConstraint(item: orderPaymentView, attribute: .leading, relatedBy: .equal, toItem: orderReceiptViewController.view, attribute: .trailing, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: orderPaymentView, attribute: .trailing, relatedBy: .equal, toItem: completedOrderContentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderPaymentView, attribute: .bottom, relatedBy: .equal, toItem: completedOrderContentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        orderPaymentComponentsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: orderPaymentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .leading, relatedBy: .equal, toItem: orderPaymentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .trailing, relatedBy: .equal, toItem: orderPaymentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: orderPaymentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .centerY, relatedBy: .equal, toItem: orderPaymentView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    func loadReceipt(){
        self.addChildViewController(orderReceiptViewController)
        orderReceiptViewController.didMove(toParentViewController: self)
        completedOrderContentView.addSubview(orderReceiptViewController.view)
    }
    
    func layoutReceipt(){
        let receiptView = orderReceiptViewController.view!
        receiptView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: receiptView, attribute: .top, relatedBy: .equal, toItem: completedOrderContentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .leading, relatedBy: .equal, toItem: completedOrderContentView, attribute: .leading, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 400).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .bottom, relatedBy: .equal, toItem: completedOrderContentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func refreshOrderPaymentDetails(){
        if orderPayment?.method == AcceptedPaymentMethods.cash.key {
            updateCashPaymentLabels()
        } else if orderPayment?.method == AcceptedPaymentMethods.card.key {
            updateCardPaymentLabels()
        }
    }
    
    func updateCashPaymentLabels(){
        orderTotalBlock.isHidden = false
        cashRoundingBlock.isHidden = false
        paymentDueBlock.isHidden = false
        cashGivenBlock.isHidden = false
        changeDueBlock.isHidden = false
        
        orderTotalBlock.label2.text = orderPayment?.amount?.toString(asMoney: true, toDecimalPlaces: 2) ?? String(0.00)
        cashRoundingBlock.label2.text = orderPayment?.rounding?.toString(asMoney: true, toDecimalPlaces: 2)
        let exactAmount: Float = orderPayment?.amount ?? 0.0
        let cashRounding: Float = orderPayment?.rounding ?? 0.0
        let cashTotal: Float = exactAmount + cashRounding
        paymentDueBlock.label1.text = "Cash Payment:"
        paymentDueBlock.label2.text = cashTotal.toString(asMoney: true, toDecimalPlaces: 2)
        cashGivenBlock.label2.text = orderPayment?.cashGiven?.toString(asMoney: true, toDecimalPlaces: 2)
        if (orderPayment?.cashGiven ?? 0.0) > Float(0.0) {
            changeDueBlock.label2.text = orderPayment?.change?.toString(asMoney: true, toDecimalPlaces: 2)
        } else {
            changeDueBlock.label2.text = ""
        }
    }
    
    func updateCardPaymentLabels(){
        orderTotalBlock.isHidden = false
        cashRoundingBlock.isHidden = true
        paymentDueBlock.isHidden = false
        cashGivenBlock.isHidden = true
        changeDueBlock.isHidden = true
        
        orderTotalBlock.label2.text = orderPayment?.amount?.toString(asMoney: true, toDecimalPlaces: 2) ?? String(0.00)
        paymentDueBlock.label1.text = "Card Payment:"
        paymentDueBlock.label2.text = orderPayment?.amount?.toString(asMoney: true, toDecimalPlaces: 2) ?? String(0.00)

    }
    
    func printOrder(){
        if let orderAsStruct = orderAsStruct {
            NIMBUS.Print?.printOrderReceipt(order: orderAsStruct)
        }
    }
    
    func openCashDrawer(){
        NIMBUS.Print?.openCashDrawer()
    }
    
    func checkIfThisIsOpenOrder(){
        if order?.status == NIMBUS.Library?.OrderStatus.Created {
            completedOrderContentView.isHidden = true
            openOrderContentView.isHidden = false
        } else {
            completedOrderContentView.isHidden = false
            openOrderContentView.isHidden = true
        }
    }
    
    func dismissSelf(){
        if orderViewManagerDelegate != nil {
            activityIndicatorForCompletedOrder.stopAnimating()
            orderViewManagerDelegate?.closeRecentOrderModal()
        } else {
            
        }
    }
}
