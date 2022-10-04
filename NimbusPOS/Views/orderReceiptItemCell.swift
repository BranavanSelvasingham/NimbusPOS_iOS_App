//
//  orderReceiptItemCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-12.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class OrderReceiptItemCell: UITableViewCell {
    var quantityView: UIView = UIView()
    var allItemsListView: UIViewWithShadow = UIViewWithShadow()
    var itemAddOnsStackView: UIStackView = UIStackView()
    
    var cellOrderItem: orderItem = orderItem() {
        didSet{
            quantityLabel.text = "x" + String(describing: cellOrderItem.quantity)
            fillOutItemDetails()
        }
    }
    
    var quantityLabel: UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        quantityLabel.font = MDCTypography.titleFont()
        
        itemAddOnsStackView.axis = .vertical
        itemAddOnsStackView.distribution = .equalSpacing
        itemAddOnsStackView.spacing = 0
        itemAddOnsStackView.alignment = .fill
        
        quantityView.addSubview(quantityLabel)
        allItemsListView.addSubview(itemAddOnsStackView)
        
        self.contentView.addSubview(quantityView)
        self.contentView.addSubview(allItemsListView)
        
        self.contentView.bringSubview(toFront: allItemsListView)

        constrainSubviews()
    }
    
    func constrainSubviews(){
        let quantityViewWidth: CGFloat = 50
        let quantityIndicatorHeight: CGFloat = 30
        
        quantityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: quantityView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: quantityView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: quantityView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: quantityViewWidth).isActive = true
        NSLayoutConstraint(item: quantityView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        allItemsListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: allItemsListView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: allItemsListView, attribute: .leading, relatedBy: .equal, toItem: quantityView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: allItemsListView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: allItemsListView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: quantityLabel, attribute: .height, relatedBy: .equal, toItem: quantityView, attribute: .height, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: quantityLabel, attribute: .leading, relatedBy: .equal, toItem: quantityView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: quantityLabel, attribute: .trailing, relatedBy: .equal, toItem: quantityView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: quantityLabel, attribute: .centerY, relatedBy: .equal, toItem: quantityView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        itemAddOnsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .top, relatedBy: .equal, toItem: allItemsListView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .leading, relatedBy: .equal, toItem: allItemsListView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .trailing, relatedBy: .equal, toItem: allItemsListView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .bottom, relatedBy: .equal, toItem: allItemsListView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(cellOrderItem: orderItem){
        self.cellOrderItem = cellOrderItem
    }
    
    func fillOutItemDetails(){
        itemAddOnsStackView.subviews.forEach { $0.removeFromSuperview() }
        
        let itemDetailLabel = UILabel()
        itemDetailLabel.numberOfLines = 2
        itemDetailLabel.lineBreakMode = .byWordWrapping
        itemDetailLabel.setContentHuggingPriority(249, for: .horizontal)
        
        if (cellOrderItem.product?.sizes?.count ?? 0) > 1 {
            itemDetailLabel.text = (cellOrderItem.size?.label ?? "?") + " - " + (cellOrderItem.product?.name ?? "?")
        } else {
            itemDetailLabel.text = cellOrderItem.product?.name
        }
        
        let itemPriceLabel = UILabel()
        itemPriceLabel.text = cellOrderItem.size!.price?.toString(asMoney: true, toDecimalPlaces: 2)
        itemPriceLabel.textAlignment = .right
        itemPriceLabel.setContentHuggingPriority(251, for: .horizontal)
        
        let appendTopLevelItemDetail = UIStackView(arrangedSubviews: [itemDetailLabel, itemPriceLabel])
        appendTopLevelItemDetail.axis = .horizontal
        //        appendTopLevelItemDetail.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        itemAddOnsStackView.addArrangedSubview(appendTopLevelItemDetail)
        
        fillOutAddOnsAndSubstitutions()
        fillOutNotes()
        
        itemAddOnsStackView.sizeToFit()
    }
    
    func fillOutAddOnsAndSubstitutions() {
        cellOrderItem.addOns?.forEach{addOn in
            let itemDetailsHorizontalStackView = UIStackView()
            itemDetailsHorizontalStackView.axis = .horizontal
            itemDetailsHorizontalStackView.distribution = .fillProportionally
            itemDetailsHorizontalStackView.spacing = 50
            
            let itemDetailLabel = ItemDetails_UILabelSubclass()
            itemDetailLabel.text = addOn.name
            
            let itemPriceLabel = UILabel()
            itemPriceLabel.text = addOn.price?.toString(asMoney: true, toDecimalPlaces: 2)
            
            let appendItemDetail = UIStackView(arrangedSubviews: [itemDetailLabel, itemPriceLabel])
            appendItemDetail.axis = .horizontal
            
            itemAddOnsStackView.addArrangedSubview(appendItemDetail)
        }
    }
    
    func fillOutNotes() {
        cellOrderItem.notes?.forEach{note in
            let itemNoteLabel = ItemDetails_UILabelSubclass()
            itemNoteLabel.text = "*" + note
            
            let appendItemDetail = UIStackView(arrangedSubviews: [itemNoteLabel])
            
            appendItemDetail.axis = .horizontal
            
            itemAddOnsStackView.addArrangedSubview(appendItemDetail)
        }
    }
    
//    var item = orderItem(){
//        didSet {
//            itemQuantityLabel.text = "x" + String(item.quantity)
//            fillOutItemDetails()
//        }
//    }
//
//    @IBOutlet weak var itemQuantityLabel: UILabel!
//    @IBOutlet weak var itemAddOnsStackView: UIStackView!
//
//
//    func initCell(item: orderItem) {
//        self.item = item
//    }
//
//    func fillOutItemDetails(){
//        itemAddOnsStackView.subviews.forEach { $0.removeFromSuperview() }
//
//        let itemDetailLabel = UILabel()
//        itemDetailLabel.text = item.product?.name
//
//        let itemPriceLabel = UILabel()
//        itemPriceLabel.text = item.size!.price?.toString(asMoney: true, toDecimalPlaces: 2)
//
//        let appendTopLevelItemDetail = UIStackView(arrangedSubviews: [itemDetailLabel, itemPriceLabel])
//        appendTopLevelItemDetail.axis = .horizontal
//        //        appendTopLevelItemDetail.heightAnchor.constraint(equalToConstant: 100).isActive = true
//
//        itemAddOnsStackView.addArrangedSubview(appendTopLevelItemDetail)
//
//        fillOutAddOnsAndSubstitutions()
//        fillOutNotes()
//    }
//
//    func fillOutAddOnsAndSubstitutions() {
//        item.addOns?.forEach{addOn in
//            let itemDetailsHorizontalStackView = UIStackView()
//            itemDetailsHorizontalStackView.axis = .horizontal
//            itemDetailsHorizontalStackView.distribution = .fillProportionally
//            itemDetailsHorizontalStackView.spacing = 50
//
//            let itemDetailLabel = ItemDetails_UILabelSubclass()
//            itemDetailLabel.text = addOn.name
//
//            let itemPriceLabel = UILabel()
//            itemPriceLabel.text = addOn.price?.toString(asMoney: true, toDecimalPlaces: 2)
//
//            let appendItemDetail = UIStackView(arrangedSubviews: [itemDetailLabel, itemPriceLabel])
//            appendItemDetail.axis = .horizontal
//
//            itemAddOnsStackView.addArrangedSubview(appendItemDetail)
//        }
//    }
//
//    func fillOutNotes() {
//        item.notes?.forEach{note in
//            let itemNoteLabel = ItemDetails_UILabelSubclass()
//            itemNoteLabel.text = note
//
//            let appendItemDetail = UIStackView(arrangedSubviews: [itemNoteLabel])
//
//            appendItemDetail.axis = .horizontal
//
//            itemAddOnsStackView.addArrangedSubview(appendItemDetail)
//        }
//    }
}

