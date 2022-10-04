//
//  OrderCheckoutManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-13.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol OrderCheckoutManagerDelegate {
    func setOrderPaymentDetails(orderPayment: paymentInformation)
    func refreshOrderPaymentDetails()
    func giftCardPaySet(giftCardPay: Float)
}

class OrderCheckoutManager: UIViewController, OrderCheckoutManagerDelegate {
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    
    let headerView: UIViewWithShadow = {
        let headerView = UIViewWithShadow()
        headerView.setDefaultElevation()
        headerView.backgroundColor = UIColor.white
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        return headerView
    }()
    
    let backButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.setImage(UIImage(named: "ic_arrow_back_white_48pt"), for: .normal)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.backgroundColor = UIColor.gray
        customButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        customButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        customButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return customButton
    }()
    
    let orderAdjustmentButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.setTitle("Order Total Adjustment", for: .normal)
        customButton.isUppercaseTitle = false
        customButton.setTitleFont(MDCTypography.titleFont(), for: .normal)
        customButton.setTitleColor(UIColor.gray, for: .normal)
        customButton.setElevation(.cardResting , for: .normal)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.backgroundColor = UIColor.white
        customButton.addTarget(self, action: #selector(openOrderDiscounts), for: .touchUpInside)
        customButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        customButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return customButton
    }()
    
    let orderAdjustmentsVC: OrderAdjustmentController = OrderAdjustmentController()
    let orderAdjustmentsView: SlideOverModalView = SlideOverModalView()
    
    let orderPaymentView: UIView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 200)))
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
    
    var orderPayment: paymentInformation? = nil {
        didSet {
            refreshOrderPaymentDetails()
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
    
    let paymentTypeSelectorView: UIView = UIView()
    
    let paymentTypeSelectorStackView = { () -> UIStackView in
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: 100, height: 300))
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()
    
    let cashPaymentTypeButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.setImage(UIImage(named: "ic_local_atm_48pt"), for: .normal)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.backgroundColor = UIColor.white
        customButton.addTarget(self, action: #selector(cashPaymentTypeSelected), for: .touchUpInside)
        customButton.setShadowColor(UIColor.color(fromHexString: "00ffff"), for: .selected)
        customButton.setElevation(.cardPickedUp, for: .selected)
        return customButton
    }()
    
    let cardPaymentTypeButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.setImage(UIImage(named: "ic_credit_card_48pt"), for: .normal)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.backgroundColor = UIColor.white
        customButton.addTarget(self, action: #selector(cardPaymentTypeSelected), for: .touchUpInside)
        customButton.setShadowColor(UIColor.color(fromHexString: "00ffff"), for: .selected)
        customButton.setElevation(.cardPickedUp, for: .selected)
        return customButton
    }()
    
    let completeOrderButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.setTitle("Order Completed", for: .normal)
        customButton.setTitleColor(UIColor.white, for: .normal)
        customButton.isUppercaseTitle = false
        customButton.setTitleFont(MDCTypography.titleFont(), for: .normal)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.backgroundColor = UIColor.color(fromHexString: "009933")
        customButton.addTarget(self, action: #selector(completeOrder), for: .touchUpInside)
        customButton.widthAnchor.constraint(equalToConstant: 400).isActive = true
        customButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return customButton
    }()
    
    let keypadController = CashKeypadController()
    let keypadView: UIView = UIView()
    
    var printReceiptSwitch: SmartSwitch = {
        let printReceiptSwitch = SmartSwitch(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        printReceiptSwitch.switchLabel.text = "Print Receipt:"
        printReceiptSwitch.switchImageRight.image = UIImage(named: "ic_print_36pt")
        printReceiptSwitch.switchElement.addTarget(self, action: #selector(printSwitchStateChange), for: .valueChanged)
        return printReceiptSwitch
    }()
    
    var cashDrawerSwitch: SmartSwitch = {
        let cashDrawerSwitch = SmartSwitch(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        cashDrawerSwitch.switchLabel.text = "Open Cash Drawer:"
        cashDrawerSwitch.switchImageRight.image = UIImage(named: "ic_open_in_browser_36pt")
        cashDrawerSwitch.switchImageRight.transform = cashDrawerSwitch.switchImageRight.transform.rotated(by: CGFloat.pi)
        cashDrawerSwitch.switchElement.addTarget(self, action: #selector(cashDrawerSwitchStateChange), for: .valueChanged)
        return cashDrawerSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NIMBUS.OrderCreation?.orderCheckoutManagerDelegate = self
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(headerView)
        self.view.addSubview(backButton)
        self.view.addSubview(completeOrderButton)
        loadPaymentTypeSelector()
        loadPaymentComponentsStack()
        temporaryFeatures()
        loadKeypad()
        loadPrintSwitch()
        loadCashDrawerSwitch()
        loadOrderAdjustments()
    }
    
    func temporaryFeatures(){
        orderPaymentView.layer.borderColor = UIColor.lightGray.cgColor
        orderPaymentView.layer.borderWidth = 1

//        paymentTypeSelectorView.layer.borderColor = UIColor.gray.cgColor
//        paymentTypeSelectorView.layer.borderWidth = 2

        keypadView.layer.borderColor = UIColor.lightGray.cgColor
        keypadView.layer.borderWidth = 1
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutHeader()
        layoutBackButton()
        layoutPaymentTypeSelector()
        layoutPaymentComponentsStack()
        layoutOrderCompletedButton()
        layoutKeypad()
        layoutPrintSwitch()
        layoutCashDrawerSwitch()
        layoutOrderAdjustments()
    }
    
    func loadOrderAdjustments(){
        self.view.addSubview(orderAdjustmentButton)
        
        self.addChildViewController(orderAdjustmentsVC)
        orderAdjustmentsVC.didMove(toParentViewController: self)
        orderAdjustmentsView.addViewToModal(view: orderAdjustmentsVC.view)
        orderAdjustmentsView.headerTitle = "Order Total Adjustment"
        self.view.addSubview(orderAdjustmentsView)
        self.view.bringSubview(toFront: orderAdjustmentsView)
        
        let closeAdjustmentView = UITapGestureRecognizer(target: self, action: #selector(dismissAdjustmentsView))
        closeAdjustmentView.numberOfTapsRequired = 1
        closeAdjustmentView.cancelsTouchesInView = false
        orderAdjustmentsView.blurView.addGestureRecognizer(closeAdjustmentView)
    }
    
    func layoutOrderAdjustments(){
        NSLayoutConstraint(item: orderAdjustmentButton, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: orderAdjustmentButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        
        let customFrame = CGRect(origin: CGPoint(x: 600, y: 30), size: CGSize(width: 400, height: 330))
        orderAdjustmentsView.resizeView(frame: self.view.frame, customPresentFrame: customFrame)
    }
    
    func loadPrintSwitch(){
        headerView.addSubview(printReceiptSwitch)
    }
    
    func layoutPrintSwitch(){
        printReceiptSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: printReceiptSwitch, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: printReceiptSwitch, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: printReceiptSwitch, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300).isActive = true
        NSLayoutConstraint(item: printReceiptSwitch, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
    }
    
    func loadCashDrawerSwitch(){
        headerView.addSubview(cashDrawerSwitch)
    }
    
    func layoutCashDrawerSwitch(){
        cashDrawerSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cashDrawerSwitch, attribute: .top, relatedBy: .equal, toItem: printReceiptSwitch, attribute: .bottom, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: cashDrawerSwitch, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: cashDrawerSwitch, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300).isActive = true
        NSLayoutConstraint(item: cashDrawerSwitch, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
    }
    
    func loadKeypad(){
        self.addChildViewController(keypadController)
        keypadController.didMove(toParentViewController: self)
        keypadView.addSubview(keypadController.view)
        self.view.addSubview(keypadView)
    }
    
    func layoutKeypad(){
        keypadView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: keypadView, attribute: .top, relatedBy: .equal, toItem: orderPaymentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keypadView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: keypadView, attribute: .trailing, relatedBy: .equal, toItem: orderPaymentView, attribute: .leading, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: keypadView, attribute: .bottom, relatedBy: .equal, toItem: orderPaymentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        keypadController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: keypadController.view, attribute: .top, relatedBy: .equal, toItem: keypadView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keypadController.view, attribute: .leading, relatedBy: .equal, toItem: keypadView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keypadController.view, attribute: .trailing, relatedBy: .equal, toItem: keypadView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keypadController.view, attribute: .bottom, relatedBy: .equal, toItem: keypadView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func loadPaymentTypeSelector(){
        self.view.addSubview(paymentTypeSelectorView)
        paymentTypeSelectorStackView.addArrangedSubview(cashPaymentTypeButton)
        paymentTypeSelectorStackView.addArrangedSubview(cardPaymentTypeButton)
        paymentTypeSelectorView.addSubview(paymentTypeSelectorStackView)
    }
    
    func layoutOrderCompletedButton(){
        NSLayoutConstraint(item: completeOrderButton, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: completeOrderButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
    }
    
    func layoutPaymentTypeSelector(){
        paymentTypeSelectorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: paymentTypeSelectorView, attribute: .top, relatedBy: .equal, toItem: orderPaymentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: paymentTypeSelectorView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: paymentTypeSelectorView, attribute: .bottom, relatedBy: .equal, toItem: orderPaymentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        paymentTypeSelectorStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: paymentTypeSelectorStackView, attribute: .leading, relatedBy: .equal, toItem: paymentTypeSelectorView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: paymentTypeSelectorStackView, attribute: .trailing, relatedBy: .equal, toItem: paymentTypeSelectorView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: paymentTypeSelectorStackView, attribute: .centerY, relatedBy: .equal, toItem: paymentTypeSelectorView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        cashPaymentTypeButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cashPaymentTypeButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        cardPaymentTypeButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cardPaymentTypeButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func loadPaymentComponentsStack(){
        orderPaymentComponentsStackView.addArrangedSubview(orderTotalBlock)
        orderPaymentComponentsStackView.addArrangedSubview(cashRoundingBlock)
        orderPaymentComponentsStackView.addArrangedSubview(giftCardBlock)
        orderPaymentComponentsStackView.addArrangedSubview(paymentDueBlock)
        orderPaymentComponentsStackView.addArrangedSubview(cashGivenBlock)
        orderPaymentComponentsStackView.addArrangedSubview(changeDueBlock)
        orderPaymentView.addSubview(orderPaymentComponentsStackView)
        self.view.addSubview(orderPaymentView)
    }
    
    func layoutPaymentComponentsStack(){
        orderPaymentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderPaymentView, attribute: .trailing, relatedBy: .equal, toItem: paymentTypeSelectorView, attribute: .leading, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: orderPaymentView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.4, constant: 0).isActive = true
        NSLayoutConstraint(item: orderPaymentView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.5, constant: 0).isActive = true
        NSLayoutConstraint(item: orderPaymentView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -150).isActive = true
        
        orderPaymentComponentsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: orderPaymentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .leading, relatedBy: .equal, toItem: orderPaymentView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .trailing, relatedBy: .equal, toItem: orderPaymentView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: orderPaymentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderPaymentComponentsStackView, attribute: .centerY, relatedBy: .equal, toItem: orderPaymentView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    func layoutHeader(){
        NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    }
    
    func layoutBackButton(){
        NSLayoutConstraint(item: backButton, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: backButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        NIMBUS.OrderCreation?.updateCheckoutView()
    }

    func backButtonClicked() {
        orderViewManagerDelegate?.exitCheckout()
    }
    
    func setOrderPaymentDetails(orderPayment: paymentInformation) {
        self.orderPayment = orderPayment
    }
    
    func giftCardPaySet(giftCardPay: Float){
        self.giftCardPay = giftCardPay
    }
    
    func refreshOrderPaymentDetails(){
        if orderPayment?.method == AcceptedPaymentMethods.cash.key {
            updateCashPaymentLabels()
        } else if orderPayment?.method == AcceptedPaymentMethods.card.key {
            updateCardPaymentLabels()
        }
        
        printReceiptSwitch.switchElement.setOn(NIMBUS.OrderCreation?.printOrderReceipt ?? false, animated: false)
        cashDrawerSwitch.switchElement.setOn(NIMBUS.OrderCreation?.openCashDrawer ?? false, animated: false)
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
        
        cashPaymentTypeButton.isSelected = true
        cardPaymentTypeButton.isSelected = false
        
        completeOrderButton.setTitle("Order Completed by Cash", for: .normal)
        
        keypadView.isHidden = false
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
        
        cashPaymentTypeButton.isSelected = false
        cardPaymentTypeButton.isSelected = true
        
        completeOrderButton.setTitle("Order Completed by Card", for: .normal)
        
        keypadView.isHidden = true
    }
    
    func cashPaymentTypeSelected() {
        NIMBUS.OrderCreation?.setPaymentMethod(method: AcceptedPaymentMethods.cash)
    }
    
    func cardPaymentTypeSelected(_ sender: UIButton) {
        NIMBUS.OrderCreation?.setPaymentMethod(method: AcceptedPaymentMethods.card)
    }
    
    func printSwitchStateChange(){
        NIMBUS.OrderCreation?.printOrderReceipt = printReceiptSwitch.switchElement.isOn
    }
    
    func cashDrawerSwitchStateChange(){
        NIMBUS.OrderCreation?.openCashDrawer = cashDrawerSwitch.switchElement.isOn
    }
    
    func completeOrder() {
        NIMBUS.OrderCreation?.completeOrder()
    }
    
    func openOrderDiscounts(){
        orderAdjustmentsView.presentModal()
    }
    
    func dismissAdjustmentsView(){
        orderAdjustmentsView.dismissModal()
    }
}
