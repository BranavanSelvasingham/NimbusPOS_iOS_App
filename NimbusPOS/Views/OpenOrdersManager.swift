//
//  OpenOrdersManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-27.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol OpenOrdersManagerDelegate: OrderHistoryManagerDelegate {
    
}

class OpenOrdersManager: UIViewController, OpenOrdersManagerDelegate {
    
    var openOrdersCollectionVC: OpenOrdersCollectionVC!
    
    let headerView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.setDefaultElevation()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = MDCTypography.headlineFont()
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.text = "Open Orders"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let ticketBar: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.shadowLayer.elevation = .cardPickedUp
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.backgroundColor = UIColor(patternImage: UIImage(named: "ticket-holder-bar")!)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBackground()
        
        loadOpenOrdersCollection()
        loadHeader()
        loadTicketHolderBar()
    }
    
    override func viewWillLayoutSubviews() {
        layoutHeader()
        layoutOpenOrdersCollection()
        layoutTicketBar()
    }
    
    func loadTicketHolderBar(){
        self.view.addSubview(ticketBar)
        self.view.bringSubview(toFront: ticketBar)
    }
    
    func loadBackground(){
        let metalBackground = UIImage(named: "steel-background")!
        
        self.view.backgroundColor = UIColor(patternImage: metalBackground)
    }
    
    func loadHeader(){
        self.view.addSubview(headerView)
        self.view.bringSubview(toFront: headerView)
        
        headerView.addSubview(titleLabel)
    }
    
    func layoutTicketBar(){
        NSLayoutConstraint(item: ticketBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 80).isActive = true
        NSLayoutConstraint(item: ticketBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: ticketBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    }
    
    func layoutHeader(){
        NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: headerView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    func loadOpenOrdersCollection(){
        let slipCellHeight: CGFloat = self.view.frame.height - 125
        let slipCellWidth: CGFloat = 400
        let slipCellSize = CGSize(width: slipCellWidth, height: slipCellHeight)
        let slipCellInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let slipCellMinimumGap: CGFloat = 4
        
        let orderSlipLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        orderSlipLayout.sectionInset = slipCellInsets
        orderSlipLayout.itemSize = slipCellSize
        orderSlipLayout.scrollDirection = .horizontal
        orderSlipLayout.minimumInteritemSpacing = slipCellMinimumGap
        orderSlipLayout.minimumLineSpacing = slipCellMinimumGap
        
        openOrdersCollectionVC = OpenOrdersCollectionVC(collectionViewLayout: orderSlipLayout)
        self.addChildViewController(openOrdersCollectionVC)
        openOrdersCollectionVC.didMove(toParentViewController: self)
        openOrdersCollectionVC.openOrderManagerDelegate = self
        self.view.addSubview(openOrdersCollectionVC.view)
        self.view.sendSubview(toBack: openOrdersCollectionVC.view)
    }
    
    func layoutOpenOrdersCollection(){
        let collectionView = openOrdersCollectionVC.view!
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: ticketBar, attribute: .bottom, multiplier: 1, constant: -5).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func orderSelected(order: Order) {
        
    }
    
    
}
