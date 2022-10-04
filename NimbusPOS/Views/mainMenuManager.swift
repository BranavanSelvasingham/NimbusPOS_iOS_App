//
//  mainMenu.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-17.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

protocol MainMenuManagerDelegate {
    func hideMenu()
    func showMenu()
}

class MainMenuManager: MainMenuManagerDelegate {
    var view : UIView
    var menuView: MainMenu?
    var menuBlurView: UIView?
    var menuWidth: CGFloat?
    var menuHeight: CGFloat?
    var minimizedMenuOrigin: CGPoint?
    var expandedMenuOrigin: CGPoint?
    
    init(frame: CGRect, view: UIView) {
        self.view = view
        menuBlurView = UIView(frame: frame)
        
        menuWidth = frame.width * 0.85
        menuHeight = menuWidth! / 1.618 //golden ratio
        
        minimizedMenuOrigin = CGPoint(x: 5, y: 5)
        expandedMenuOrigin = CGPoint(x: frame.width/2 - menuWidth!/2, y: frame.height/2 - menuHeight!/2)
        
        let expandedMenuFrame: CGRect = CGRect(origin: expandedMenuOrigin!, size: CGSize(width: menuWidth!, height: menuHeight!))
        let minimizedMenuFrame: CGRect = CGRect(origin: minimizedMenuOrigin!, size: CGSize(width: 10, height: 10))
    
        menuView = MainMenu(expandedFrame: expandedMenuFrame, minimizedFrame: minimizedMenuFrame)
        menuView?.menuManagerDelegate = self
        
        let tapExpandedGroupBlur = UITapGestureRecognizer(target: self, action: #selector(hideMenu))
        tapExpandedGroupBlur.numberOfTapsRequired = 1
        tapExpandedGroupBlur.cancelsTouchesInView = false
        menuBlurView?.addGestureRecognizer(tapExpandedGroupBlur)
        menuBlurView?.backgroundColor = UIColor.black //UIColor.white
        menuBlurView?.alpha = 0.7
        menuBlurView?.isHidden = true
        
        view.addSubview(menuBlurView!)
        view.addSubview(menuView!)
    }
    
    @objc func hideMenu(){
        menuView?.hideMenu()
        menuBlurView?.isHidden = true
    }
    
    func showMenu(){
        menuView?.showMenu()
        menuBlurView?.isHidden = false
    }
    
}
