//
//  OrderExpandedSizesCollectionViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "expandedProductSizeCell"

class OrderExpandedSizesCollectionViewController: UICollectionViewController {
    var orderProductsViewManagerDelegate: OrderProductsViewManagerDelegate?
    
    var selectedProductItem: productSchema? {
        didSet {
            selectedProductSizes = selectedProductItem?.getSortedSizes() ?? []
        }
    }
    
    var selectedProductSizes: [productSize] = [productSize]() {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        // Register cell classes
        self.collectionView!.register(ExpandedProductSizeCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedProductSizes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indexItem = selectedProductSizes[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ExpandedProductSizeCell
        cell.initCell(size: indexItem, product: selectedProductItem)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItemSize = selectedProductSizes[indexPath.row]
        orderProductsViewManagerDelegate?.handleSizeCellSelect(selectedSize: selectedItemSize)
    }
}
