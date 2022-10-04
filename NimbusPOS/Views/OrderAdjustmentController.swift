//
//  orderCheckoutadjustment.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-15.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

protocol OrderAdjustmentControllerDelegate {
    func setAdjustmentPercent(percent: Int)
}

class OrderAdjustmentController: UIViewController, OrderAdjustmentControllerDelegate {
    var adjustmentPercent: Int = 0 {
        didSet{
            adjustmentPercentLabel.text = "Adjustment: " + adjustmentPercent.toString() + "%"
            adjustmentSlider.value = Float(adjustmentPercent)
        }
    }
    
    var adjustmentPercentLabel: UILabel = {
        let adjustmentLabel = UILabel()
        adjustmentLabel.backgroundColor = UIColor.white
        adjustmentLabel.font = MDCTypography.titleFont()
        adjustmentLabel.textColor = UIColor.gray
        adjustmentLabel.textAlignment = .center
        adjustmentLabel.text = "Adjustment %"
        return adjustmentLabel
    }()
    
    var adjustmentSlider: UISlider = {
        let adjustmentSlider = UISlider()
        adjustmentSlider.minimumValue = 0
        adjustmentSlider.maximumValue = 100
        adjustmentSlider.value = 0
        adjustmentSlider.addTarget(self, action: #selector(adjustmentSliderMoved(_:)), for: .valueChanged)
        return adjustmentSlider
    }()
    
    var adjustmentIncrementDown: MDCRaisedButton = { () -> MDCRaisedButton in
        let button = MDCRaisedButton()
        button.backgroundColor = UIColor.white
        button.setTitle("- 5%", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(adjustmentIncrementDownClicked), for: .touchUpInside)
        return button
    }()
    
    var adjustmentIncrementUp: UIButton = { () -> MDCRaisedButton in
        let button = MDCRaisedButton()
        button.backgroundColor = UIColor.white
        button.setTitle("+ 5%", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleFont(MDCTypography.titleFont(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(adjustmentIncrementUpClicked), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NIMBUS.OrderCreation?.orderAdjustmentDelegate = self
        
        self.view.addSubview(adjustmentPercentLabel)
        self.view.addSubview(adjustmentSlider)
        self.view.addSubview(adjustmentIncrementUp)
        self.view.addSubview(adjustmentIncrementDown)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        adjustmentPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: adjustmentPercentLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: adjustmentPercentLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: adjustmentPercentLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: adjustmentPercentLabel, attribute: .bottom, relatedBy: .equal, toItem: adjustmentSlider, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: adjustmentPercentLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100).isActive = true
        
        adjustmentSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: adjustmentSlider, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: adjustmentSlider, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: adjustmentSlider, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70).isActive = true
        
        NSLayoutConstraint(item: adjustmentIncrementDown, attribute: .top, relatedBy: .equal, toItem: adjustmentSlider, attribute: .bottom, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: adjustmentIncrementDown, attribute: .leading, relatedBy: .equal, toItem: adjustmentSlider, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: adjustmentIncrementUp, attribute: .top, relatedBy: .equal, toItem: adjustmentSlider, attribute: .bottom, multiplier: 1, constant: 30).isActive = true
        NSLayoutConstraint(item: adjustmentIncrementUp, attribute: .trailing, relatedBy: .equal, toItem: adjustmentSlider, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
    }
    
    func adjustmentSliderMoved(_ sender: UISlider) {
        let newPercent = Int(sender.value)
        let oldPercent = NIMBUS.OrderCreation?.getAdjustmentPercent() ?? 0
        NIMBUS.OrderCreation?.changeAdjustmentPercent(percent: (newPercent - oldPercent))
    }
    
    func adjustmentIncrementDownClicked() {
        NIMBUS.OrderCreation?.changeAdjustmentPercent(percent: -5)
    }
    
    func adjustmentIncrementUpClicked() {
        NIMBUS.OrderCreation?.changeAdjustmentPercent(percent: 5)
    }
    
    func setAdjustmentPercent(percent: Int){
        self.adjustmentPercent = percent
    }
}
