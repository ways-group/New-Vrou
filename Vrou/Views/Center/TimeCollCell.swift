//
//  TimeCollCell.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/4/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class TimeCollCell: UICollectionViewCell {
    
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var SlotView: UIView!
    
    func UpdateView(time:String) {
        TimeLbl.text = time
    }
    
    
    
    override var isSelected: Bool {
        didSet {
            TimeLbl.textColor = isSelected ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            SlotView.backgroundColor = isSelected ? #colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
    }
    
    
    
}
