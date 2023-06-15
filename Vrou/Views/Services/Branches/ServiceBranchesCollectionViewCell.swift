//
//  ServiceBranchesCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 5/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class ServiceBranchesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var branchName_lbl: UILabel!
    @IBOutlet weak var background_view: UIView!
    
    override var isSelected: Bool{
        didSet{
           // branchName_lbl.textColor = isSelected ? UIColor(named: "whiteColor")! : UIColor(named: "textColor")!
            background_view.borderColor = isSelected ? UIColor(named: "mainColor") : UIColor(named: "whiteColor")
        }
    }
}
