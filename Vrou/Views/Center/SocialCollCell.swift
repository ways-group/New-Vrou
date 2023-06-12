//
//  SocialCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/15/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class SocialCollCell: UICollectionViewCell {
    
    @IBOutlet weak var SocialImage: UIImageView!
    
    func UpdateView(social:SocialMedia) {
      //  SetImage(image: SocialImage, link: social.)
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
}
