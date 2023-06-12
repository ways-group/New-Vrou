//
//  BottomHomeCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/9/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class BottomHomeCollCell: UICollectionViewCell {
    
    
    @IBOutlet weak var SalonBackGround: UIImageView!
    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    
    
    func UpdateView(salon:Salon) {
        SetImage(image: SalonBackGround, link: salon.salon_background ?? "" )
        SetImage(image: SalonLogo , link: salon.salon_logo ?? "" )
        SalonName.text = salon.salon_name ?? ""
        SalonCategory.text = ""
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
}
