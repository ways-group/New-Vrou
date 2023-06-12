//
//  HomeBottomCollCell2.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/23/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class HomeBottomCollCell2: UICollectionViewCell {
    
    @IBOutlet weak var BackImage: UIImageView!
    @IBOutlet weak var salonLogo: UIImageView!
    @IBOutlet weak var salonName: UILabel!
    @IBOutlet weak var salonCategory: UILabel!
    
    func UpdateView(salon:Salon) {
        SetImage(image: BackImage, link: salon.salon_background ?? "")
        SetImage(image: salonLogo, link: salon.salon_logo ?? "")
        salonName.text = salon.salon_name ?? ""
        salonCategory.text =  salon.category_name ?? ""

    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
    
}
