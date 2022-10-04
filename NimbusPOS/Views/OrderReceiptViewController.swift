//
//  OrderReceiptViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class OrderReceiptViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var orderMO: Order? {
        didSet {
            let orderAsStruct = orderSchema(withManagedObject: orderMO)
            order = orderAsStruct
        }
    }
    
    var order: orderSchema? = nil {
        didSet {
            DispatchQueue.main.async {
                if self.order?._id != nil {
                    self.receiptView.isHidden = false
                    
                    self.refreshHeaderLabels()
                    
                    self.refreshFoorterLabels()
                    
                    self.refreshItemsTable()
                    
                    if let customerId = self.order?.customerId {
                        self.orderCustomer = NIMBUS.Customers?.getCustomerById(id: customerId)
                    } else {
                        self.customerLabel.isHidden = true
                    }
                    
                    if let waiterId = self.order?.waiterId {
                        self.orderWaiter = NIMBUS.Employees?.getEmployeeById(employeeId: waiterId)
                    } else {
                        self.waiterLabel.isHidden = true
                    }
                    
                    if let tableId = self.order?.tableId {
                        self.orderTable = NIMBUS.Tables?.getTableById(tableId: tableId)
                    } else {
                        self.tableLabel.isHidden = true
                    }
                    
                    if self.order?.status == _OrderStatus.Cancelled.rawValue {
                        self.orderCancelled.isHidden = false
                    } else {
                        self.orderCancelled.isHidden = true
                    }
                    
                    self.refreshScrollView()
                    
                } else {
                    self.emptyReceipt()
                }
            }
        }
    }
    
    var orderCustomer: Customer? = nil {
        didSet {
            if orderCustomer != nil {
                customerLabel.text = "For " + (orderCustomer?.name ?? "??")
                customerLabel.isHidden = false
            } else {
                customerLabel.isHidden = true
            }
        }
    }
    
    var orderWaiter: Employee? = nil {
        didSet {
            if orderWaiter != nil {
                waiterLabel.text = "By " + (orderWaiter?.name ?? "??" )
                waiterLabel.isHidden = false
            } else {
                waiterLabel.isHidden = true
            }
        }
    }
    
    var orderTable: Table? = nil {
        didSet {
            if orderTable != nil {
                tableLabel.text = "Table: " + (orderTable?.tableLabel ?? "??")
                tableLabel.isHidden = false
            } else {
                tableLabel.isHidden = true
            }
        }
    }
    
    func refreshScrollView(){
        self.view.setNeedsUpdateConstraints()
        var height = footerView.frame.maxY
        height = receiptView.frame.height
        receiptScrollView.contentSize.height = height
    }
    
    func refreshHeaderLabels(){
        if let location = NIMBUS.Location?.getLocationById(locationId: order?.locationId ?? " ") {
            locationLabel.text = location.name
            locationStreet.text = location.addressStreet
        } else {
            locationLabel.text = "Location Unknown?!"
            locationStreet.text = "Location Address Unknown?!"
        }
        
        uniqueOrderNumberLabel.text = "Order #: " + (order?.formattedUniqueOrderNumber() ?? "??")
        dailyOrderNumberLabel.text = order?.formattedDailyOrderNumber()
        orderDateLabel.text = order?.formattedCreatedDate(includeTime: true, longDate: true)
    }
    
    func refreshFoorterLabels(){
        subtotalBlock.setAmountToLabel2(optionalAmount: order?.subtotals?.subtotal)
        discountsBlock.setAmountToLabel2(optionalAmount: order?.subtotals?.discount)
        adjustmentsBlock.setAmountToLabel2(optionalAmount: order?.subtotals?.adjustments)
        taxesBlock.setAmountToLabel2(optionalAmount: order?.subtotals?.tax)
        totalBlock.setAmountToLabel2(optionalAmount: order?.subtotals?.total)
        
        giftCardBlock.setAmountToLabel2(optionalAmount: order?.payment?.giftCardTotal)
        paymentReceivedBlock.setAmountToLabel2(optionalAmount: order?.payment?.received)
    }
    
    func refreshItemsTable(){
        orderItemsTableView.reloadData()
        orderItemsTableView.layoutIfNeeded()
    }
    
    func refreshItemsTableHeight(){
        self.tableHeight?.isActive = false
        self.tableHeight = NSLayoutConstraint(item: self.orderItemsTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.orderItemsTableView.contentSize.height)
        self.tableHeight?.isActive = true
    }
    
    func emptyReceipt(){
        receiptView.isHidden = true
    }
    
    let innerMargin: CGFloat = 10
    
    var receiptScrollView: UIScrollView = {
        let receiptScrollView = UIScrollView()
        receiptScrollView.translatesAutoresizingMaskIntoConstraints = false
        return receiptScrollView
    }()
    
    var receiptView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.shadowLayer.elevation = .cardPickedUp
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var backgroundImageViewHeight: NSLayoutConstraint?
    
    var tableHeight: NSLayoutConstraint?
    
    var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let headerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
//        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        return stack
    }()
    
    var businessLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.titleFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .center
        amountLabel.text = NIMBUS.Business?.getBusinessName()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return amountLabel
    }()
    
    var locationLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.subheadFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .center
        amountLabel.text = "Location Name"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return amountLabel
    }()
    
    var locationStreet: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.body1Font()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .center
        amountLabel.text = "Location Street"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        return amountLabel
    }()
    
    var orderDateLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.titleFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .center
        amountLabel.text = "Order Date"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return amountLabel
    }()
    
    var customerLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.titleFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .left
        amountLabel.text = "Customer Name"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return amountLabel
    }()
    
    var waiterLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.titleFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .right
        amountLabel.text = "Waiter Name"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return amountLabel
    }()
    
    var tableLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.titleFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .left
        amountLabel.text = "Table Label"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return amountLabel
    }()
    
    var uniqueOrderNumberLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.subheadFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .left
        amountLabel.text = "Unique Order#"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return amountLabel
    }()
    
    var dailyOrderNumberLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.titleFont()
        amountLabel.textColor = UIColor.black
        amountLabel.textAlignment = .right
        amountLabel.text = "Daily#"
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return amountLabel
    }()
    
    let footerStackView: UIStackView = {
        let stack = UIStackView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: 200)))
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.heightAnchor.constraint(lessThanOrEqualToConstant: 210).isActive = true
        return stack
    }()
    
//    var footerStackView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    var footerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var subtotalBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Subtotal:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        block.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return block
    }()
    
    var discountsBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Discounts:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        block.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return block
    }()
    
    var adjustmentsBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Adjustments:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        block.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return block
    }()
    
    var taxesBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Taxes:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        block.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return block
    }()
    
    var totalBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Total:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        block.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return block
    }()
    
    var giftCardBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Gift Card Payment:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        block.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return block
    }()
    
    var paymentReceivedBlock: TwoLabelBlock = {
        let labelFont = MDCTypography.titleFont()
        let amountsLabelWidth: Int = 100
        var block = TwoLabelBlock(splitBy: .label2Width, label2SplitValue: amountsLabelWidth, labelColor: UIColor.black, labelFont: labelFont)
        block.label1.text = "Payment Received:"
        block.label2.text = "$0.00"
        block.translatesAutoresizingMaskIntoConstraints = false
        block.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return block
    }()
    
    var orderCancelled: UILabel = {
        let label = UILabel()
        label.text = "CANCELLED"
        label.isHidden = true
        label.font = MDCTypography.titleFont()
        label.textColor = UIColor.red
        label.transform = CGAffineTransform.identity.rotated(by: CGFloat(-Double.pi/4))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return label
    }()
    
    class smartTableView: UITableView {
        var receiptDelegate: OrderReceiptViewController?
        
        override var contentSize: CGSize {
            didSet {
                receiptDelegate?.refreshItemsTableHeight()
            }
        }
    }
    
    var orderItemsTableView: smartTableView = {
        let tableView = smartTableView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(OrderReceiptItemCell.self, forCellReuseIdentifier: "orderReceiptItemCell")
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if order == nil { emptyReceipt() }
        
        orderItemsTableView.receiptDelegate = self
        
        self.view.addSubview(receiptScrollView)
        receiptScrollView.addSubview(receiptView)
        
        orderItemsTableView.delegate = self
        orderItemsTableView.dataSource = self
        
        let horizontalStackUniqueNumAndDailyNum = UIStackView(arrangedSubviews: [uniqueOrderNumberLabel, dailyOrderNumberLabel])
        horizontalStackUniqueNumAndDailyNum.axis = .horizontal
        
        let horizontalStackTableAndWaiter = UIStackView(arrangedSubviews: [tableLabel, waiterLabel])
        horizontalStackTableAndWaiter.axis = .horizontal
        
        headerStackView.addArrangedSubview(businessLabel)
        headerStackView.addArrangedSubview(locationLabel)
        headerStackView.addArrangedSubview(locationStreet)
        headerStackView.addArrangedSubview(orderDateLabel)
        headerStackView.addArrangedSubview(customerLabel)
        headerStackView.addArrangedSubview(horizontalStackUniqueNumAndDailyNum)
        headerStackView.addArrangedSubview(horizontalStackTableAndWaiter)
        
        
        headerView.addSubview(headerStackView)
        headerView.addSubview(orderCancelled)
        headerView.bringSubview(toFront: orderCancelled)
        
        receiptView.addSubview(headerView)
//        orderItemsTableView.tableHeaderView = headerView

        receiptView.addSubview(orderItemsTableView)
        
        footerStackView.addArrangedSubview(subtotalBlock)
        footerStackView.addArrangedSubview(discountsBlock)
        footerStackView.addArrangedSubview(adjustmentsBlock)
        footerStackView.addArrangedSubview(taxesBlock)
        footerStackView.addArrangedSubview(totalBlock)
        footerStackView.addArrangedSubview(giftCardBlock)
        footerStackView.addArrangedSubview(paymentReceivedBlock)
        
        footerView.addSubview(footerStackView)
        receiptView.addSubview(footerView)
//        orderItemsTableView.tableFooterView = footerView
        
        loadBackground()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint(item: receiptScrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptScrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptScrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: receiptScrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: receiptView, attribute: .top, relatedBy: .equal, toItem: receiptScrollView, attribute: .top, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .leading, relatedBy: .equal, toItem: receiptScrollView, attribute: .leading, multiplier: 1, constant: 15).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .width, relatedBy: .equal, toItem: receiptScrollView, attribute: .width, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: receiptView, attribute: .bottom, relatedBy: .equal, toItem: footerView, attribute: .bottom, multiplier: 1, constant: innerMargin).isActive = true
        
        NSLayoutConstraint(item: receiptView, attribute: .bottom, relatedBy: .equal, toItem: receiptScrollView, attribute: .bottom, multiplier: 1, constant: -30).isActive = true
        
        NSLayoutConstraint(item: headerStackView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerStackView, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerStackView, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: receiptView, attribute: .top, multiplier: 1, constant: innerMargin).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .leading, relatedBy: .equal, toItem: receiptView, attribute: .leading, multiplier: 1, constant: innerMargin).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .trailing, relatedBy: .equal, toItem: receiptView, attribute: .trailing, multiplier: 1, constant: -innerMargin).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .bottom, relatedBy: .equal, toItem: headerStackView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderCancelled, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: orderCancelled, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: orderItemsTableView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderItemsTableView, attribute: .leading, relatedBy: .equal, toItem: receiptView, attribute: .leading, multiplier: 1, constant: innerMargin).isActive = true
        NSLayoutConstraint(item: orderItemsTableView, attribute: .trailing, relatedBy: .equal, toItem: receiptView, attribute: .trailing, multiplier: 1, constant: -innerMargin).isActive = true
        
        NSLayoutConstraint(item: footerStackView, attribute: .top, relatedBy: .equal, toItem: footerView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: footerStackView, attribute: .leading, relatedBy: .equal, toItem: footerView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: footerStackView, attribute: .trailing, relatedBy: .equal, toItem: footerView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true

        NSLayoutConstraint(item: footerView, attribute: .top, relatedBy: .equal, toItem: orderItemsTableView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: footerView, attribute: .leading, relatedBy: .equal, toItem: receiptView, attribute: .leading, multiplier: 1, constant: innerMargin).isActive = true
        NSLayoutConstraint(item: footerView, attribute: .trailing, relatedBy: .equal, toItem: receiptView, attribute: .trailing, multiplier: 1, constant: -innerMargin).isActive = true
        NSLayoutConstraint(item: footerView, attribute: .bottom, relatedBy: .equal, toItem: footerStackView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func loadBackground(){
        let backgroundPatterImage = UIImage(named: "background_paper_white_2")!
        receiptView.backgroundColor = UIColor(patternImage: backgroundPatterImage)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return order?.getNumberOfOccupiedSeats() ?? 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.numberOfSections > 1 {
            if let allSeats = order?.getOccupiedSeatNumbers() {
                return "Seat: \(allSeats[section])"
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allSeats = order?.getOccupiedSeatNumbers() {
            let seatNumber = allSeats[section]
            let seatItems = order?.getOrderItemsForSeat(seatNumber: seatNumber)
            return seatItems?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderReceiptItemCell", for: indexPath) as! OrderReceiptItemCell
        if let allSeats = order?.getOccupiedSeatNumbers() {
            let seatNumber = allSeats[indexPath.section]
            if let seatItems = order?.getOrderItemsForSeat(seatNumber: seatNumber){
                let indexOrderItem = seatItems[indexPath.row]
                cell.initCell(cellOrderItem: indexOrderItem)
            }
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
