//
//  SmartTextFieldNewInputView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-29.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class SmartTextFieldNewInputView: UIView {
    var textField: MDCTextField = MDCTextField()
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    override var frame: CGRect {
        didSet {
            resizeView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(textField)

        textField.clearButtonMode = .never
        
        textField.addTarget(self, action: #selector(textFieldInFocus), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldOutOfFocus), for: .editingDidEnd)
        
        resizeView()
    }
    
    func resizeView(){
        let viewWidth: CGFloat = self.frame.width
        let viewHeight: CGFloat = self.frame.height
        let buttonDim: CGFloat = 50
        let textFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewWidth - (2 * buttonDim), height: viewHeight))
        let button1Frame = CGRect(origin: CGPoint(x: textFrame.width, y: 0), size: CGSize(width: buttonDim, height: buttonDim))
        let button2Frame = CGRect(origin: CGPoint(x: textFrame.width + buttonDim, y: 0), size: CGSize(width: buttonDim, height: buttonDim))
        
        textField.frame = textFrame
    }
    
    func textFieldInFocus(){
        
    }
    
    func textFieldOutOfFocus(){
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
