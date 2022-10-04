//
//  orderLoyaltyView.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-01-20.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class OrderLoyaltyView: UIViewController{
    var loyaltyCategoryCollection: UICollectionView!
    var loyaltyProgramCollection: UICollectionView!
    
    var selectedLoyaltyCategoryType: String = (NIMBUS.LoyaltyPrograms?.loyaltyTypes[0].name)!
    let categoryCellSize = CGSize(width: 100, height: 57)
    let programCellSize =  CGSize(width: 100, height: 120)
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.white
        
        let categoryLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        categoryLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        categoryLayout.itemSize = categoryCellSize
        
        loyaltyCategoryCollection = UICollectionView(frame: self.view.frame, collectionViewLayout: categoryLayout)
        
        let prorgramLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        prorgramLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        prorgramLayout.itemSize = programCellSize
        loyaltyProgramCollection = UICollectionView(frame: self.view.frame, collectionViewLayout: prorgramLayout)
        
        self.loyaltyCategoryCollection.delegate = self
        self.loyaltyCategoryCollection.dataSource = self
        
        self.loyaltyProgramCollection.delegate = self
        self.loyaltyProgramCollection.dataSource = self
        
        loyaltyCategoryCollection.backgroundColor = UIColor.white
        loyaltyProgramCollection.backgroundColor = UIColor.white
        
        self.view.addSubview(loyaltyCategoryCollection)
        self.view.addSubview(loyaltyProgramCollection)
        
        loyaltyCategoryCollection.register(orderLoyaltyCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "loyaltyCategoryCell")
        loyaltyProgramCollection.register(orderLoyaltyProgramCollectionViewCell.self, forCellWithReuseIdentifier: "loyaltyProgramCell")
        
        NIMBUS.LoyaltyPrograms?.initializeOrderLoyaltyView(collectionView: loyaltyProgramCollection)
    }
    
    override func viewWillLayoutSubviews() {
        loyaltyCategoryCollection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: loyaltyCategoryCollection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loyaltyCategoryCollection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loyaltyCategoryCollection, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loyaltyCategoryCollection, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 70).isActive = true
        
        loyaltyProgramCollection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: loyaltyProgramCollection, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: loyaltyCategoryCollection, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loyaltyProgramCollection, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loyaltyProgramCollection, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loyaltyProgramCollection, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
}

extension OrderLoyaltyView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.loyaltyCategoryCollection {
            return NIMBUS.LoyaltyPrograms?.loyaltyTypes.count ?? 0
        } else {
            return NIMBUS.LoyaltyPrograms?.fetchedLoyaltyProgramsAsStructs!.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.loyaltyCategoryCollection {
            let indexCategory = NIMBUS.LoyaltyPrograms?.loyaltyTypes[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loyaltyCategoryCell", for: indexPath) as! orderLoyaltyCategoryCollectionViewCell
            cell.initCell(categoryKey: (indexCategory?.name)!, categoryLabel: (indexCategory?.label)!, color: (indexCategory?.color)!)
            return cell
        } else {
            let indexProgram = NIMBUS.LoyaltyPrograms?.fetchedLoyaltyProgramsAsStructs![indexPath.row] as! loyaltyProgramSchema
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loyaltyProgramCell", for: indexPath) as! orderLoyaltyProgramCollectionViewCell
            cell.initCell(program: indexProgram)
            return cell
        }
    }
}

extension OrderLoyaltyView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.loyaltyCategoryCollection {
            return getSizeOfCategoryCellAt(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        } else {
            return getSizeOfProductCellAt(collectionView: collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
    }
   
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

extension OrderLoyaltyView {
    func getSizeOfProductCellAt (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let containerWidth = collectionView.frame.width
        let containerHeight = collectionView.frame.height
        let cellWidth = (containerWidth)/3 - 6
        let cellHeight = cellWidth * 0.6
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func getSizeOfCategoryCellAt(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let containerWidth = collectionView.layer.bounds.width
        let containerHeight = collectionView.layer.bounds.height
        let cellWidth: CGFloat
        if indexPath.row == 0 {
            cellWidth = CGFloat(70)
        } else {
            cellWidth = CGFloat((containerWidth - 70)/3 - 20)
        }
        let cellHeight = CGFloat(56)
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
