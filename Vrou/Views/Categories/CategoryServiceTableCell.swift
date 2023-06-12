//
//  CategoryServiceTableCell.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
import HCSStarRatingView

class CategoryServiceTableCell: UITableViewCell {
    
    
    @IBOutlet weak var ServiceImage: UIImageView!
    @IBOutlet weak var ServiceName: UILabel!
    @IBOutlet weak var ServiceDescription: UILabel!
    @IBOutlet weak var ServiceDuration: UILabel!
    @IBOutlet weak var ServicePrice: UILabel!
    
    @IBOutlet weak var CategoryImage: UIImageView!
    @IBOutlet weak var CategoryRate: HCSStarRatingView!
    @IBOutlet weak var CategoryName: UILabel!
    
    @IBOutlet weak var salonName: UILabel!
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        // Initialization code
    //    }
    //
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    
    
    
    func UpdateView(service:Service, home:String) {
        SetImage(image: ServiceImage, link: service.image ?? "")
        ServiceName.text = service.service_name ?? ""
        ServiceDescription.text = service.service_description ?? ""
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
            ServiceDuration.text = "\(service.service_duration ?? "0") Minutes"
        }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
            ServiceDuration.text = "\(service.service_duration ?? "0") دقيقة"
        }
        SetImage(image: CategoryImage, link: service.salon_logo ?? "")
        CategoryRate.value = CGFloat(truncating: NumberFormatter().number(from: service.rate ?? "0.0") ?? 0)
        CategoryName.text = service.category?.service_category ?? ""
        salonName.text = service.salon_name ?? ""
        
        if home == "1" {
            if service.home_price == "0.00" {
                       
                   
                   if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
                      ServicePrice.text = "Call Salon"
                   }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
                       ServicePrice.text = "اتصل بالصالون"
                   }
                       
                   } else {
                       ServicePrice.text = "\(service.home_price ?? "0") \(service.currency ?? "")"
                   }
        }else {
           if service.salon_price == "0.00" {
                      
                  
                  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
                     ServicePrice.text = "Call Salon"
                  }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
                      ServicePrice.text = "اتصل بالصالون"
                  }
                      
                  } else {
                      ServicePrice.text = "\(service.salon_price ?? "0") \(service.currency ?? "")"
                  }
        }
        
    }
    
    
    func UpdateView(service:ServiceSearchData) {
        SetImage(image: ServiceImage, link: service.image ?? "")
        ServiceName.text = service.service_name ?? ""
        ServiceDescription.text = service.service_description ?? ""
        //        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
        //            ServiceDuration.text = "\(service.service_duration ?? "0") Minutes"
        //        }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
        //            ServiceDuration.text = "\(service.service_duration ?? "0") دقيقة"
        //        }
        //     SetImage(image: CategoryImage, link: service.category?.image ?? "")
        CategoryRate.value = CGFloat(truncating: NumberFormatter().number(from: service.rate ?? "0.0") ?? 0)
        //  CategoryName.text = service.category?.service_category ?? ""
        //   salonName.text = service.salon_name ?? ""
        
        if service.service_price == "0.00" {
            
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
           ServicePrice.text = "Call Salon"
        }else  if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en"{
            ServicePrice.text = "اتصل بالصالون"
        }
            
        } else {
            ServicePrice.text = "\(service.service_price ?? "0") \(service.currency ?? "")"
        }
        
        
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
}
