//
//  OrderProductsCollectionViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "productCell"

class OrderProductsCollectionViewController: UICollectionViewController {
    var orderProductsViewManagerDelegate: OrderProductsViewManagerDelegate?
    
    var categoryFilter = "All" {
        didSet{
            refreshProductsData()
        }
    }
    
    var productList = [productSchema](){
        didSet{
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    var expandedGroupItem: productSchema?
    
    var addToOrderProduct = orderItem()
    
    var selectedProductItem: productSchema? {
        didSet {
            if selectedProductItem != nil {
                if selectedProductItem?.sizes?.count == 1 {
                    NIMBUS.OrderCreation?.addSelectedProductToOrderItems(selectedProductItem: selectedProductItem!, selectedSize: (selectedProductItem?.sizes?.first)!)
                    selectedProductItem = nil
                }
            }
        }
    }
    
    var selectedItemSize: productSize? {
        didSet {
            if selectedItemSize != nil {
                NIMBUS.OrderCreation?.addSelectedProductToOrderItems(selectedProductItem: selectedProductItem!, selectedSize: selectedItemSize!)
                selectedItemSize = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        // Register cell classes
        self.collectionView!.register(ProductCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: NIMBUS.Products?.managedContext)
        
        let refreshControl = UIRefreshControl()
        self.collectionView!.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshProductsData), for: .valueChanged)
        
        refreshProductsData()
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        let entityDescription = Product.entity()
        NIMBUS.Data?.parseNotificationManagedObjectContextDidChange(entityDescription: entityDescription, notification: notification, callFunction: refreshProductsData)
    }
    
    func refreshProductsData(){
        productList = NIMBUS.Products!.getProductCollectionViewData(categoryFilter: categoryFilter)
        self.collectionView!.refreshControl?.endRefreshing()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indexProduct = productList[indexPath.row] as! productSchema
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionCell
        cell.initCell(product: indexProduct)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = productList[indexPath.row]
        orderProductsViewManagerDelegate?.handleProductCellSelect(selectedItem: selectedItem)
    }
}
