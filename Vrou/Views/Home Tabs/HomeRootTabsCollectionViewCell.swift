//
//  HomeRootTabsCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/16/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class HomeRootTabsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var title_lbl:UILabel!
    @IBOutlet weak var background_img:UIImageView!
    @IBOutlet weak var icon_img:UIImageView!
    
    func oldCellConfigue() {
        background_img.image = UIImage()
    }
    
    func newCellConfigure() {
        background_img.image = #imageLiteral(resourceName: "selected tab")
    }
}
