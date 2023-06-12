//
//  CenterFeaturesCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class CenterFeaturesCollCell: UICollectionViewCell {
    
    @IBOutlet weak var FeatureImage: UIImageView!
    @IBOutlet weak var FeatureLbl: UILabel!
    
    func UpdateView(image:String , title:String) {
        SetImage(image: FeatureImage, link: image)
        FeatureLbl.text = title
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
}
