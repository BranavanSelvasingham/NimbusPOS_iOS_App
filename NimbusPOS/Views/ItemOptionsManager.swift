//
//  itemOptionsMenu.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-24.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit

protocol itemOptionsManagerDelegate {
    func refreshAllViews()
    func refreshDiscounts()
    func refreshAddOnsAndSubsData()
    func refreshNotes()
}

class ItemOptionsManager: UIViewController, itemOptionsManagerDelegate{
    var optionsSegmentedControl: UISegmentedControl = UISegmentedControl()
    let segments: [String] = ["Add-Ons", "Substitutions", "Notes", "Discount"]
    
    var optionsMenuContainerView: UIView = UIView()
    
    var selectedAddOnsList = [orderItemAddOns]()
    var associatedAddOnsList = [orderItemAddOns]()
    var genericAddOnsList = [orderItemAddOns]()
    
    var selectedSubstitutionsList = [orderItemAddOns]()
    var associatedSubstitutionsList = [orderItemAddOns]()
    var genericSubstitutionsList = [orderItemAddOns]()
    
    var addedNotes = [String]()
    
    var addOnsController: AddOnsOptionsView = AddOnsOptionsView()
    var substitutionsController: SubstitutionsOptionsView = SubstitutionsOptionsView()
    var notesController: NotesOptionsView = NotesOptionsView()
    var discountsController: DiscountOptionsView = DiscountOptionsView()
    
    override func viewDidLoad() {
        NIMBUS.OrderCreation?.initializeItemOptionsMenu(delegate: self)
        
        optionsSegmentedControl.insertSegment(withTitle: segments[0], at: 0, animated: true)
        optionsSegmentedControl.insertSegment(withTitle: segments[1], at: 1, animated: true)
        optionsSegmentedControl.insertSegment(withTitle: segments[2], at: 2, animated: true)
        optionsSegmentedControl.insertSegment(withTitle: segments[3], at: 3, animated: true)
        
        optionsSegmentedControl.addTarget(self, action: #selector(optionsSegmentedControlSelection), for: .valueChanged)
        
        self.view.addSubview(optionsSegmentedControl)
        self.view.addSubview(optionsMenuContainerView)
        self.view.bringSubview(toFront: optionsSegmentedControl)
        
        self.addChildViewController(addOnsController)
        addOnsController.didMove(toParentViewController: self)
        optionsMenuContainerView.addSubview(addOnsController.view)
        
        self.addChildViewController(substitutionsController)
        substitutionsController.didMove(toParentViewController: self)
        optionsMenuContainerView.addSubview(substitutionsController.view)
        
        self.addChildViewController(notesController)
        notesController.didMove(toParentViewController: self)
        optionsMenuContainerView.addSubview(notesController.view)
        
        self.addChildViewController(discountsController)
        discountsController.didMove(toParentViewController: self)
        optionsMenuContainerView.addSubview(discountsController.view)
        
    }
    
    override func viewWillLayoutSubviews() {
        optionsSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: optionsSegmentedControl, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsSegmentedControl, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsSegmentedControl, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsSegmentedControl, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30).isActive = true
        
        optionsMenuContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: optionsMenuContainerView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: optionsSegmentedControl, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsMenuContainerView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsMenuContainerView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: optionsMenuContainerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    
        //
        addOnsController.view.frame = self.optionsMenuContainerView.frame
        
        //
        substitutionsController.view.frame = self.optionsMenuContainerView.frame
        
        //
        notesController.view.frame = self.optionsMenuContainerView.frame
        
        //
        discountsController.view.frame = self.optionsMenuContainerView.frame
    }
    
    func optionsSegmentedControlSelection() {
        switch optionsSegmentedControl.selectedSegmentIndex
        {
        case 0:
            refreshAddOnsAndSubsData()
            loadAddOnsView()
            
        case 1:
            refreshAddOnsAndSubsData()
            loadSubsView()
            
        case 2:
            refreshNotes()
            loadNotesView()
            
        case 3:
            refreshDiscounts()
            loadDiscountView()
            
        default: break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAllViews()
        loadAddOnsView()
    }
    
    func loadAddOnsView(){
        addOnsController.view.isHidden = false
        substitutionsController.view.isHidden = true
        notesController.view.isHidden = true
        discountsController.view.isHidden = true
        
        if optionsSegmentedControl.selectedSegmentIndex != 0 {
            optionsSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    func loadSubsView(){
        addOnsController.view.isHidden = true
        substitutionsController.view.isHidden = false
        notesController.view.isHidden = true
        discountsController.view.isHidden = true
        
        if optionsSegmentedControl.selectedSegmentIndex != 1 {
            optionsSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    func loadNotesView() {
        addOnsController.view.isHidden = true
        substitutionsController.view.isHidden = true
        notesController.view.isHidden = false
        discountsController.view.isHidden = true
        
        if optionsSegmentedControl.selectedSegmentIndex != 2 {
            optionsSegmentedControl.selectedSegmentIndex = 2
        }
    }
    
    func loadDiscountView(){
        addOnsController.view.isHidden = true
        substitutionsController.view.isHidden = true
        notesController.view.isHidden = true
        discountsController.view.isHidden = false

        if optionsSegmentedControl.selectedSegmentIndex != 3 {
            optionsSegmentedControl.selectedSegmentIndex = 3
        }
    }
    
    func refreshAddOnsAndSubsData(){
        self.addOnsController.refreshAddOnsData()
        self.substitutionsController.refreshSubsData()
    }
    
    func refreshNotes(){
        self.notesController.refreshNotesData()
    }
    
    func refreshDiscounts(){
        self.discountsController.refreshDiscountOptions()
    }
    
    func refreshAllViews(){
        refreshAddOnsAndSubsData()
        refreshNotes()
        refreshDiscounts()
    }
    
}
