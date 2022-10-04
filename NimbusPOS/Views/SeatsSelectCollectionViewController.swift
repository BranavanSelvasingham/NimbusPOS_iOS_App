//
//  SeatsSelectCollectionViewController.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-03-10.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "seatSelectCell"

class SeatsSelectCollectionViewController: UICollectionViewController {
    var table: Table? {
        didSet {
            if table != nil {
                numberOfSeats = Int(table?.seats ?? 0)
            }
        }
    }
    
    var seatsArray: [seatStruct] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    var numberOfSeats: Int = 1 {
        didSet {
            var seats = [seatStruct]()
            for seat in 1...numberOfSeats {
                seats.append(seatStruct(seatNumber: seat))
            }
            seatsArray = seats
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.register(SeatSelectCollectionViewCell.self, forCellWithReuseIdentifier: "seatSelectCell")
        self.collectionView?.register(AddSeatCollectionViewCell.self, forCellWithReuseIdentifier: "addSeatCell")
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return seatsArray.count
        } else {
            return 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seatSelectCell", for: indexPath) as! SeatSelectCollectionViewCell
            let seatNumber = seatsArray[indexPath.row].seatNumber
            cell.initCell(seatNumber: seatNumber)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addSeatCell", for: indexPath) as! AddSeatCollectionViewCell
            return cell
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selectedCell = collectionView.cellForItem(at: indexPath) as! SeatSelectCollectionViewCell
            let selectedSeat = selectedCell.seatNumber
            NIMBUS.OrderCreation?.seat = seatStruct(seatNumber: selectedSeat ?? 1)
        } else {
            NIMBUS.OrderCreation?.addSeatToTable()
        }
    }

}
