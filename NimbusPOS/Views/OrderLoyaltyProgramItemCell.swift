//
//  OrderLoyaltyProgramItemCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-09.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class OrderLoyaltyProgramItemCell: OrderItemCell {
    var loyaltyCard: nimbusOrderCreationFunctions.orderLoyaltyCards? {
        get{
            return NIMBUS.OrderCreation?.getPrePurchaseLoyaltyCard(forOrderItem: cellOrderItem)
        }
    }
    
    var applyButton: MDCButton = MDCButton()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        applyButton.addTarget(self, action: #selector(applyLoyaltyProgram), for: .touchUpInside)
        applyButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        self.contentView.addSubview(applyButton)
        
        super.optionsButton.isEnabled = false
        super.optionsButton.isHidden = true
        
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: applyButton, attribute: .top, relatedBy: .equal, toItem: bottomBarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: applyButton, attribute: .centerX, relatedBy: .equal, toItem: bottomBarView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: applyButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: applyButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBarView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        setApplyButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func applyLoyaltyProgram() {
        didSelectCell()
        if let apply = loyaltyCard?.apply {
            NIMBUS.OrderCreation?.setPrePurchaseLoyaltyApplyStatus(loyaltyOrderItem: self.cellOrderItem, apply: !apply)
        }
    }
    
    func setApplyButton(){
        if loyaltyCard?.apply == true {
            applyButton.setTitle("Applied", for: .normal)
            applyButton.setTitleColor(UIColor.white, for: .normal)
            applyButton.backgroundColor = UIColor.color(fromHexString: "3bdb55")
        } else {
            applyButton.setTitle("Apply", for: .normal)
            applyButton.setTitleColor(UIColor.blue, for: .normal)
            applyButton.backgroundColor = UIColor.white
        }
    }
    
    override func incrementQuantity() {
        NIMBUS.OrderCreation?.incrementLoyaltyProgramPurchase(orderLoyaltyItem: cellOrderItem)
    }
    
    override func decrementQuantity() {
        NIMBUS.OrderCreation?.decrementLoyaltyProgramPurchase(orderLoyaltyItem: cellOrderItem)
    }
    
    override func deleteItem() {
        NIMBUS.OrderCreation?.removeLoyaltyProgramPurchase(orderLoyaltyItem: self.cellOrderItem)
    }
    
    override func initCell(cellOrderItem: orderItem){
        self.cellOrderItem = cellOrderItem
        setApplyButton()
    }
    
    override func fillOutItemDetails(){
        itemAddOnsStackView.subviews.forEach { $0.removeFromSuperview() }
        
        let itemDetailLabel = UILabel()
        itemDetailLabel.text = cellOrderItem.product?.name
        
        let itemPriceLabel = UILabel()
        itemPriceLabel.text = cellOrderItem.size!.price?.toString(asMoney: true, toDecimalPlaces: 2)
        
        let appendTopLevelItemDetail = UIStackView(arrangedSubviews: [itemDetailLabel, itemPriceLabel])
        appendTopLevelItemDetail.axis = .horizontal
        
        itemAddOnsStackView.addArrangedSubview(appendTopLevelItemDetail)
    }
}
