//
//  OrderItemCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-09.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class OrderItemCell: UITableViewCell {
    var orderSummaryManagerDelegate: OrderSummaryManagerDelegate?
    
    var quantityView: UIView = UIView()
    var allItemsListView: UIViewWithShadow = UIViewWithShadow()
    var bottomBarView: UIView = UIView()
    
    var itemAddOnsStackView: UIStackView = UIStackView()
    
    var cellOrderItem: orderItem = orderItem() {
        didSet{
            incrementQuantityButton.setTitle( ("x" + String(describing: cellOrderItem.quantity)) , for: .normal)
            if cellOrderItem.quantity > 1 {
                decrementQuantityButton.isHidden = false
            } else {
                decrementQuantityButton.isHidden = true
            }
            fillOutItemDetails()
            checkIfItemIsRedeem()
        }
    }
    
    var incrementQuantityButton: UIButton = UIButton()
    var decrementQuantityButton: MDCButton = MDCButton()
    var optionsButton: MDCButton = MDCButton()
    var deleteItemButton: MDCButton = MDCButton()
    
    class priceModificationLines: UIStackView {
        let label = UILabel()
        let textField = MDCTextField()
        
        convenience init(labelText: String, textFieldPlaceholder: String) {
            self.init(frame: CGRect(x: 0, y: 0, width: 200, height: 70))
            
            label.text = labelText
            textField.placeholder = textFieldPlaceholder
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.axis = .horizontal
            self.distribution = .fillProportionally
            
            label.text = "Label:"
            
            textField.placeholder = "#"
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.widthAnchor.constraint(equalToConstant: 100).isActive = true
            textField.keyboardType = .decimalPad
            
            self.addArrangedSubview(label)
            self.addArrangedSubview(textField)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    let variablePriceView: priceModificationLines = priceModificationLines(labelText: "Variable price:", textFieldPlaceholder: "$#.##")
    let unitBasedPriceView: priceModificationLines = priceModificationLines(labelText: "Unit Quantity:", textFieldPlaceholder: "#.##")

//    let unitBasedPriceView: UIStackView = {
//        let view = UIStackView()
//        view.axis = .horizontal
//        view.distribution = .fillProportionally
//
//        let label = UILabel()
//        label.text = "Units Quantity(unit):"
//
//        let textField = MDCTextField()
//        textField.placeholder = "1 unit"
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        textField.addTarget(self, action: #selector(updateUnitBasedPriceQuantity), for: .valueChanged)
//
//        view.addArrangedSubview(label)
//        view.addArrangedSubview(textField)
//
//        return view
//    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        incrementQuantityButton.addTarget(self, action: #selector(incrementQuantity), for: .touchUpInside)
        decrementQuantityButton.addTarget(self, action: #selector(decrementQuantity), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(openOptions), for: .touchUpInside)
        deleteItemButton.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        
        variablePriceView.textField.addTarget(self, action: #selector(updateVariablePrice), for: .editingDidEnd)
        unitBasedPriceView.textField.addTarget(self, action: #selector(updateUnitBasedPriceQuantity), for: .editingDidEnd)
        
        incrementQuantityButton.backgroundColor = UIColor.white
        decrementQuantityButton.backgroundColor = UIColor.white
        optionsButton.backgroundColor = UIColor.white
        deleteItemButton.backgroundColor = UIColor.white
        
        incrementQuantityButton.setTitleColor(UIColor.gray, for: .normal)
        incrementQuantityButton.titleLabel?.font = MDCTypography.titleFont()
        decrementQuantityButton.setTitleColor(UIColor.gray, for: .normal)
        optionsButton.setTitleColor(UIColor.gray, for: .normal)
        deleteItemButton.setTitleColor(UIColor.gray, for: .normal)
        
        decrementQuantityButton.setTitle("-1", for: .normal)
        optionsButton.setTitle("Options", for: .normal)
        let deleteIcon = UIImage(named: "ic_delete")
        deleteItemButton.setImage(deleteIcon, for: .normal)
        deleteItemButton.contentMode = .scaleAspectFit
        
        itemAddOnsStackView.axis = .vertical
        itemAddOnsStackView.distribution = .equalSpacing
        itemAddOnsStackView.spacing = 0
        itemAddOnsStackView.alignment = .fill
        
        quantityView.addSubview(incrementQuantityButton)
        allItemsListView.addSubview(itemAddOnsStackView)
        bottomBarView.addSubview(decrementQuantityButton)
        bottomBarView.addSubview(optionsButton)
        bottomBarView.addSubview(deleteItemButton)
        
//        allItemsListView.setDefaultElevation()
        
        self.contentView.addSubview(quantityView)
        self.contentView.addSubview(allItemsListView)
        self.contentView.addSubview(bottomBarView)
        
        self.contentView.bringSubview(toFront: allItemsListView)
        
        sizeSubviews()
        constrainSubviews()
    }
    
    func sizeSubviews(){
        
    }
    
    func constrainSubviews(){
        let quantityViewWidth: CGFloat = 50
        let quantityIndicatorHeight: CGFloat = 30
        let decrementQuantityWidth: CGFloat = 50
        let optionsButtonWidth: CGFloat = 100
        let deleteButtonWidth: CGFloat = 60
        let bottomBarHeight: CGFloat = 50
        
        quantityView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: quantityView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: quantityView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: quantityView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: quantityViewWidth).isActive = true
        NSLayoutConstraint(item: quantityView, attribute: .bottom, relatedBy: .equal, toItem: bottomBarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        allItemsListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: allItemsListView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: allItemsListView, attribute: .leading, relatedBy: .equal, toItem: quantityView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: allItemsListView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: allItemsListView, attribute: .bottom, relatedBy: .equal, toItem: bottomBarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: bottomBarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bottomBarHeight).isActive = true
        NSLayoutConstraint(item: bottomBarView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBarView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: bottomBarView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        incrementQuantityButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: incrementQuantityButton, attribute: .height, relatedBy: .equal, toItem: quantityView, attribute: .height, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: incrementQuantityButton, attribute: .leading, relatedBy: .equal, toItem: quantityView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: incrementQuantityButton, attribute: .trailing, relatedBy: .equal, toItem: quantityView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: incrementQuantityButton, attribute: .centerY, relatedBy: .equal, toItem: quantityView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        itemAddOnsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .top, relatedBy: .equal, toItem: allItemsListView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .leading, relatedBy: .equal, toItem: allItemsListView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .trailing, relatedBy: .equal, toItem: allItemsListView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .bottom, relatedBy: .equal, toItem: allItemsListView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: itemAddOnsStackView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        
        decrementQuantityButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: decrementQuantityButton, attribute: .top, relatedBy: .equal, toItem: bottomBarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: decrementQuantityButton, attribute: .leading, relatedBy: .equal, toItem: bottomBarView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: decrementQuantityButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: decrementQuantityWidth).isActive = true
        NSLayoutConstraint(item: decrementQuantityButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBarView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: optionsButton, attribute: .top, relatedBy: .equal, toItem: bottomBarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsButton, attribute: .centerX, relatedBy: .equal, toItem: bottomBarView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: optionsButtonWidth).isActive = true
        NSLayoutConstraint(item: optionsButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBarView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        deleteItemButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: deleteItemButton, attribute: .top, relatedBy: .equal, toItem: bottomBarView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: deleteItemButton, attribute: .trailing, relatedBy: .equal, toItem: bottomBarView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: deleteItemButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: deleteButtonWidth).isActive = true
        NSLayoutConstraint(item: deleteItemButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBarView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCell(cellOrderItem: orderItem){
        self.cellOrderItem = cellOrderItem
    }
    
    func didSelectCell(){
        NIMBUS.OrderCreation?.selectedOrderItem = self.cellOrderItem
    }
    
    func incrementQuantity() {
        NIMBUS.OrderCreation?.incrementOrderItem(item: cellOrderItem)
    }
    
    func decrementQuantity() {
        NIMBUS.OrderCreation?.decrementOrderItem(item: cellOrderItem)
    }
    
    func openOptions() {
        didSelectCell()
        orderSummaryManagerDelegate?.showOptionsModal()
    }
    
    func deleteItem() {
        NIMBUS.OrderCreation?.removeOrderItem(item: cellOrderItem)
    }
    
    func updateVariablePrice(){
        let variablePrice: Float = Float(variablePriceView.textField.text ?? "") ?? 0
        NIMBUS.OrderCreation?.updateOrderItemVariablePrice(item: cellOrderItem, newVariablePrice: variablePrice)
    }
    
    func updateUnitBasedPriceQuantity(){
        let unitQuantity:Float = Float(unitBasedPriceView.textField.text ?? "") ?? 0
        NIMBUS.OrderCreation?.updateOrderItemUnitQuantity(item: cellOrderItem, newUnitQuantity: unitQuantity)
    }
    
    func fillOutItemDetails(){
        itemAddOnsStackView.subviews.forEach{$0.removeFromSuperview()}
        
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
        itemPriceLabel.setContentHuggingPriority(251, for: .horizontal)
        itemPriceLabel.text = cellOrderItem.size!.price?.toString(asMoney: true, toDecimalPlaces: 2)
        itemPriceLabel.textAlignment = .right
        
        let appendTopLevelItemDetail = UIStackView(arrangedSubviews: [itemDetailLabel, itemPriceLabel])
        appendTopLevelItemDetail.axis = .horizontal
        
        itemAddOnsStackView.addArrangedSubview(appendTopLevelItemDetail)
        
        checkAndAddVariablePriceLine()
        checkAndAddUnitBasedPriceLine()
        
        fillOutAddOnsAndSubstitutions()
        fillOutNotes()
        
        itemAddOnsStackView.sizeToFit()
    }
    
    func checkAndAddVariablePriceLine(){
        if cellOrderItem.variablePrice == true {
            if cellOrderItem.unitBasedPrice == true {
                variablePriceView.textField.text = cellOrderItem.unitPrice?.toString(asMoney: true, toDecimalPlaces: 2)
            } else {
                variablePriceView.textField.text = cellOrderItem.size?.price?.toString(asMoney: true, toDecimalPlaces: 2)
            }
            itemAddOnsStackView.addArrangedSubview(variablePriceView)
        }
    }
    
    func checkAndAddUnitBasedPriceLine(){
        if cellOrderItem.unitBasedPrice == true {
            let unitLabel = cellOrderItem.unitLabel ?? ""
            let unitPrice = (cellOrderItem.unitPrice ?? 0.00).toString(asMoney: true, toDecimalPlaces: 2)
            unitBasedPriceView.label.text = "Units (\(unitPrice)/\(unitLabel))  \(unitLabel)s:"
            unitBasedPriceView.textField.text = cellOrderItem.unitBasedPriceQuantity?.toString(asMoney: false, toDecimalPlaces: 3)
            itemAddOnsStackView.addArrangedSubview(unitBasedPriceView)
        }
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
    
    func checkIfItemIsRedeem(){
        if cellOrderItem.isRedeemItem ?? false {
            incrementQuantityButton.isEnabled = false
            //            incrementQuantityButton.isHidden = false
            
            decrementQuantityButton.isEnabled = false
            decrementQuantityButton.isHidden = true
            
            optionsButton.isEnabled = false
            optionsButton.isHidden = true
        }
    }
}
