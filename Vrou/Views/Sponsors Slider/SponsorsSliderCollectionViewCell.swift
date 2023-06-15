//
//  SponsorsSliderCollectionViewCell.swift
//  Vrou
//
//  Created by MacBook Pro on 1/19/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class SponsorsSliderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    
    func configure(item: Ad){
        img.sd_setImage(with: URL.init(string: item.image ?? ""), completed: nil)
    }
    func configureMainAds(item: MainAd)  {
         img.sd_setImage(with: URL.init(string: item.image ?? ""), completed: nil)
    }
}
