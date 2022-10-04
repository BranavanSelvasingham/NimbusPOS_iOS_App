//
//  OrderSummaryManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-08.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol OrderSummaryManagerDelegate {
    func customerSelected(customer: Customer?)
    func tableSelected(table: Table?)
    func orderInformationSet(orderInfo: orderInfoSchema?)
    func orderSubtotalsSet(orderSubtotals: orderPriceSchema?)
    func giftCardPaySet(giftCardPay: Float)
    func waiterSelected(waiter: Employee?)
    func dismissOptionsModal()
    func showOptionsModal()
    func orderListEmpty(orderEmpty: Bool)
    func refreshItemsList()
}

class OrderSummaryManager: UIViewController {
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    
    //Header Section Variables
    var headerView: UIStackView = UIStackView()
    var headerViewBackground: UIViewWithShadow = UIViewWithShadow()
    
    var topHeaderSection: UIView = UIView()
    var refreshButton: MDCFloatingButton = MDCFloatingButton()
    var orderTypeButton: MDCButton = MDCButton()
    
    var customerHeaderSection: MDCCard = MDCCard()
    var customerNameLabel: UILabel = UILabel()
    var clearCustomerButton: MDCFlatButton = MDCFlatButton()
    
    var tableHeaderSection: MDCCard = MDCCard()
    var tableLabel: UILabel = UILabel()
    var seatSelectionHeaderSection: UIView = UIView()
    var seatSelector: SeatsSelectCollectionViewController!
    
    var waiterHeaderSection: UIView = UIView()
    var waiterButton: MDCButton = MDCButton()
    
    var orderInformation: orderInfoSchema? = nil {
        didSet{
            updateViewWithOrderInformation()
            orderViewManagerDelegate?.setOrderType(orderType: _OrderTypes(rawValue: (orderInformation?.orderType ?? "" )) ?? _OrderTypes.Express)
        }
    }
    
    var customer: Customer? = nil {
        didSet {
            if customer != nil {
                customerHeaderSection.isHidden = false
                customerNameLabel.text = customer?.name
                headerView.sizeToFit()
            } else {
                customerHeaderSection.isHidden = true
                headerView.sizeToFit()
            }
        }
    }
    
    var table: Table? = nil {
        didSet{
            if table != nil {
                waiterHeaderSection.isHidden = false
                tableHeaderSection.isHidden = false
                tableLabel.text = "Table: " + (table?.tableLabel ?? "N/A")
                headerView.sizeToFit()
            } else {
                waiterHeaderSection.isHidden = true
                tableHeaderSection.isHidden = true
                tableLabel.text = "Table: "
                headerView.sizeToFit()
            }
            seatSelector.table = table
        }
    }
    
    var waiter: Employee? = nil {
        didSet {
            if waiter != nil {
                waiterHeaderSection.isHidden = false
                waiterButton.setTitle("by: " + (waiter?.name ?? "?"), for: .normal)
                headerView.sizeToFit()
            } else {
                waiterButton.setTitle("Select Waiter", for: .normal)
                headerView.sizeToFit()
            }
        }
    }
    
    //Order Items Variables
    var orderItemsView: UIView = UIView()
    var orderItemsTableVC: OrderItemsTableViewController = OrderItemsTableViewController()
    
    //Order Footer Variables
    var orderFooterView: UIView = UIView()
    var orderItemsSubtotalsStackView: UIStackView = UIStackView()
    
    var subtotalBlock: TwoLabelBlock = TwoLabelBlock()
    var discountsBlock: TwoLabelBlock = TwoLabelBlock()
    var adjustmentsBlock: TwoLabelBlock = TwoLabelBlock()
    var taxesBlock: TwoLabelBlock = TwoLabelBlock()
    var totalBlock: TwoLabelBlock = TwoLabelBlock()
    var giftCardBlock: TwoLabelBlock = TwoLabelBlock()
    var checkOutButton: MDCRaisedButton = MDCRaisedButton()
    
    var orderSubtotals: orderPriceSchema? = nil {
        didSet{
            if let orderSubtotals = orderSubtotals {
                if let subtotal = orderSubtotals.subtotal {
                    subtotalBlock.isHidden = false
                    subtotalBlock.label2.text = subtotal.toString(asMoney: true, toDecimalPlaces: 2)
                } else {
                    subtotalBlock.isHidden = true
                }
                
                if let discounts = orderSubtotals.discount {
                    if discounts > 0 || discounts < 0 {
                        discountsBlock.isHidden = false
                        discountsBlock.label2.text = discounts.toString(asMoney: true, toDecimalPlaces: 2)
                    }
                } else {
                    discountsBlock.isHidden = true
                }
                
                if let adjustments = orderSubtotals.adjustments {
                    if adjustments > 0  || adjustments < 0 {
                        adjustmentsBlock.isHidden = false
                        adjustmentsBlock.label2.text = (-1 * adjustments).toString(asMoney: true, toDecimalPlaces: 2)
                    }
                } else {
                    adjustmentsBlock.isHidden = true
                }
                
                if let taxes = orderSubtotals.tax {
                    taxesBlock.isHidden = false
                    taxesBlock.label2.text = taxes.toString(asMoney: true, toDecimalPlaces: 2)
                } else {
                    taxesBlock.isHidden = true
                }
                
                if let total = orderSubtotals.total {
                    totalBlock.label2.text = total.toString(asMoney: true, toDecimalPlaces: 2)
                } else {
                    totalBlock.label2.text = "$0.00"
                }
            }
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

    //
    var orderToolBarView: UIView = UIView()
    
    
    //Background
    var backgroundImageView: UIImageView = UIImageView()
    
    //Order List
    var orderEmpty: Bool = true {
        didSet {
            if orderEmpty == true {
                orderIsEmpty()
            } else {
                orderIsActive()
            }
        }
    }
    
    //Toolbar
    let toolbarView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.backgroundColor = UIColor.gray
        view.setDefaultElevation()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 360).isActive = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    var toolbarViewConstraint: NSLayoutConstraint?

    let minimizeToolbar: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_expand_more_white"), for: .normal)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(hideToolbar), for: .touchUpInside)
        return button
    }()
    
    let openCashDrawerButton: MDCFloatingButton = {
        let button = MDCFloatingButton()
        button.setImage(UIImage(named: "ic_open_cash_drawer_white"), for: .normal)
        button.addTarget(self, action: #selector(openCashDrawer), for: .touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let reviewRecentOrderButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Review Recent Order", for: .normal)
        button.setTitleFont(MDCTypography.subheadFont(), for: .normal)
        button.addTarget(self, action: #selector(openRecentReviewOrder), for: .touchUpInside)
        button.isUppercaseTitle = false
        button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    let orderHistoryButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Order History", for: .normal)
        button.setTitleFont(MDCTypography.subheadFont(), for: .normal)
        button.addTarget(self, action: #selector(goToOrderHistory), for: .touchUpInside)
        button.isUppercaseTitle = false
        button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    let openOrdersButton: MDCRaisedButton = {
        let button = MDCRaisedButton()
        button.setTitle("Open Orders", for: .normal)
        button.setTitleFont(MDCTypography.subheadFont(), for: .normal)
        button.addTarget(self, action: #selector(goToOpenOrders), for: .touchUpInside)
        button.isUppercaseTitle = false
        button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    //Open Orders
    var openOrder: Order?
    var openOrderMode: _OpenOrderModes? {
        didSet {
            if openOrderMode == _OpenOrderModes.CheckoutOpenOrder {
                checkOutButton.setTitle("Checkout", for: .normal)
            } else if openOrderMode == _OpenOrderModes.UpdateOpenOrder {
                checkOutButton.setTitle("Update", for: .normal)
            } else {
                updateViewWithOrderInformation()
            }
        }
    }
    
    //Functions
    override func viewDidLoad() {
        loadHeaderItems()
        
        loadOrderItemsSection()
        
        loadBackground()
        
        loadOrderFooter()
        
        loadToolbar()
    }
    
    override func viewWillLayoutSubviews() {
        self.view.addSubview(topHeaderSection)
        self.view.addSubview(headerView)
        self.view.addSubview(headerViewBackground)
        self.view.addSubview(orderFooterView)
        self.view.addSubview(orderItemsView)
        self.view.addSubview(backgroundImageView)
        self.view.addSubview(toolbarView)
        
        self.view.bringSubview(toFront: topHeaderSection)
        self.view.bringSubview(toFront: headerView)
        self.view.bringSubview(toFront: toolbarView)
        
        self.view.sendSubview(toBack: orderItemsView)
        self.view.sendSubview(toBack: backgroundImageView)
        
        layoutHeaderItems()
        
        layoutOrderItemsSection()
        
        layoutBackground()
        
        layoutOrderFooter()
        
        layoutToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.updatePricingLabels()
        
        NIMBUS.OrderCreation?.resetOrder()
    }
    
    func loadToolbar(){
        toolbarView.addSubview(minimizeToolbar)
        toolbarView.addSubview(reviewRecentOrderButton)
        toolbarView.addSubview(openCashDrawerButton)
        toolbarView.addSubview(orderHistoryButton)
        toolbarView.addSubview(openOrdersButton)
    }
    
    func layoutToolbar(){
        NSLayoutConstraint(item: toolbarView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbarView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: minimizeToolbar, attribute: .top, relatedBy: .equal, toItem: toolbarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: minimizeToolbar, attribute: .centerX, relatedBy: .equal, toItem: toolbarView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: openCashDrawerButton, attribute: .top, relatedBy: .equal, toItem: toolbarView, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: openCashDrawerButton, attribute: .trailing, relatedBy: .equal, toItem: toolbarView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        
        NSLayoutConstraint(item: reviewRecentOrderButton, attribute: .leading, relatedBy: .equal, toItem: toolbarView, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: reviewRecentOrderButton, attribute: .trailing, relatedBy: .equal, toItem: toolbarView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: reviewRecentOrderButton, attribute: .bottom, relatedBy: .equal, toItem: openOrdersButton, attribute: .top, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: reviewRecentOrderButton, attribute: .centerX, relatedBy: .equal, toItem: toolbarView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: openOrdersButton, attribute: .leading, relatedBy: .equal, toItem: toolbarView, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: openOrdersButton, attribute: .trailing, relatedBy: .equal, toItem: toolbarView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: openOrdersButton, attribute: .bottom, relatedBy: .equal, toItem: orderHistoryButton, attribute: .top, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: openOrdersButton, attribute: .centerX, relatedBy: .equal, toItem: toolbarView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderHistoryButton, attribute: .leading, relatedBy: .equal, toItem: toolbarView, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: orderHistoryButton, attribute: .trailing, relatedBy: .equal, toItem: toolbarView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        NSLayoutConstraint(item: orderHistoryButton, attribute: .bottom, relatedBy: .equal, toItem: toolbarView, attribute: .bottom, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: orderHistoryButton, attribute: .centerX, relatedBy: .equal, toItem: toolbarView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
    }
    
    func loadOrderFooter(){
        let amountsLabelWidth: Int = 100
        
        let labelFont = MDCTypography.subheadFont()
        
        subtotalBlock = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.white, labelFont: labelFont)
        discountsBlock = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.white, labelFont: labelFont)
        adjustmentsBlock = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.white, labelFont: labelFont)
        taxesBlock = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.white, labelFont: labelFont)
        totalBlock = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.white, labelFont: MDCTypography.titleFont())
        giftCardBlock = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.white, labelFont: MDCTypography.titleFont())
        
        subtotalBlock.label1.text = "Subtotal"
        discountsBlock.label1.text = "Discounts"
        adjustmentsBlock.label1.text = "Adjustments"
        taxesBlock.label1.text = "Taxes"
        totalBlock.label1.text = "Total"
        giftCardBlock.label1.text = "Gift Card"
        
        subtotalBlock.label2.text = "$0.00"
        discountsBlock.label2.text = "$0.00"
        adjustmentsBlock.label2.text = "$0.00"
        taxesBlock.label2.text = "$0.00"
        totalBlock.label2.text = "$0.00"
        giftCardBlock.label2.text = "$0.00"
        
        orderItemsSubtotalsStackView.axis = .vertical
        orderItemsSubtotalsStackView.distribution = .equalSpacing
        
        checkOutButton.setTitle("Checkout", for: .normal)
        checkOutButton.setTitleColor(UIColor.white, for: .normal)
        checkOutButton.backgroundColor = UIColor().nimbusBlue
        checkOutButton.addTarget(self, action: #selector(checkoutButtonClicked), for: .touchUpInside)
        
        subtotalBlock.isHidden = true
        discountsBlock.isHidden = true
        adjustmentsBlock.isHidden = true
        taxesBlock.isHidden = true
        
        self.orderItemsSubtotalsStackView.addArrangedSubview(subtotalBlock)
        self.orderItemsSubtotalsStackView.addArrangedSubview(discountsBlock)
        self.orderItemsSubtotalsStackView.addArrangedSubview(adjustmentsBlock)
        self.orderItemsSubtotalsStackView.addArrangedSubview(taxesBlock)
        self.orderItemsSubtotalsStackView.addArrangedSubview(totalBlock)
        self.orderItemsSubtotalsStackView.addArrangedSubview(giftCardBlock)
        
        self.orderFooterView.addSubview(orderItemsSubtotalsStackView)
        self.orderFooterView.addSubview(checkOutButton)
    }
    
    func layoutOrderFooter(){
        let blockHeight: CGFloat = 25
        let checkOutButtonWidth: CGFloat = 130
        let minOrderFooterViewHeight: CGFloat = 150
        
        subtotalBlock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: subtotalBlock, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true
        
        discountsBlock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: discountsBlock, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true

        adjustmentsBlock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: adjustmentsBlock, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true

        taxesBlock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: taxesBlock, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true

        totalBlock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: totalBlock, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true

        giftCardBlock.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: giftCardBlock, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true
        
        orderItemsSubtotalsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderItemsSubtotalsStackView, attribute: .centerY, relatedBy: .equal, toItem: orderFooterView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsSubtotalsStackView, attribute: .leading, relatedBy: .equal, toItem: orderFooterView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsSubtotalsStackView, attribute: .trailing, relatedBy: .equal, toItem: checkOutButton, attribute: .leading, multiplier: 1, constant: -15).isActive = true
//        NSLayoutConstraint(item: orderItemsSubtotalsStackView, attribute: .bottom, relatedBy: .equal, toItem: orderFooterView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        checkOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: checkOutButton, attribute: .top, relatedBy: .equal, toItem: orderFooterView, attribute: .top, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: checkOutButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: checkOutButtonWidth).isActive = true
//        NSLayoutConstraint(item: checkOutButton, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: checkOutButtonWidth).isActive = true
        NSLayoutConstraint(item: checkOutButton, attribute: .trailing, relatedBy: .equal, toItem: orderFooterView, attribute: .trailing, multiplier: 1, constant: -5).isActive = true
        NSLayoutConstraint(item: checkOutButton, attribute: .bottom, relatedBy: .equal, toItem: orderFooterView, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
        
        orderFooterView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint(item: orderFooterView, attribute: .top, relatedBy: .equal, toItem: orderItemsSubtotalsStackView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderFooterView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderFooterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderFooterView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderFooterView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: minOrderFooterViewHeight).isActive = true
    }
    
    func loadBackground(){
        let backgroundImage = UIImage(named: "background_paper_white_1")
        backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
    }
    
    func layoutBackground(){
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func loadHeaderItems(){
        topHeaderSection.backgroundColor = UIColor.clear
        headerView.backgroundColor = UIColor.clear
        headerViewBackground.backgroundColor = UIColor.white
        headerViewBackground.setDefaultElevation()
        
        headerView.axis = .vertical
        headerView.distribution = .equalSpacing
        headerView.spacing = 10
        headerView.alignment = .fill
        
        orderFooterView.backgroundColor = UIColor().nimbusBlue
        
        refreshButton.addTarget(self, action: #selector(refreshOrder), for: .touchUpInside)
        refreshButton.setImage(UIImage(named: "ic_refresh_white"), for: .normal)
        refreshButton.setBackgroundColor(UIColor.lightGray)
        
        orderTypeButton.addTarget(self, action: #selector(selectOrderType), for: .touchUpInside)
        orderTypeButton.setTitle("Select Order Type", for: .normal)
        orderTypeButton.setTitleColor(UIColor.gray, for: .normal)
        orderTypeButton.setElevation( .raisedButtonResting , for: .normal)
        orderTypeButton.setBackgroundColor(UIColor.white)
        
        clearCustomerButton.addTarget(self, action: #selector(clearSelectedCustomer), for: .touchUpInside)
        clearCustomerButton.setImage(UIImage(named: "ic_clear"), for: .normal)
        clearCustomerButton.setBackgroundColor(UIColor.white)
        
        customerNameLabel.text = "Customer Name"
        customerNameLabel.textAlignment = .center
        customerNameLabel.textColor = UIColor.gray
        
        tableLabel.text = "Table: Table Label"
        tableLabel.textAlignment = .left
        tableLabel.textColor = UIColor.gray
        
        topHeaderSection.addSubview(orderTypeButton)
        topHeaderSection.addSubview(refreshButton)
        
        customerHeaderSection.addSubview(clearCustomerButton)
        customerHeaderSection.addSubview(customerNameLabel)
        
        tableHeaderSection.addSubview(tableLabel)
        tableHeaderSection.addSubview(seatSelectionHeaderSection)
        
        waiterButton.addTarget(self, action: #selector(selectWaiter), for: .touchUpInside)
        waiterButton.setTitle("Select Waiter", for: .normal)
        waiterButton.isUppercaseTitle = false
        waiterButton.setTitleColor(UIColor.gray, for: .normal)
        waiterButton.setElevation( .raisedButtonResting , for: .normal)
        waiterButton.setBackgroundColor(UIColor.white)
        
        waiterHeaderSection.addSubview(waiterButton)
        
        headerView.addArrangedSubview(customerHeaderSection)
        headerView.addArrangedSubview(tableHeaderSection)
        headerView.addArrangedSubview(waiterHeaderSection)
        
        startupSeatSelector()
        
        NIMBUS.OrderCreation?.orderSummaryManagerDelegate = self
        
        customerHeaderSection.isHidden = true
        tableHeaderSection.isHidden = true
        waiterHeaderSection.isHidden = true
    }
    
    func layoutHeaderItems(){
        let leftGap: CGFloat = 10
        let rightGap: CGFloat = -10
        let verticalGap: CGFloat = 10
        let sectionHeight: CGFloat = 50
        
        topHeaderSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: topHeaderSection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: topHeaderSection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: topHeaderSection, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        //        NSLayoutConstraint(item: topHeaderSection, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: sectionHeight).isActive = true
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: topHeaderSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10).isActive = true
        //        NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 150).isActive = true
        
        headerViewBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: headerViewBackground, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerViewBackground, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerViewBackground, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerViewBackground, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 10).isActive = true
        
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: refreshButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: topHeaderSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: refreshButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: topHeaderSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: refreshButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: refreshButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: refreshButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: topHeaderSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        
        orderTypeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderTypeButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: topHeaderSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: orderTypeButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: topHeaderSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: leftGap).isActive = true
        NSLayoutConstraint(item: orderTypeButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: refreshButton, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: rightGap).isActive = true
        NSLayoutConstraint(item: orderTypeButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: topHeaderSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -5).isActive = true
        
        waiterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: waiterButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: waiterHeaderSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: waiterButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: waiterHeaderSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: waiterButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: waiterHeaderSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: waiterButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: waiterHeaderSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: waiterButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: sectionHeight).isActive = true
        
        customerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: customerNameLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: customerHeaderSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customerNameLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: customerHeaderSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customerNameLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: clearCustomerButton, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: customerNameLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: sectionHeight).isActive = true
        NSLayoutConstraint(item: customerNameLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: customerHeaderSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        
        clearCustomerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: clearCustomerButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: customerHeaderSection, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: clearCustomerButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: sectionHeight).isActive = true
        NSLayoutConstraint(item: clearCustomerButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: sectionHeight * 1.2).isActive = true
        NSLayoutConstraint(item: clearCustomerButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: customerHeaderSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        
        tableLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: tableLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: tableHeaderSection, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: tableHeaderSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: leftGap).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: tableHeaderSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: rightGap).isActive = true
        NSLayoutConstraint(item: tableLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: sectionHeight * 0.6).isActive = true
        
        seatSelectionHeaderSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: seatSelectionHeaderSection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: tableLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: seatSelectionHeaderSection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: tableHeaderSection, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: leftGap).isActive = true
        NSLayoutConstraint(item: seatSelectionHeaderSection, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: tableHeaderSection, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: rightGap).isActive = true
        NSLayoutConstraint(item: seatSelectionHeaderSection, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: sectionHeight).isActive = true
        NSLayoutConstraint(item: seatSelectionHeaderSection, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: tableHeaderSection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func loadOrderItemsSection(){
        self.addChildViewController(orderItemsTableVC)
        orderItemsTableVC.orderSummaryManagerDelegate = self
        orderItemsTableVC.didMove(toParentViewController: self)
        
        orderItemsView.backgroundColor = UIColor.clear
        
        orderItemsView.addSubview(orderItemsTableVC.view)
    }
    
    func layoutOrderItemsSection(){
        orderItemsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderItemsView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: headerViewBackground, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: orderFooterView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        
        let orderItemsTableView = orderItemsTableVC.view!
        orderItemsTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderItemsTableView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: orderItemsView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsTableView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: orderItemsView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsTableView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: orderItemsView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsTableView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: orderItemsView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func startupSeatSelector(){
        let seatCellSize = CGSize(width: 100, height: 40)
        let seatCellInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        
        let seatsLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        seatsLayout.sectionInset = seatCellInsets
        seatsLayout.itemSize = seatCellSize
        seatsLayout.scrollDirection = .horizontal
        
        seatSelector = SeatsSelectCollectionViewController(collectionViewLayout: seatsLayout)
        
        self.addChildViewController(seatSelector)
        seatSelectionHeaderSection.addSubview(seatSelector.view)
        seatSelector.view.frame = seatSelectionHeaderSection.frame
        seatSelector.didMove(toParentViewController: self)
    }
    
    func refreshOrder(){
        NIMBUS.OrderCreation?.resetOrder()
    }
    
    func selectOrderType() {
        orderViewManagerDelegate?.openOrderTypeModal()
    }
    
    func clearSelectedCustomer(){
        NIMBUS.OrderCreation?.clearCustomerInfo()
    }
    
    func selectWaiter(){
        orderViewManagerDelegate?.openWaiterSelectorModal()
    }
    
    func updatePricingLabels(){
        self.orderSubtotals = nil
        self.giftCardPay = 0
    }
    
    func orderIsEmpty(){
        checkOutButton.isEnabled = false
        showToolbar()
    }
    
    func orderIsActive(){
        checkOutButton.isEnabled = true
        hideToolbar()
    }
    
    func updateViewWithOrderInformation(){
        if let orderType = orderInformation?.orderType {
            if orderType.isEmpty {
                self.orderTypeButton.setTitle("Select Order Type", for: .normal)
            } else {
                self.orderTypeButton.setTitle(orderType + " Order", for: .normal)
                
                if orderType == _OrderTypes.Express.rawValue {
                    checkOutButton.setTitle("Checkout", for: .normal)
                } else {
                    if openOrderMode == nil || openOrderMode == _OpenOrderModes.NotOpenOrder {
                        checkOutButton.setTitle("Create", for: .normal)
                    }
                }
                
            }
        }
    }
    
    func checkoutButtonClicked() {
        NIMBUS.OrderCreation?.initializeOrderPaymentValues()
        let (checkoutReady, errorReason) = (NIMBUS.OrderCreation?.isOrderReadyForCheckout())!
        if checkoutReady == true {
            if let orderType = orderInformation?.orderType {
                if orderType == _OrderTypes.Express.rawValue {
                    orderViewManagerDelegate?.startCheckout()
                } else {
                    if openOrderMode == _OpenOrderModes.UpdateOpenOrder {
                        NIMBUS.OrderCreation?.updateOpenOrder()
                    } else if openOrderMode == _OpenOrderModes.CheckoutOpenOrder {
                        orderViewManagerDelegate?.startCheckout()
                    } else {
                        NIMBUS.OrderCreation?.createOpenOrder()
                    }
                }
            }
        } else {
//            print(errorReason)
//            if errorReason == "WAITER" {
//                performSegue(withIdentifier: "segueToEmployeesList", sender: nil)
//            }
        }
    }
    
    func showToolbar(){
        self.toolbarViewConstraint?.isActive = false
        self.toolbarViewConstraint = NSLayoutConstraint(item: self.toolbarView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 10)
        self.toolbarViewConstraint?.isActive = true
    }
    
    func hideToolbar(){
        self.toolbarViewConstraint?.isActive = false
        self.toolbarViewConstraint = NSLayoutConstraint(item: self.toolbarView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.toolbarViewConstraint?.isActive = true
    }
    
    func goToOrderHistory(){
        NIMBUS.Navigation?.loadOrderHistoryView()
    }
    
    func goToOpenOrders(){
        NIMBUS.Navigation?.loadOpenOrdersView()
    }
}

extension OrderSummaryManager: OrderSummaryManagerDelegate{
    func dismissOptionsModal() {
        orderViewManagerDelegate?.dismissOptionsModal()
    }
    
    func showOptionsModal() {
        orderViewManagerDelegate?.showOptionsModal()
    }
    
    func customerSelected(customer: Customer?) {
        self.customer = customer
    }
    
    func tableSelected(table: Table?) {
        self.table = table
    }
    
    func orderInformationSet(orderInfo: orderInfoSchema?) {
        self.orderInformation = orderInfo
    }
    
    func waiterSelected(waiter: Employee?) {
        self.waiter = waiter
    }
    
    func orderSubtotalsSet(orderSubtotals: orderPriceSchema?){
        self.orderSubtotals = orderSubtotals
    }
    
    func giftCardPaySet(giftCardPay: Float){
        self.giftCardPay = giftCardPay
    }
    
    func orderListEmpty(orderEmpty: Bool) {
        self.orderEmpty = orderEmpty
    }
    
    func refreshItemsList() {
        self.orderItemsTableVC.tableView.reloadData()
    }
    
    func openCashDrawer(){
        NIMBUS.Print?.openCashDrawer()
    }
    
    func openRecentReviewOrder(){
        orderViewManagerDelegate?.openRecentOrderModal(withSelfDismiss: false)
    }
}
