//
//  SalonProfileTabsCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/22/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class SalonProfileTabsCell: UICollectionViewCell {
    
    @IBOutlet weak var title_lbl:UILabel!
    @IBOutlet weak var selected_view:UIView!
    
    func oldCellConfigue() {
        selected_view.backgroundColor = UIColor.clear
        title_lbl.textColor = UIColor(named: "grayColor2")
    }
    
    func newCellConfigure() {
        selected_view.backgroundColor = UIColor(named: "mainColor")
        title_lbl.textColor = UIColor(named: "mainColor")
    }
    
}
