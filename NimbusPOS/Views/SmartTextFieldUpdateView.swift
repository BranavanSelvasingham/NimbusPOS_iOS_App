//
//  SmartTextFieldView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-26.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class SmartTextFieldUpdateView: UIView {
    var originalText: String?
    var textField: MDCTextField = MDCTextField()
    var saveButton: MDCButton = MDCButton()
    var undoButton: MDCButton = MDCButton()
    let buttonDim: CGFloat = 50
    
    override var frame: CGRect {
        didSet {
            resizeView()
        }
    }
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
            originalText = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        saveButton.setImage(UIImage(named: "ic_save"), for: .normal)
        undoButton.setImage(UIImage(named: "ic_undo"), for: .normal)
        
        saveButton.setBackgroundColor(UIColor.white)
        undoButton.setBackgroundColor(UIColor.white)
        
        saveButton.isHidden = true
        undoButton.isHidden = true
        
        self.addSubview(textField)
        self.addSubview(saveButton)
        self.addSubview(undoButton)
        
        textField.clearButtonMode = .never
        
        textField.addTarget(self, action: #selector(textFieldInFocus), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldOutOfFocus), for: .editingDidEnd)
        
        saveButton.addTarget(self, action: #selector(saveText), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(undoTextChanges), for: .touchUpInside)
        
        resizeView()
    }
    
    func resizeView(){
        let viewWidth: CGFloat = self.frame.width
        let viewHeight: CGFloat = self.frame.height
        let textFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewWidth - (2 * buttonDim), height: viewHeight))
        let button1Frame = CGRect(origin: CGPoint(x: textFrame.width, y: 0), size: CGSize(width: buttonDim, height: buttonDim))
        let button2Frame = CGRect(origin: CGPoint(x: textFrame.width + buttonDim, y: 0), size: CGSize(width: buttonDim, height: buttonDim))
        
        textField.frame = textFrame
        saveButton.frame = button1Frame
        undoButton.frame = button2Frame
    }
    
    func textFieldInFocus(){
        saveButton.isHidden = false
        undoButton.isHidden = false
    }
    
    func textFieldOutOfFocus(){
        saveButton.isHidden = true
        undoButton.isHidden = true
    }
    
    func saveText(){
        originalText = textField.text ?? ""
        stopEditing()
    }
    
    func undoTextChanges(){
        textField.text = originalText
        stopEditing()
    }
    
    func stopEditing(){
        textField.endEditing(true)
        textFieldOutOfFocus()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
