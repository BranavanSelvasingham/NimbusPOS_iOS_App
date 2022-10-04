//
//  OrderProductsViewManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

protocol OrderProductsViewManagerDelegate {
    func categorySelected(categoryFilter: String)
    func handleProductCellSelect(selectedItem: productSchema)
    func handleSizeCellSelect(selectedSize: productSize)
}

class OrderProductsViewManager: UIViewController{
    
    //Categories
    var categoriesViewController: OrderProductsCategoryCollectionVC!
    var productCategoryViewHeightConstraint: NSLayoutConstraint!
    let categoryCellSize = CGSize(width: 165, height: 50)
    let categoryCellInsets = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
    
    //Products
    var productsViewController: OrderProductsCollectionViewController!
    var expandedGroupProductsViewController: OrderExpandedGroupCollectionViewController!
    var expandedProductSizesViewController: OrderExpandedSizesCollectionViewController!
    let productCellSize = CGSize(width: 165, height: 133)
    let productCellInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    let productCellMinimumGap: CGFloat = 4
    
    //Pop up modals
    var expandedGroupModal: OrderPopUpModalView!
    var expandedSizesModal: OrderPopUpModalView!
    
    var expandedGroupItem: productSchema? {
        didSet{
            expandedGroupProductsViewController.expandedGroupItem = expandedGroupItem
            
            let modalSize = sizeExpandedCollectionView(numberOfTiles: expandedGroupItem?.productsUnderGroup?.count ?? 0)
            let modalOrigin = positionExpandedView(modalSize: modalSize)
            let modalFrame = CGRect(origin: modalOrigin, size: modalSize)
            expandedGroupModal.presentModal(contentView: expandedGroupProductsViewController.view, contentFrame: modalFrame, modalColor: expandedGroupItem?.getCategoryColor() ?? UIColor.white, headerTitle: expandedGroupItem?.name ?? "")
        }
    }
    
    var selectedProductItem: productSchema? {
        didSet {
            if selectedProductItem != nil {
                if selectedProductItem?.sizes?.count == 1 { // Single size
                    NIMBUS.OrderCreation?.addSelectedProductToOrderItems(selectedProductItem: selectedProductItem!, selectedSize: (selectedProductItem?.sizes?.first)!)
                    selectedProductItem = nil
                } else { //Multi-size
                    expandedProductSizesViewController.selectedProductItem = selectedProductItem
                    
                    let modalSize = sizeExpandedCollectionView(numberOfTiles: selectedProductItem?.sizes?.count ?? 0)
                    let modalOrigin = positionExpandedView(modalSize: modalSize)
                    let modalFrame = CGRect(origin: modalOrigin, size: modalSize)
                    expandedSizesModal.presentModal(contentView: expandedProductSizesViewController.view, contentFrame: modalFrame, modalColor: selectedProductItem?.getCategoryColor() ?? UIColor.white, headerTitle: selectedProductItem?.name ?? "" )
                }
            }
        }
    }
    
    var selectedItemSize: productSize? {
        didSet {
            if selectedItemSize != nil  && selectedProductItem != nil {
                NIMBUS.OrderCreation?.addSelectedProductToOrderItems(selectedProductItem: selectedProductItem!, selectedSize: selectedItemSize!)
                selectedItemSize = nil
            }
        }
    }

    var categoryFilter = "All" {
        didSet{
            productsViewController.categoryFilter = categoryFilter
        }
    }
    
    var recentTouchInProductCollectionView = CGPoint()
    
    override func viewDidLoad() {
        startupCategories()
        startupProducts()
        startupExpandedGroup()
        startupExpandedSizes()
        
        startupTouchPointRecorder()
    }
    
    override func viewWillLayoutSubviews() {
        layoutCategories()
        layoutProducts()
        
        expandedGroupModal.resizeView(frame: self.view.frame)
        expandedSizesModal.resizeView(frame: self.view.frame)
    }
    
    func startupTouchPointRecorder(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapInView))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        productsViewController.view.addGestureRecognizer(tap)
    }
    
    func tapInView(tap: UITapGestureRecognizer) {
        recentTouchInProductCollectionView = tap.location(in: productsViewController.view)
    }
    
    func startupCategories(){
        let categoryLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        categoryLayout.sectionInset = categoryCellInsets
        categoryLayout.itemSize = categoryCellSize
        categoryLayout.minimumInteritemSpacing = 4
        categoryLayout.minimumLineSpacing = 4
        
        categoriesViewController = OrderProductsCategoryCollectionVC(collectionViewLayout: categoryLayout)
        
        self.addChildViewController(categoriesViewController)
        categoriesViewController.orderProductsViewManagerDelegate = self
        self.view.addSubview(categoriesViewController.view)
        categoriesViewController.view.frame = self.view.frame
        categoriesViewController.didMove(toParentViewController: self)
        
        self.view.addSubview(categoriesViewController.view)
    }
    
    func layoutCategories(){
        let productCategoriesView = categoriesViewController.view!
        let categoriesPerRow: Int = 4
        
        productCategoriesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: productCategoriesView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productCategoriesView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productCategoriesView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        productCategoryViewHeightConstraint = NSLayoutConstraint(item: productCategoriesView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100)
        
        let numberOfCategories = categoriesViewController.categoriesList.count
        let numberOfRows = ceil(Double(CGFloat(numberOfCategories) / CGFloat(categoriesPerRow)))
        productCategoryViewHeightConstraint.constant = CGFloat(numberOfRows) * (categoryCellSize.height + 4) + categoryCellInsets.top + categoryCellInsets.bottom
        productCategoryViewHeightConstraint?.isActive = true
    }
    
    func startupProducts(){
        let productLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        productLayout.sectionInset = productCellInsets
        productLayout.itemSize = productCellSize
        productLayout.minimumInteritemSpacing = productCellMinimumGap
        productLayout.minimumLineSpacing = productCellMinimumGap
        
        productsViewController = OrderProductsCollectionViewController(collectionViewLayout: productLayout)
        
        self.addChildViewController(productsViewController)
        productsViewController.orderProductsViewManagerDelegate = self
        self.view.addSubview(productsViewController.view)
        productsViewController.view.frame = self.view.frame
        productsViewController.didMove(toParentViewController: self)
        
        let productsView = productsViewController.view!
        
        self.view.addSubview(productsView)
    }
    
    func layoutProducts(){
        let productsView = productsViewController.view!
        
        productsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: productsView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: categoriesViewController.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productsView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productsView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: productsView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func startupExpandedGroup(){
        expandedGroupModal = OrderPopUpModalView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 300)))
        self.view.addSubview(expandedGroupModal)

        let productLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        productLayout.sectionInset = productCellInsets
        productLayout.itemSize = productCellSize
        productLayout.minimumInteritemSpacing = productCellMinimumGap
        productLayout.minimumLineSpacing = productCellMinimumGap

        expandedGroupProductsViewController = OrderExpandedGroupCollectionViewController(collectionViewLayout: productLayout)
        self.addChildViewController(expandedGroupProductsViewController)
        expandedGroupProductsViewController.orderProductsViewManagerDelegate = self
        expandedGroupProductsViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 300, height: 300))
        expandedGroupProductsViewController.didMove(toParentViewController: self)

        expandedGroupModal.addViewToModal(view: expandedGroupProductsViewController.view)
    }
    
    func startupExpandedSizes(){
        expandedSizesModal = OrderPopUpModalView(frame: CGRect(origin: CGPoint(x: 300, y: 0), size: CGSize(width: 300, height: 300)))
        self.view.addSubview(expandedSizesModal)

        let productLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        productLayout.sectionInset = productCellInsets
        productLayout.itemSize = productCellSize
        productLayout.minimumInteritemSpacing = productCellMinimumGap
        productLayout.minimumLineSpacing = productCellMinimumGap


        expandedProductSizesViewController = OrderExpandedSizesCollectionViewController(collectionViewLayout: productLayout)
        self.addChildViewController(expandedProductSizesViewController)
        expandedProductSizesViewController.orderProductsViewManagerDelegate = self
        expandedProductSizesViewController.view.frame = expandedSizesModal.presentFrame
        expandedProductSizesViewController.didMove(toParentViewController: self)
        
        expandedSizesModal.addViewToModal(view: expandedProductSizesViewController.view)
    }
    
    func sizeExpandedCollectionView(numberOfTiles: Int) -> CGSize {
        let cellSize = productCellSize
        
        let maxCollectionViewWidth = CGFloat(3) * cellSize.width + CGFloat(8.0) + 10
        let dynamicCollectionViewWidth = CGFloat(numberOfTiles) * cellSize.width + CGFloat((numberOfTiles - 1 ) * 4 + 10)
        let width = (numberOfTiles > 3) ? maxCollectionViewWidth : dynamicCollectionViewWidth
        
        let maxCollectionViewHeight = CGFloat(2) * cellSize.height + CGFloat(10)
        let dynamicCollectionViewHeight = cellSize.height + CGFloat(10)
        let height = (numberOfTiles > 3) ? maxCollectionViewHeight : dynamicCollectionViewHeight
        
        return CGSize(width: width, height: height)
    }
    
    func positionExpandedView(modalSize: CGSize) -> CGPoint {
        let touchX = recentTouchInProductCollectionView.x
        let touchY = recentTouchInProductCollectionView.y
        
        let maxWidth = productsViewController.view.bounds.width
        let maxHeight = productsViewController.view.bounds.height
        
        let modalWidth = modalSize.width + 10
        let modalHeight = modalSize.height + 10
        
        let x = (touchX + modalWidth) > maxWidth ? maxWidth - modalWidth : touchX
        
        let y = (touchY + modalHeight) > maxHeight ? maxHeight - modalHeight : touchY
        
        return CGPoint(x: x, y: y)
    }
}

extension OrderProductsViewManager: OrderProductsViewManagerDelegate{
    func handleSizeCellSelect(selectedSize: productSize) {
        self.selectedItemSize = selectedSize
    }
    
    func handleProductCellSelect(selectedItem: productSchema) {
        if selectedItem.isGroupObject {
            expandedGroupItem = selectedItem
        } else {
            selectedProductItem = selectedItem
        }
    }
    
    func categorySelected(categoryFilter: String) {
        self.categoryFilter = categoryFilter
    }
}
