//
//  SalonsCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView

class SalonsCollCell: UICollectionViewCell {
    
    @IBOutlet weak var SalonImage: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonRateStars: HCSStarRatingView!
    @IBOutlet weak var SalonCatgeory: UILabel!
    @IBOutlet weak var SalonLocation: UILabel!
    @IBOutlet weak var openClose: UILabel!
    @IBOutlet weak var VerifyImage: UIImageView!
    
    func UpdateView(salon:Salon) {
//        SalonImage.cornerRadius = 0 ;
//        SalonImage.cornerRadius = 37.5 ;
        SetImage(image: SalonImage, link: salon.salon_logo ?? "")
        SalonName.text = salon.salon_name ?? ""
        SalonRateStars.value = CGFloat(truncating: NumberFormatter().number(from: salon.rate ?? "0.0") ?? 0.0)
        SalonCatgeory.text = salon.category?.category_name ?? "NO"
        SalonLocation.text = salon.city?.city_name ?? ""
        
        VerifyImage.sd_setImage(with: URL(string: salon.verify_image ?? ""), placeholderImage: UIImage(), options: .highPriority , completed: nil)
        
        if salon.is_open_now == 0 ||  salon.is_open_now == nil  {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                openClose.text = "Close"
                
            }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                openClose.text = "مغلق"
                
            }
        }else if salon.is_open_now == 1 {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                openClose.text = "Open"
            }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                openClose.text = "مفتوح"
            }
        }
    }
    
    
//    override func prepareForReuse() {
//        // SalonImage.cornerRadius = 0 ;
////        SalonImage.frame = CGRect(origin: SalonImage.bounds.origin/2, size: CGSize(width: SalonImage.bounds.width, height: SalonImage.bounds.width))
//
//        SalonImage.frame  = CGRect(x: SalonImage.bounds.origin.x/2, y: SalonImage.bounds.origin.y/2, width: SalonImage.bounds.width, height: SalonImage.bounds.width)
//
//        SalonImage.cornerRadius = SalonImage.bounds.width/2
//    }
    
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        //image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
    
}
