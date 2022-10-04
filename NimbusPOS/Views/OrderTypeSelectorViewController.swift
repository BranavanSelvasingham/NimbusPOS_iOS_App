//
//  OrderTypeSelectorViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit
import MaterialComponents

protocol OrderTypeSelectorDelegate {
    func setOrderInformation(info: orderInfoSchema)
    func backToMainSelector()
}

class OrderTypeSelectorViewController: UIViewController, OrderTypeSelectorDelegate {
    var orderViewManagerDelegate: OrderViewManagerDelegate?
    
    var orderTypeTilesStackView: UIStackView = UIStackView()
    
    var expressButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.backgroundColor = UIColor.gray
        customButton.setTitleColor(UIColor.white, for: .normal)
        customButton.setTitleFont(MDCTypography.titleFont(), for: .normal)
        customButton.setTitle("Express", for: .normal)
        customButton.addTarget(self, action: #selector(expressSelected), for: .touchUpInside)
        customButton.setBackgroundColor(UIColor().nimbusBlue, for: .selected)
        return customButton
    }()
    
    var dineInButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.backgroundColor = UIColor.gray
        customButton.setTitleColor(UIColor.white, for: .normal)
        customButton.setTitleFont(MDCTypography.titleFont(), for: .normal)
        customButton.setTitle("Dine-In", for: .normal)
        customButton.addTarget(self, action: #selector(dineInSelected), for: .touchUpInside)
        customButton.setBackgroundColor(UIColor().nimbusBlue, for: .selected)
        return customButton
    }()
    
    var takeOutButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.backgroundColor = UIColor.gray
        customButton.setTitleColor(UIColor.white, for: .normal)
        customButton.setTitleFont(MDCTypography.titleFont(), for: .normal)
        customButton.setTitle("Take-Out", for: .normal)
        customButton.addTarget(self, action: #selector(openTakeOutForm), for: .touchUpInside)
        customButton.setBackgroundColor(UIColor().nimbusBlue, for: .selected)
        return customButton
    }()
    var deliveryButton: MDCRaisedButton = {
        let customButton = MDCRaisedButton()
        customButton.backgroundColor = UIColor.gray
        customButton.setTitleColor(UIColor.white, for: .normal)
        customButton.setTitleFont(MDCTypography.titleFont(), for: .normal)
        customButton.setTitle("Delivery", for: .normal)
        customButton.addTarget(self, action: #selector(openDeliveryForm), for: .touchUpInside)
        customButton.setBackgroundColor(UIColor().nimbusBlue, for: .selected)
        return customButton
    }()
    
    var takeOutFormView: UIView = UIView()
    var takeOutFormVC: TakeOutInformationViewController = TakeOutInformationViewController()
    
    var deliveryFormView: UIView = UIView()
    var deliveryFormVC: DeliveryInformationViewController = DeliveryInformationViewController()  //UIStoryboard(name: "OrderTypeInformation", bundle: Bundle.main).instantiateViewController(withIdentifier: "DeliveryInformationViewController") as! DeliveryInformationViewController
    
    var orderInformation: orderInfoSchema? {
        didSet {
            NIMBUS.OrderCreation?.orderInformation = orderInformation!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        orderTypeTilesStackView.axis = .horizontal
        orderTypeTilesStackView.alignment = .center
        orderTypeTilesStackView.distribution = .equalSpacing
        
        orderTypeTilesStackView.addArrangedSubview(expressButton)
        orderTypeTilesStackView.addArrangedSubview(dineInButton)
        orderTypeTilesStackView.addArrangedSubview(takeOutButton)
        orderTypeTilesStackView.addArrangedSubview(deliveryButton)
        self.view.addSubview(orderTypeTilesStackView)
        
        self.view.addSubview(takeOutFormView)
        self.view.addSubview(deliveryFormView)
        
        loadTakeOutForm()
        loadDeliveryForm()
    }
    
    override func viewWillLayoutSubviews() {
        orderTypeTilesStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: orderTypeTilesStackView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTypeTilesStackView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: orderTypeTilesStackView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .width, multiplier: 0.8, constant: 0).isActive = true
        
        let tiles = [expressButton, dineInButton, takeOutButton, deliveryButton]
        tiles.forEach { tile in
            tile.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: tile, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150).isActive = true
            NSLayoutConstraint(item: tile, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150).isActive = true
        }
        
        let forms = [takeOutFormView, deliveryFormView]
        forms.forEach { form in
            form.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: form, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1, constant: 5).isActive = true
            NSLayoutConstraint(item: form, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0).isActive = true
        }
        
        takeOutFormVC.view.frame = takeOutFormView.bounds
        deliveryFormVC.view.frame = deliveryFormView.bounds
        
        self.view.bringSubview(toFront: takeOutFormView)
        self.view.bringSubview(toFront: deliveryFormView)
    }
    
    func loadTakeOutForm(){
        self.addChildViewController(takeOutFormVC)
        takeOutFormVC.orderTypeSelectorDelegate = self
        takeOutFormView.addSubview(takeOutFormVC.view)
        takeOutFormVC.didMove(toParentViewController: self)
        takeOutFormView.isHidden = true
    }
    
    func loadDeliveryForm(){
        self.addChildViewController(deliveryFormVC)
        deliveryFormVC.orderTypeSelectorDelegate = self
        deliveryFormView.addSubview(deliveryFormVC.view)
        deliveryFormVC.didMove(toParentViewController: self)
        deliveryFormView.isHidden = true
    }

    func expressSelected() {
        var info = orderInfoSchema()
        info.orderType = _OrderTypes.Express.rawValue
        setOrderInformation(info: info)
    }
    
    func dineInSelected() {
        var info = orderInfoSchema()
        info.orderType = _OrderTypes.DineIn.rawValue
        setOrderInformation(info: info)
    }
    
    func openTakeOutForm(){
        takeOutFormView.isHidden = false
    }
    
    func openDeliveryForm(){
        deliveryFormView.isHidden = false
    }
    
    func setOrderInformation(info: orderInfoSchema){
        self.orderInformation = info
        orderViewManagerDelegate?.dismissOrderTypeModal()
    }
    
    func backToMainSelector() {
        takeOutFormView.isHidden = true
        deliveryFormView.isHidden = true
    }
    
    func fillInExistingOrderTypeDetails(){
        if let orderInfo = NIMBUS.OrderCreation?.orderInformation {
            expressButton.isSelected = false
            dineInButton.isSelected = false
            deliveryButton.isSelected = false
            takeOutButton.isSelected = false
            
            if orderInfo.orderType == _OrderTypes.Express.rawValue {
                expressButton.isSelected = true
            } else if orderInfo.orderType == _OrderTypes.DineIn.rawValue {
                dineInButton.isSelected = true
            } else if orderInfo.orderType == _OrderTypes.TakeOut.rawValue {
                takeOutButton.isSelected = true
                openTakeOutForm()
            } else if orderInfo.orderType == _OrderTypes.Delivery.rawValue {
                deliveryButton.isSelected = true
                openDeliveryForm()
            }
            
            deliveryFormVC.fillInAnyEnteredOrderTypeInformation()
            takeOutFormVC.fillInAnyEnteredOrderTypeInformation()
        }
    }
}
