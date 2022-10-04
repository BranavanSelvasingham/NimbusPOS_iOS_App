//
//  discountsOptions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-25.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

class DiscountOptionsView: UIViewController{
    var includeAddOnsLabel: UILabel = UILabel()
    var discountPercentLabel: UILabel = UILabel()
    var discountQuantityLabel: UILabel = UILabel()
    
    var discountQuantityField: UITextField = UITextField()
    var discountPercentField: UITextField = UITextField()
    var includeAddOnsSwitch: UISwitch = UISwitch()
    
    var addDiscountItemButton: UIButton = UIButton()
    
    var mainStackView: UIStackView = UIStackView()
    
    var block1: UIView = UIView()
    var block2: UIView = UIView()
    var block3: UIView = UIView()
    var block4: UIView = UIView()
    
    override func viewDidLoad() {
        
        includeAddOnsLabel.text = "Include Add-Ons (if any) in discount?"
        includeAddOnsLabel.font = MDCTypography.titleFont()
        includeAddOnsLabel.textAlignment = .right
        
        discountPercentLabel.text = "Discount %:"
        discountPercentLabel.font = MDCTypography.titleFont()
        discountPercentLabel.textAlignment = .right
        
        discountPercentField.keyboardType = .numberPad
        discountPercentField.layer.borderColor = UIColor.lightGray.cgColor
        discountPercentField.layer.borderWidth = 1
        discountPercentField.textAlignment = .center
        
        discountQuantityLabel.text = "Discount Quantity:"
        discountQuantityLabel.font = MDCTypography.titleFont()
        discountQuantityLabel.textAlignment = .right
        
        discountQuantityField.keyboardType = .numberPad
        discountQuantityField.layer.borderColor = UIColor.lightGray.cgColor
        discountQuantityField.layer.borderWidth = 1
        discountQuantityField.textAlignment = .center
        
        addDiscountItemButton.addTarget(self, action: #selector(addDiscountItem), for: .touchUpInside)
        addDiscountItemButton.setTitleColor(UIColor.white, for: .normal)
        addDiscountItemButton.setTitle("Add Discount Item", for: .normal)
        addDiscountItemButton.backgroundColor = UIColor.gray
        
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        
        self.view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(block1)
        mainStackView.addArrangedSubview(block2)
        mainStackView.addArrangedSubview(block3)
        mainStackView.addArrangedSubview(block4)
        
        self.block1.addSubview(includeAddOnsLabel)
        self.block1.addSubview(includeAddOnsSwitch)
        
        self.block2.addSubview(discountPercentLabel)
        self.block2.addSubview(discountPercentField)
        
        self.block3.addSubview(discountQuantityLabel)
        self.block3.addSubview(discountQuantityField)
        
        self.block4.addSubview(addDiscountItemButton)
    }
    
    override func viewWillLayoutSubviews() {
        let blockHeight: CGFloat = 50
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: mainStackView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mainStackView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: mainStackView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0).isActive = true
        
        block1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: block1, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true
        
        block2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: block2, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true
        
        block3.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: block3, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true
        
        block4.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: block4, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: blockHeight).isActive = true
    
        includeAddOnsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: includeAddOnsLabel, attribute: .top, relatedBy: .equal, toItem: block1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: includeAddOnsLabel, attribute: .leading, relatedBy: .equal, toItem: block1, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: includeAddOnsLabel, attribute: .trailing, relatedBy: .equal, toItem: includeAddOnsSwitch, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: includeAddOnsLabel, attribute: .bottom, relatedBy: .equal, toItem: block1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        includeAddOnsSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: includeAddOnsSwitch, attribute: .trailing, relatedBy: .equal, toItem: block1, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: includeAddOnsSwitch, attribute: .centerY, relatedBy: .equal, toItem: block1, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: includeAddOnsSwitch, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        
        discountPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: discountPercentLabel, attribute: .top, relatedBy: .equal, toItem: block2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountPercentLabel, attribute: .leading, relatedBy: .equal, toItem: block2, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountPercentLabel, attribute: .trailing, relatedBy: .equal, toItem: discountPercentField, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountPercentLabel, attribute: .bottom, relatedBy: .equal, toItem: block2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        discountPercentField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: discountPercentField, attribute: .top, relatedBy: .equal, toItem: block2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountPercentField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: discountPercentField, attribute: .trailing, relatedBy: .equal, toItem: block2, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountPercentField, attribute: .bottom, relatedBy: .equal, toItem: block2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        discountQuantityLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: discountQuantityLabel, attribute: .top, relatedBy: .equal, toItem: block3, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountQuantityLabel, attribute: .leading, relatedBy: .equal, toItem: block3, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountQuantityLabel, attribute: .trailing, relatedBy: .equal, toItem: discountQuantityField, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountQuantityLabel, attribute: .bottom, relatedBy: .equal, toItem: block3, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        discountQuantityField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: discountQuantityField, attribute: .top, relatedBy: .equal, toItem: block3, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountQuantityField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: discountQuantityField, attribute: .trailing, relatedBy: .equal, toItem: block3, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: discountQuantityField, attribute: .bottom, relatedBy: .equal, toItem: block3, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        addDiscountItemButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: addDiscountItemButton, attribute: .top, relatedBy: .equal, toItem: block4, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addDiscountItemButton, attribute: .leading, relatedBy: .equal, toItem: block4, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addDiscountItemButton, attribute: .trailing, relatedBy: .equal, toItem: block4, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: addDiscountItemButton, attribute: .bottom, relatedBy: .equal, toItem: block4, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
    }
    
    func addDiscountItem() {
        let includeAddOns: Bool = self.includeAddOnsSwitch.isOn
        let discountPercent: Float = Float(self.discountPercentField.text!) ?? 100
        let discountQuantity: Int = Int(self.discountQuantityField.text!) ?? 1
        
        NIMBUS.OrderCreation?.addDiscountItem(includeAddOns: includeAddOns, discountPercent: discountPercent, discountQuantity: discountQuantity)
    }
    
    func refreshDiscountOptions(){
        includeAddOnsSwitch.isOn = true
        discountPercentField.text = Int(100).toString()
        discountQuantityField.text = Int(1).toString()
    }
}


