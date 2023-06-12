//
//  CenterGalleryCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class CenterGalleryCollCell: UICollectionViewCell {
    
    @IBOutlet weak var centerImage: UIImageView!
    
    
    
    func UpdateView(media:Media) {
        SetImage(image: centerImage, link: media.image ?? "")
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
}
