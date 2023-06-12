//
//  ServcisesCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/12/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class ServcisesCollCell: UICollectionViewCell {
    
    @IBOutlet weak var ServiceImage: UIImageView!
    @IBOutlet weak var ServiceName: UILabel!
    @IBOutlet weak var SalonCount: UILabel!
    
    
    func UpdateView(category:Category) {
        SetImage(image: ServiceImage, link: category.image ?? "")
        ServiceName.text = category.service_category ?? ""
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            SalonCount.text = "\(category.salons_count ?? 0) Salons"
            
        }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            SalonCount.text = "\(category.salons_count ?? 0) صالونات"  
        }
    }
    
    
    func UpdateView_home(category:Category?) {
        SetImage(image: ServiceImage, link: category?.image ?? "")
        ServiceName.text = category?.service_category ?? ""
       
    }
    
    
    func UpdateView_center(album:SalonAlbum) {
        SetImage(image: ServiceImage, link: album.image ?? "")
        ServiceName.text = album.name ?? ""
    }

    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
     //   image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
}
