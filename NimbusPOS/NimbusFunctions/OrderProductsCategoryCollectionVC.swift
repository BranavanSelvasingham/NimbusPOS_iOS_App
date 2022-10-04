//
//  OrderProductsCategoryCollectionVC.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

private let reuseIdentifier = "categoryCell"

class OrderProductsCategoryCollectionVC: UICollectionViewController {
    var orderProductsViewManagerDelegate: OrderProductsViewManagerDelegate?
    
    var categoriesList = [productCategorySchema](){
        didSet{
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.backgroundColor = UIColor.white
        
        // Register cell classes
        self.collectionView!.register(CategoryCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.Categories?.managedContext)
        
        refreshCategoriesData()
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = ProductCategory.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshCategoriesData)
    }
    
    func refreshCategoriesData(){
        categoriesList = []
        
        var anyCategory = productCategorySchema()
        anyCategory.name = "All"
        
        categoriesList.append(anyCategory)
        NIMBUS.Categories!.getCategoriesSorted().forEach {category in
            categoriesList.append(category.convertToStruct())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CategoryCollectionCell
        let indexCategory = categoriesList[indexPath.row]
        cell.initCell(category: indexCategory)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categorySelected = categoriesList[indexPath.row]
        let selectedCell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionCell
        let categoryFilter = categorySelected.name ?? ""
        orderProductsViewManagerDelegate?.categorySelected(categoryFilter: categoryFilter)
    }
}
