//
//  CenterCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/13/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SDWebImage
import MOLH

class CenterCollCell: UICollectionViewCell {
    
    @IBOutlet weak var CenterImage: UIImageView!
    @IBOutlet weak var CenterName: UILabel!
    @IBOutlet weak var CenterCategory: UILabel!
    @IBOutlet weak var CenterLocation: UILabel!
    @IBOutlet weak var CenterOpenState: UILabel!
    @IBOutlet weak var StarsRate: HCSStarRatingView!
    
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var verficationImage: UIImageView!
    
    let toArabic = ToArabic()
    
    func UpdateView(salon:Salon) {
        SetImage(image: CenterImage, link: salon.salon_logo ?? "")
        CenterName.text = salon.salon_name ?? ""
        CenterCategory.text = salon.category?.category_name ?? ""
        if salon.area?.area_name ?? "" != "" {
             CenterLocation.text = "\(salon.city?.city_name ?? "" )-\(salon.area?.area_name ?? "")"
        }else {
             CenterLocation.text = "\(salon.city?.city_name ?? "" )"
        }
       
      
        StarsRate.value = CGFloat(Double(salon.rating ?? "0.0") ?? 0.0)
        
        verficationImage.sd_setImage(with: URL(string: salon.verify_image ?? ""), placeholderImage: UIImage(), options: .highPriority , completed: nil)
        
        if salon.is_open_now == 0 {
            CenterOpenState.text = NSLocalizedString("Close", comment: "")
        }else if salon.is_open_now == 1 {
            CenterOpenState.text = NSLocalizedString("Open", comment: "")
        }
            
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: arrow)
        }
        
    }
    
    
    func UpdateView(salon:CenterSearchData) {
        
        SetImage(image: CenterImage, link: salon.salon_logo ?? "")
        CenterName.text = salon.salon_name ?? ""
        CenterCategory.text = salon.search_category_name ?? ""
        verficationImage.sd_setImage(with: URL(string: salon.verify_image ?? ""), placeholderImage: UIImage(), options: .highPriority , completed: nil)
        // second Verify_image  To be Updated
    }
    
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
       image.sd_setImage(with: url, completed: nil)
    }
    
    
}
