//
//  FamousSalonCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView
class FamousSalonCollCell: UICollectionViewCell {
    
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonLocation: UILabel!
    @IBOutlet weak var SalonRatingStars: HCSStarRatingView!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var FavouritesLbl: UILabel!
    @IBOutlet weak var isOpenLbl: UILabel!
    
    
    func UpdateView(salon:Salon) {
        SetImage(image: SalonImage, link: salon.salon_background ?? "")
        SalonName.text = salon.salon_name ?? ""
        SalonLocation.text = salon.city?.city_name ?? ""
        SalonRatingStars.value = CGFloat(truncating: NumberFormatter().number(from: salon.rate ?? "0.0") ?? 0.0)
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            followersLbl.text = " \(salon.followers_count ?? "0") Followers"
            FavouritesLbl.text = " \(salon.wishlist_count ?? "0") Favourites"
                if salon.is_open_now == 0 {
                            isOpenLbl.text = "Close"
                }else if salon.is_open_now == 1 {
                            isOpenLbl.text = "Open"
                }
            
            
           }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            followersLbl.text = "\(salon.followers_count ?? "0") المتابعون"
            FavouritesLbl.text = "\(salon.wishlist_count ?? "0") اعجاب"
            
                if salon.is_open_now == 0 {
                    isOpenLbl.text = "مغلق"
                }else if salon.is_open_now == 1 {
                    isOpenLbl.text = "مفتوح"
                }
        }
      
    
        
        
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
}
