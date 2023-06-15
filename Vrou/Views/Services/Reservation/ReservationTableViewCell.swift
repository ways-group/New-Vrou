//
//  ReservationTableViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 5/11/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class ReservationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var service_img:UIImageView!
    @IBOutlet weak var serviceName_lbl:UILabel!
    @IBOutlet weak var serviceDescription_lbl:UILabel!
    @IBOutlet weak var serviceDuration_lbl:UILabel!
    @IBOutlet weak var servicePrice_lbl:UILabel!
    @IBOutlet weak var currency_lbl:UILabel!
    
    func configure(service : Service?, _ atHome: Bool = false) {
        service_img.layer.cornerRadius = 10
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            service_img.layer.maskedCorners = [.layerMinXMinYCorner]
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"{
           service_img.layer.maskedCorners = [.layerMaxXMinYCorner]
        }
        
        service_img.sd_setImage(with: URL.init(string: service?.image ?? ""), completed: nil)
        serviceName_lbl.text = service?.service_name ?? ""
        serviceDescription_lbl.text = service?.service_description ?? ""
        serviceDuration_lbl.text = "\(service?.service_duration ?? "") \("mins".ar())"
        servicePrice_lbl.text = atHome ? service?.home_price : service?.salon_price
        currency_lbl.text = service?.currency ?? ""
                          
    }
    
}
