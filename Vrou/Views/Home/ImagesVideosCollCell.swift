//
//  ImagesVideosCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/9/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class ImagesVideosCollCell: UICollectionViewCell {
    
    
    @IBOutlet weak var PlayBtn: UIImageView!
    var imageType = true // True for images, False for videos
    @IBOutlet weak var SalonBackGround: UIImageView!
    
    @IBOutlet weak var salonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    
    func UpdateFunc(salon:Salon) {
        SetImage(image: SalonBackGround, link: salon.salon_background ?? "")
        SetImage(image: salonLogo, link: salon.salon_logo ?? "")

        SalonName.text = salon.salon_name ?? ""
        SalonCategory.text = salon.category_name ?? ""
        
        if salon.salon_video == nil {
            PlayBtn.isHidden = true
            PlayBtn.isUserInteractionEnabled = false
        }else {
            PlayBtn.isHidden = false
            PlayBtn.isUserInteractionEnabled = true
            imageType = false
        }

    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
    
}
