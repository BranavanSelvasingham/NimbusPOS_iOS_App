//
//  OrderExpandedGroupCollectionViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-06.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "expandedGroupProductCell"

class OrderExpandedGroupCollectionViewController: UICollectionViewController {
    var orderProductsViewManagerDelegate: OrderProductsViewManagerDelegate?
    
    var expandedGroupItem: productSchema? {
        didSet{
            self.collectionView?.reloadData()
        }
    }
    
    var tileSize: CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
        
        // Register cell classes
        self.collectionView!.register(ProductCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return expandedGroupItem?.productsUnderGroup?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indexProduct = expandedGroupItem?.productsUnderGroup?[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionCell
        cell.initCell(product: indexProduct!)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedItem = expandedGroupItem?.productsUnderGroup?[indexPath.row]{
            orderProductsViewManagerDelegate?.handleProductCellSelect(selectedItem: selectedItem)
        }
    }

}
