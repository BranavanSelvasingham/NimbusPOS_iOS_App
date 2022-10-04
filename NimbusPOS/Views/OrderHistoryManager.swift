//
//  OrderHistoryManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol OrderHistoryManagerDelegate {
    func orderSelected(order: Order)
}

class OrderHistoryManager: UIViewController, OrderHistoryManagerDelegate {
    var orderHistoryListVC: OrderHistoryListViewController = OrderHistoryListViewController()
    var orderDetailVC: OrderDetailViewController = OrderDetailViewController()
    var pageView: PageView = PageView()
    
    var selectedOrder: Order? {
        didSet {
            orderDetailVC.order = selectedOrder
        }
    }
    
    let deleteButton: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_delete"), for: .normal)
        button.addTarget(self, action: #selector(deleteOrder), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let printButton: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_print"), for: .normal)
        button.addTarget(self, action: #selector(printOrder), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let historySettingBlock: IconAndLabelBlock = {
        let orderHistoryLimitOptions: [Int] = [7, 14, 31]
        let orderHistoryLimitOptionTitles: [Int: String] = [7: "7 Days", 14: "14 Days", 31: "31 Days"]
        
        let selectedLocalOrderHistoryLimit = NIMBUS.Data?.localOrderHistoryLimit ?? 7
        let historySetting: String = orderHistoryLimitOptionTitles[selectedLocalOrderHistoryLimit] ?? ""
        
        let historyImage: UIImage = UIImage(named: "ic_history_18pt") ?? UIImage()

        let block = IconAndLabelBlock(frame: CGRect(x: 0, y: 0, width: 100, height: 50), iconImage: historyImage, labelText: historySetting, labelFont: MDCTypography.body1Font(), labelTextAlignment: .left, labelTextColor: UIColor.gray)
        return block
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageView = PageView(frame: self.view.frame, screenSplitRatio: 0.55)
        pageView.leftSection.setHeaderTitle(title: "Order History")
        pageView.leftSection.setRightTitleNote(sideView: historySettingBlock)
        
        orderHistoryListVC.orderListManagerDelegate = self
        self.addChildViewController(orderHistoryListVC)
        pageView.addTableViewToLeftSection(tableView: orderHistoryListVC.view)
        orderHistoryListVC.didMove(toParentViewController: self)
        
        orderDetailVC.orderHistoryManagerDelegate = self
        self.addChildViewController(orderDetailVC)
        pageView.addDetailViewToRightSection(detailView: orderDetailVC.view)
        orderDetailVC.didMove(toParentViewController: self)
        
        self.view.addSubview(pageView)
        
        pageView.rightSection.headerView.addSubview(deleteButton)
        pageView.rightSection.headerView.addSubview(printButton)
        
        NIMBUS.OrderManagement?.deleteAllOutOfHistoryScopeLocalOrders()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        pageView.frame = self.view.frame
        
        let rightHeader = pageView.rightSection.headerView
        NSLayoutConstraint(item: printButton, attribute: .centerY, relatedBy: .equal, toItem: rightHeader, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printButton, attribute: .leading, relatedBy: .equal, toItem: rightHeader, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        
        NSLayoutConstraint(item: deleteButton, attribute: .centerY, relatedBy: .equal, toItem: rightHeader, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: deleteButton, attribute: .trailing, relatedBy: .equal, toItem: rightHeader, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    func orderSelected(order: Order){
        self.selectedOrder = order
    }
    
    func deleteOrder(){
        if let orderId = selectedOrder?.id {
            NIMBUS.OrderManagement?.cancelOrder(orderId: orderId)
        }
    }
    
    func printOrder(){
        if let orderId = selectedOrder?.id {
            NIMBUS.OrderManagement?.printOrder(orderId: orderId)
        }
    }
}
