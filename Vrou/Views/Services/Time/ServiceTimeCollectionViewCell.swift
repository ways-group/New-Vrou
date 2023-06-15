//
//  ServiceTimeCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 5/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class ServiceTimeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var time_lbl: UILabel!
    @IBOutlet weak var background_view: UIView!
    
    override var isSelected: Bool{
        didSet{
            time_lbl.textColor = isSelected ? UIColor(named: "whiteColor")! : UIColor(named: "lightGray")!
            background_view.backgroundColor = isSelected ? UIColor(named: "mainColor") : UIColor(named: "whiteColor")!
        }
    }
}
