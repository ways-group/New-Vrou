//
//  SalonFeaturesCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/24/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class SalonFeaturesCell: UICollectionViewCell {
    
    @IBOutlet weak var FeatureImage: UIImageView!
    @IBOutlet weak var FeatureLbl: UILabel!
    
    func configure(item: SalonFeatures?){
        SetImage(image: FeatureImage, link: item?.image ?? "")
        FeatureLbl.text = item?.feature_name ?? ""
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
}
