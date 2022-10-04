//
//  OrderPopUpModalView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-07.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class OrderPopUpModalView: UIView {
    var parentFrame: CGRect = CGRect.zero
    var presentFrame: CGRect = CGRect.zero
    
    var blurView: UIView = UIView()
    var modalView: UIView = UIView()
    var modalContentView: UIView = UIView()

    let headerTitleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.blurView.backgroundColor = UIColor.black
        self.blurView.alpha = 0.5
        self.addSubview(blurView)
        
        self.modalView.backgroundColor = UIColor.white
        
        headerTitleLabel.font = MDCTypography.titleFont()
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.textColor = UIColor.white
        
        self.addSubview(modalView)
        self.bringSubview(toFront: modalView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        self.blurView.addGestureRecognizer(tap)
        
        self.isHidden = true
        
        self.modalView.addSubview(modalContentView)
        self.modalView.addSubview(headerTitleLabel)
        
        resizeView(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func resizeView(frame: CGRect){
        self.frame = frame
        parentFrame = frame
        self.blurView.frame = frame
    }
    
    func presentModal(contentView: UIView, contentFrame: CGRect, modalColor: UIColor, headerTitle: String){
        var containerFrame = contentFrame.offsetBy(dx: -10, dy: -30)
        containerFrame.size.width += 10 + 10
        containerFrame.size.height += 30 + 10
        self.modalView.frame = containerFrame
        
        self.modalContentView.frame.size = contentFrame.size
        self.modalContentView.frame.origin = CGPoint(x: 10, y: 30)
        
        contentView.frame = self.modalContentView.bounds
        
        var labelFrame = containerFrame
        labelFrame.size.height = 30
        self.headerTitleLabel.frame.size = labelFrame.size
        self.headerTitleLabel.frame.origin = .zero
        
        self.modalView.backgroundColor = modalColor
        self.headerTitleLabel.text = headerTitle
        
        self.isHidden = false
        
//        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn , animations: {
//            self.modalView.transform = CGAffineTransform.identity
//        })
//        animator.addCompletion({ (position) in
//
//        })
//        animator.startAnimation()
    }
    
    func dismissModal(){
//        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn , animations: {
//            self.modalView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.parentFrame.height)
//        })
//        animator.addCompletion({ (position) in
            self.isHidden = true
//        })
//        animator.startAnimation()
    }
    
    func addViewToModal(view: UIView){
        view.frame = self.modalContentView.bounds
        self.modalContentView.addSubview(view)
    }
}
