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

class MainMenu: UIView {
    var expandedFrame: CGRect?
    var minimizedFrame: CGRect?
    var menuTilesView: UIView?
    var menuManagerDelegate: MainMenuManagerDelegate?
    
    init(expandedFrame: CGRect, minimizedFrame: CGRect) {
        super.init(frame: expandedFrame)
        
        self.expandedFrame = expandedFrame
        self.minimizedFrame = minimizedFrame
        self.backgroundColor = UIColor.gray
        self.isHidden = true
        self.setDefaultElevation()

        self.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        
        initializeMenuTiles()
    }
    
    func initializeMenuTiles(){
        let tileWidth: CGFloat = 200
        let tileHeight: CGFloat = 200
        let tileSize: CGSize = CGSize(width: tileWidth, height: tileHeight)
        let tileSpacing: CGFloat = (self.expandedFrame!.width - (4 * tileWidth))/5
        let headerHeight: CGFloat = (self.expandedFrame?.height)! - (2 * tileHeight) - (3 * tileSpacing) - 30
        let firstRow: CGFloat = headerHeight + tileSpacing
        let secondRow: CGFloat = headerHeight + tileSpacing + tileHeight + tileSpacing
        
        //Header Info
        let businessDisplayViewFrame: CGRect = CGRect(origin: CGPoint(x: 5, y: 20), size: CGSize(width: 190, height: 30))
        let businessDisplayView =  BusinessNameTile(frame: businessDisplayViewFrame, blockSize: .medium)
        self.addSubview(businessDisplayView)
        
        businessDisplayView.translatesAutoresizingMaskIntoConstraints = false
        businessDisplayView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        NSLayoutConstraint(item: businessDisplayView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: tileSpacing).isActive = true
        NSLayoutConstraint(item: businessDisplayView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: tileSpacing).isActive = true
        
        let locationDisplayViewFrame: CGRect = CGRect(origin: CGPoint(x: (self.expandedFrame?.width)! - 200 - 5, y: 20), size: CGSize(width: 190, height: 30))
        let locationDisplayView =  LocationNameTile(frame: locationDisplayViewFrame, blockSize: .medium)
        self.addSubview(locationDisplayView)
        
        locationDisplayView.translatesAutoresizingMaskIntoConstraints = false
        locationDisplayView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        NSLayoutConstraint(item: locationDisplayView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -tileSpacing).isActive = true
        NSLayoutConstraint(item: locationDisplayView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: tileSpacing).isActive = true

        //Header Toolbar Tiles
        let toolbarTileWidth: CGFloat = 200
        let toolbarTileHeight: CGFloat = 40
        let toolbarTileSize: CGSize = CGSize(width: toolbarTileWidth, height: toolbarTileHeight)
        let numberOfToolbarTilesPerRow: CGFloat = 5
        let toolbarTileSpacing: CGFloat = (self.expandedFrame!.width - (numberOfToolbarTilesPerRow * toolbarTileWidth))/(numberOfToolbarTilesPerRow + 1)
        
        //Main Menu Tiles
        let ordersTile = MainMenuTile(title: "Orders", iconName: "ic_add_shopping_cart_white_48pt", tileSize: tileSize)
        ordersTile.frame.origin = CGPoint(x: tileSpacing, y: firstRow)
        ordersTile.addTarget(self, action: #selector(goToOrders), for: .touchUpInside)
        self.addSubview(ordersTile)
        
        let openOrdersTile = MainMenuTile(title: "Open Orders", iconName: "ic_content_paste_white_48pt", tileSize: tileSize)
        openOrdersTile.frame.origin = CGPoint(x: tileSpacing + (tileWidth + tileSpacing) * 1, y: firstRow)
        openOrdersTile.addTarget(self, action: #selector(goToOpenOrders), for: .touchUpInside)
        self.addSubview(openOrdersTile)
        
        let orderHistoryTile = MainMenuTile(title: "Order History", iconName: "ic_history_white_48pt", tileSize: tileSize)
        orderHistoryTile.frame.origin = CGPoint(x: tileSpacing + (tileWidth + tileSpacing) * 2, y: firstRow)
        orderHistoryTile.addTarget(self, action: #selector(goToOrderHistory), for: .touchUpInside)
        self.addSubview(orderHistoryTile)

        let dailyReportTile = MainMenuTile(title: "Daily Reports", iconName: "ic_description_white_48pt", tileSize: tileSize)
        dailyReportTile.frame.origin = CGPoint(x: tileSpacing + (tileWidth + tileSpacing) * 3, y: firstRow)
        dailyReportTile.addTarget(self, action: #selector(goToDailyReports), for: .touchUpInside)
        self.addSubview(dailyReportTile)
        
        let customersTile = MainMenuTile(title: "Customers", iconName: "ic_people_outline_white_48pt", tileSize: tileSize)
        customersTile.frame.origin = CGPoint(x: tileSpacing, y: secondRow)
        customersTile.addTarget(self, action: #selector(goToCustomers), for: .touchUpInside)
        self.addSubview(customersTile)
        
        let employeesTile = MainMenuTile(title: "Employees", iconName: "ic_people_white_48pt", tileSize: tileSize)
        employeesTile.frame.origin = CGPoint(x: tileSpacing + (tileWidth + tileSpacing) * 1, y: secondRow)
        employeesTile.addTarget(self, action: #selector(goToEmployees), for: .touchUpInside)
        self.addSubview(employeesTile)
        
        let notesTile = MainMenuTile(title: "Notes", iconName: "ic_library_books_white_48pt", tileSize: tileSize)
        notesTile.frame.origin = CGPoint(x: tileSpacing + (tileWidth + tileSpacing) * 2, y: secondRow)
        notesTile.addTarget(self, action: #selector(goToNotes), for: .touchUpInside)
        self.addSubview(notesTile)

        let settingTile = MainMenuTile(title: "Settings", iconName: "ic_settings_white_48pt", tileSize: tileSize)
        settingTile.frame.origin = CGPoint(x: tileSpacing + (tileWidth + tileSpacing) * 3, y: secondRow)
        settingTile.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
        self.addSubview(settingTile)
        
//        let helpTile = MainMenuTile(title: "Help", iconName: "ic_help_outline_white_48pt", tileSize: tileSize)
//        helpTile.frame.origin = CGPoint(x: tileSpacing + (tileWidth + tileSpacing) * 3, y: secondRow)
//        helpTile.addTarget(self, action: #selector(goToHelp), for: .touchUpInside)
//        self.addSubview(helpTile)
    }
    
    func goToOrders(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadOrdersView()
    }
    
    func goToOpenOrders(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadOpenOrdersView()
    }
    
    func goToOrderHistory(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadOrderHistoryView()
    }
    
    func goToDailyReports(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadDailyReportView()
    }
    
    func goToCustomers(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadCustomersView()
    }
    
    func goToEmployees(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadEmployeesView()
    }
    
    func goToNotes(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadNotesView()
    }
    
    func goToSettings(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadSettingsView()
    }
    
    func goToHelp(){
        menuManagerDelegate?.hideMenu()
        NIMBUS.Navigation?.loadFullHelpPageView()
    }
    
    func showMenu(){
        self.isHidden = false
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn , animations: {
            self.transform = CGAffineTransform.identity
        })
        animator.addCompletion({ (position) in
            
        })
        animator.startAnimation()
    }
    
    func hideMenu(){
        let animator = UIViewPropertyAnimator(duration: 0.2 , curve: .easeIn , animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        })
        animator.addCompletion({ (position) in
            self.isHidden = true
        })
        animator.startAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override class var layerClass: AnyClass {
        return MDCShadowLayer.self
    }
    
    var shadowLayer: MDCShadowLayer {
        return self.layer as! MDCShadowLayer
    }
    
    func setDefaultElevation() {
        self.shadowLayer.elevation = .cardPickedUp
    }
}
