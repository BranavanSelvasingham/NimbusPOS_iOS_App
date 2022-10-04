//
//  keypadController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-15.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class CashKeypadController: UIViewController{
    let keypadStackView: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .equalCentering
        verticalStack.alignment = .fill
        return verticalStack
    }()
    
    let digitRowStackView789: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .horizontal
        verticalStack.distribution = .equalCentering
        verticalStack.alignment = .fill
        return verticalStack
    }()
    
    let digitRowStackView456: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .horizontal
        verticalStack.distribution = .equalCentering
        verticalStack.alignment = .fill
        return verticalStack
    }()
    
    let digitRowStackView123: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .horizontal
        verticalStack.distribution = .equalCentering
        verticalStack.alignment = .fill
        return verticalStack
    }()
    
    let digitRowStackView0: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .horizontal
        verticalStack.distribution = .equalCentering
        verticalStack.alignment = .center
        return verticalStack
    }()
    
    let digit0: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 0
        digit.setTitle("0", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit1: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 1
        digit.setTitle("1", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit2: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 2
        digit.setTitle("2", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit3: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 3
        digit.setTitle("3", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit4: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 4
        digit.setTitle("4", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit5: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 5
        digit.setTitle("5", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit6: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 6
        digit.setTitle("6", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit7: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 7
        digit.setTitle("7", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit8: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 8
        digit.setTitle("8", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let digit9: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.widthAnchor.constraint(equalToConstant: 50)
        digit.heightAnchor.constraint(equalToConstant: 50)
        digit.tag = 9
        digit.setTitle("9", for: .normal)
        digit.setTitleFont(MDCTypography.titleFont(), for: .normal)
        digit.addTarget(self, action: #selector(addToCashGivenDigit(_:)), for: .touchUpInside)
        return digit
    }()
    
    let cash5: MDCRaisedButton = { () -> MDCRaisedButton in
        let digit = MDCRaisedButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.tag = 5
//        digit.setTitle("$ 5.00", for: .normal)
        digit.setBackgroundImage(UIImage(named: "CAD5Bill"), for: .normal)
        digit.contentMode = .scaleAspectFit
        digit.addTarget(self, action: #selector(addToCashAmountGiven(_:)), for: .touchUpInside)
        return digit
    }()
    
    let cash10: MDCRaisedButton = { () -> MDCRaisedButton in
        let digit = MDCRaisedButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.tag = 10
//        digit.setTitle("$ 10.00", for: .normal)
        digit.setBackgroundImage(UIImage(named: "CAD10Bill"), for: .normal)
        digit.contentMode = .scaleAspectFit
        digit.addTarget(self, action: #selector(addToCashAmountGiven(_:)), for: .touchUpInside)
        return digit
    }()
    
    let cash20: MDCRaisedButton = { () -> MDCRaisedButton in
        let digit = MDCRaisedButton()
        digit.backgroundColor = UIColor.white
        digit.setTitleColor(UIColor.gray, for: .normal)
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.tag = 20
//        digit.setTitle("$ 20.00", for: .normal)
        digit.setBackgroundImage(UIImage(named: "CAD20Bill"), for: .normal)
        digit.contentMode = .scaleAspectFit
        digit.addTarget(self, action: #selector(addToCashAmountGiven(_:)), for: .touchUpInside)
        return digit
    }()
    
    let cashNotesStackView: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .equalCentering
        verticalStack.alignment = .fill
        return verticalStack
    }()
    
    let cashNotesView: UIView = UIView()
    
    let keyPadView: UIView = UIView()
    
    let amountEnteredView: UIView = UIView()
    
    let amountEnteredLabel: UILabel = {
        let amountLabel = UILabel()
        amountLabel.font = MDCTypography.titleFont()
        amountLabel.textColor = UIColor.gray
        amountLabel.textAlignment = .right
        amountLabel.text = "Cash Given: $ 0.00"
        return amountLabel
    }()
    
    let resetAmountButton: MDCFloatingButton = { () -> MDCFloatingButton in
        let digit = MDCFloatingButton()
        digit.backgroundColor = UIColor.white
        digit.translatesAutoresizingMaskIntoConstraints = false
        digit.setImage(UIImage(named: "ic_refresh"), for: .normal)
        digit.addTarget(self, action: #selector(resetCashGiven), for: .touchUpInside)
        return digit
    }()
    
    override func viewDidLoad() {
        loadDigits()
        loadCashNotes()
        loadAmountView()
    }
    
    override func viewWillLayoutSubviews() {
        amountEnteredView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: amountEnteredView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: amountEnteredView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: amountEnteredView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        cashNotesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cashNotesView, attribute: .top, relatedBy: .equal, toItem: amountEnteredView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cashNotesView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: cashNotesView, attribute: .trailing, relatedBy: .equal, toItem: keyPadView, attribute: .leading, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: cashNotesView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        keyPadView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: keyPadView, attribute: .top, relatedBy: .equal, toItem: amountEnteredView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keyPadView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: keyPadView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: keyPadView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250).isActive = true
        NSLayoutConstraint(item: keyPadView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 210).isActive = true
        
        layoutCashNotes()
        layoutDigits()
        layoutAmountView()
    }
    
    func loadDigits(){
        digitRowStackView789.addArrangedSubview(digit7)
        digitRowStackView789.addArrangedSubview(digit8)
        digitRowStackView789.addArrangedSubview(digit9)
        
        digitRowStackView456.addArrangedSubview(digit4)
        digitRowStackView456.addArrangedSubview(digit5)
        digitRowStackView456.addArrangedSubview(digit6)
        
        digitRowStackView123.addArrangedSubview(digit3)
        digitRowStackView123.addArrangedSubview(digit2)
        digitRowStackView123.addArrangedSubview(digit1)
        
        digitRowStackView0.addArrangedSubview(digit0)
        
        keypadStackView.addArrangedSubview(digitRowStackView789)
        keypadStackView.addArrangedSubview(digitRowStackView456)
        keypadStackView.addArrangedSubview(digitRowStackView123)
        keypadStackView.addArrangedSubview(digitRowStackView0)
        
        keyPadView.addSubview(keypadStackView)
        self.view.addSubview(keyPadView)
    }
    
    func loadAmountView(){
        amountEnteredView.addSubview(amountEnteredLabel)
        amountEnteredView.addSubview(resetAmountButton)
        self.view.addSubview(amountEnteredView)
    }
    
    func loadCashNotes(){
        cashNotesView.addSubview(cash20)
        cashNotesView.addSubview(cash10)
        cashNotesView.addSubview(cash5)
        self.view.addSubview(cashNotesView)
    }
    
    func layoutAmountView(){
        resetAmountButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: resetAmountButton, attribute: .centerY, relatedBy: .equal, toItem: amountEnteredView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: resetAmountButton, attribute: .trailing, relatedBy: .equal, toItem: amountEnteredView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: resetAmountButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: resetAmountButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true

        amountEnteredLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: amountEnteredLabel, attribute: .top, relatedBy: .equal, toItem: amountEnteredView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: amountEnteredLabel, attribute: .leading, relatedBy: .equal, toItem: amountEnteredView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: amountEnteredLabel, attribute: .trailing, relatedBy: .equal, toItem: resetAmountButton, attribute: .leading, multiplier: 1, constant: -25).isActive = true
        NSLayoutConstraint(item: amountEnteredLabel, attribute: .bottom, relatedBy: .equal, toItem: amountEnteredView , attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func layoutDigits(){
        keypadStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: keypadStackView, attribute: .top, relatedBy: .equal, toItem: keyPadView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keypadStackView, attribute: .leading, relatedBy: .equal, toItem: keyPadView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keypadStackView, attribute: .trailing, relatedBy: .equal, toItem: keyPadView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: keypadStackView, attribute: .bottom, relatedBy: .equal, toItem: keyPadView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func layoutCashNotes(){
        cash20.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cash20, attribute: .top, relatedBy: .equal, toItem: cashNotesView, attribute: .top, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: cash20, attribute: .leading, relatedBy: .equal, toItem: cashNotesView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cash20, attribute: .trailing, relatedBy: .equal, toItem: cashNotesView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cash20, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70).isActive = true
        
        cash10.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cash10, attribute: .top, relatedBy: .equal, toItem: cash20, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: cash10, attribute: .leading, relatedBy: .equal, toItem: cashNotesView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cash10, attribute: .trailing, relatedBy: .equal, toItem: cashNotesView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cash10, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70).isActive = true
        
        cash5.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: cash5, attribute: .top, relatedBy: .equal, toItem: cash10, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: cash5, attribute: .leading, relatedBy: .equal, toItem: cashNotesView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cash5, attribute: .trailing, relatedBy: .equal, toItem: cashNotesView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cash5, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 70).isActive = true
    }
    
    func addToCashGivenDigit(_ sender: UIButton) {
        let cashGiven = NIMBUS.OrderCreation?.orderPayment.cashGiven!
        let digitSelected = String(sender.tag)
        let updatedDigits = String(Int(cashGiven!*100)) + digitSelected
        let updatedAmount = (Float(updatedDigits) ?? 0 )/100
        NIMBUS.OrderCreation?.updateCashGiven(given:  updatedAmount.rounded(toPlaces: 2))
        self.amountEnteredLabel.text = "Cash Given: " + updatedAmount.toString(asMoney: true, toDecimalPlaces: 2)
    }

    func addToCashAmountGiven(_ sender: UIButton) {
        let amountSelected = Float(sender.tag)
        let cashGiven = (NIMBUS.OrderCreation?.orderPayment.cashGiven)! + amountSelected
        NIMBUS.OrderCreation?.updateCashGiven(given: cashGiven)
        self.amountEnteredLabel.text = "Cash Given: " + cashGiven.toString(asMoney: true, toDecimalPlaces: 2)
    }
    
    func resetCashGiven() {
        NIMBUS.OrderCreation?.updateCashGiven(given: 0.00)
        self.amountEnteredLabel.text = "Cash Given: $ 0.00"
    }

    
}
