//
//  MyWorldAdsCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/8/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class MyWorldAdsCollCell: UICollectionViewCell {
    
    @IBOutlet weak var AdImage: UIImageView!
    var id = ""
    var link = ""
    
    func UpdateView(ad:Ad) {
        let url = URL(string:ad.image ?? "")
        AdImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
    
}
