//
//  SlideOverModalView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-22.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class SlideOverModalView: UIView {
    var parentFrame: CGRect = CGRect.zero
    var presentFrame: CGRect = CGRect.zero
    
    var blurView: UIView = UIView()
    var modalView: UIView = UIView()
    let headerView: UIViewWithShadow = UIViewWithShadow()
    let headerTitleLabel: UILabel = UILabel()
    let modalContentView: UIView = UIView()
    let leftButtonBar = MDCButtonBar()
    var leftButtonBarActionButtons = [UIBarButtonItem](){
        didSet {
            leftButtonBar.items = leftButtonBarActionButtons
            resizeLeftButtonBar()
        }
    }
    let rightButtonBar = MDCButtonBar()
    var rightButtonBarActionButtons = [UIBarButtonItem](){
        didSet {
            rightButtonBar.items = rightButtonBarActionButtons
            resizeRightButtonBar()
        }
    }
    
    var headerTitle: String {
        get {
            return headerTitleLabel.text ?? ""
        }
        set {
            headerTitleLabel.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.blurView.backgroundColor = UIColor.black
        self.blurView.alpha = 0.5
        self.addSubview(blurView)
        
        self.modalView.backgroundColor = UIColor.white
        
        headerView.shadowLayer.elevation = .switch
        
        headerTitleLabel.font = MDCTypography.titleFont()
        headerTitleLabel.textAlignment = .center
        
        headerView.addSubview(leftButtonBar)
        headerView.addSubview(rightButtonBar)
        
        headerView.addSubview(headerTitleLabel)
        headerView.sendSubview(toBack: headerTitleLabel)
        
        self.modalView.addSubview(headerView)
        
        self.modalView.addSubview(modalContentView)
        
        self.addSubview(modalView)
        self.bringSubview(toFront: modalView)
        
        self.isHidden = true
        
        resizeView(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setCustomPresentFrame(presentFrame: CGRect){
        self.modalView.frame = presentFrame
    }
    
    func setDefaultPresentFrame(frame: CGRect){
        presentFrame = CGRect(origin: CGPoint(x: frame.width*0.2, y: frame.height*0.1), size: CGSize(width: frame.width * 0.6 , height: frame.height * 0.6))
        self.modalView.frame = presentFrame
    }
    
    func resizeView(frame: CGRect, customPresentFrame: CGRect = .zero){
        self.frame = frame
        
        parentFrame = frame
        self.blurView.frame = frame
       
        if customPresentFrame == .zero {
            setDefaultPresentFrame(frame: frame)
        } else {
            setCustomPresentFrame(presentFrame: customPresentFrame)
        }
        
        headerView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.modalView.frame.width, height: 50))
        headerTitleLabel.frame = headerView.frame
        
        modalContentView.frame = CGRect(origin: CGPoint(x: 0, y: headerView.frame.height), size: CGSize(width: self.modalView.frame.width, height: self.modalView.frame.height - self.headerView.frame.height))
        
        resizeRightButtonBar()
        resizeLeftButtonBar()
    }
    
    func resizeRightButtonBar(){
        let sizeRight = rightButtonBar.sizeThatFits(self.frame.size)
        rightButtonBar.frame = CGRect(x: headerView.frame.width - sizeRight.width, y: 0, width: sizeRight.width, height: headerView.frame.height)
    }
    
    func resizeLeftButtonBar(){
        let sizeLeft = leftButtonBar.sizeThatFits(self.frame.size)
        leftButtonBar.frame = CGRect(x: 0, y: 0, width: sizeLeft.width, height: headerView.frame.height)
    }
    
    func presentModal(slideAnimation: Bool = true){
        self.isHidden = false
        if slideAnimation == true {
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn , animations: {
                self.modalView.transform = CGAffineTransform.identity
            })
            animator.addCompletion({ (position) in
                
            })
            animator.startAnimation()
        }
    }
    
    func dismissModal(slideAnimation: Bool = true){
        if slideAnimation == true {
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn , animations: {
                self.modalView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.parentFrame.height)
            })
            animator.addCompletion({ (position) in
                self.isHidden = true
            })
            animator.startAnimation()
        } else {
            self.isHidden = true
        }
    }
    
    func addViewToModal(view: UIView){
        view.frame = self.modalContentView.bounds
        view.clipsToBounds = true
        self.modalContentView.addSubview(view)
    }
    
}
