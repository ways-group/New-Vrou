//
//  ServiceReservationCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/18/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

import HCSStarRatingView

class ServiceReservationCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var salon_img: UIImageView!
    @IBOutlet weak var salonLogo_img: UIImageView!
    @IBOutlet weak var salonName_lbl: UILabel!
    @IBOutlet weak var category_lbl: UILabel!
    @IBOutlet weak var salonCity_lbl: UILabel!
    @IBOutlet weak var reservation_view: UIView!
    @IBOutlet weak var reservation_btn: UIButton!
    @IBOutlet weak var SalonRatingStars: HCSStarRatingView!
 
    func UpdateView(salon:Salon?) {
        salonName_lbl.text = salon?.salon_name ?? ""
        category_lbl.text = salon?.search_category_name ?? ""
        salonCity_lbl.text = salon?.area?.area_name //.city?.city_name ?? ""
        SalonRatingStars.value = CGFloat(truncating: NumberFormatter().number(from: salon?.rate ?? "0.0") ?? 0.0)
        salon_img.sd_setImage(with: URL.init(string: salon?.salon_background ?? ""), completed: nil)
        salonLogo_img.sd_setImage(with: URL.init(string: salon?.salon_logo ?? ""), completed: nil)
        
        salon_img.layer.cornerRadius = 8
        salon_img.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        reservation_view.layer.cornerRadius = 5
        reservation_view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        reservation_btn.setTitle("Reservation".ar(), for: .normal)
    }

}
