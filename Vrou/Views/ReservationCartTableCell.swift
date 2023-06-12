//
//  ReservationCartTableCell.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
import SwipeCellKit


//protocol CancelReservationDelegate {
//    func Cancel()
//}


class ReservationCartTableCell: SwipeTableViewCell {
    
    
    @IBOutlet weak var ReservationImage: UIImageView!
    @IBOutlet weak var ReservationName: UILabel!
    @IBOutlet weak var ReservationDescription: UILabel!
    @IBOutlet weak var ReservationPrice: UILabel!
    @IBOutlet weak var ReservationDuration: UILabel!
    
    
    @IBOutlet weak var SalonIcon: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCity: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var specialistName: UILabel!
    
    
    @IBOutlet weak var ReservationStatus: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var SpecialistView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func UpdateView(service:ComingService) {
        //
        SetImage(image: ReservationImage, link: service.service?.image ?? "")
        ReservationName.text = service.service?.service_name ?? ""
        ReservationDescription.text = service.service?.service_description ?? ""
        ReservationDuration.text = "\(service.service?.service_duration ?? "0") mins"
        
        SetImage(image: SalonIcon, link: service.salon_logo ?? "")
        SalonName.text = service.salon_name ?? ""
        SalonCity.text = service.city_name ?? ""
        ReservationPrice.text = "\(service.price ?? "") \(service.currency_name ?? "")"

        Date.text = service.service_date ?? ""
        time.text = service.service_time ?? ""
        specialistName.text = service.employee?.employee_name ?? ""
        
        if service.employee == nil || service.employee?.employee_name ?? "" == "" {
            SpecialistView.isHidden = true
        }
    }
    
    func UpdateView(reservation:Reservation , histoty:Bool) {
        //
        SetImage(image: ReservationImage, link: reservation.service_image ?? "")
        ReservationName.text = reservation.service_name ?? ""
        ReservationDescription.text = reservation.service_description ?? ""
        ReservationPrice.text = "\(reservation.price ?? "") \(reservation.currency ?? "")"
        ReservationDuration.text = "\(reservation.service_duration ?? "0") mins"
        
        SetImage(image: SalonIcon, link: reservation.salon_logo ?? "")
        SalonName.text = reservation.salon_name ?? ""
        SalonCity.text = reservation.city ?? ""
        Date.text = reservation.service_date ?? ""
        time.text = reservation.service_time ?? ""
        specialistName.text = reservation.employee_name ?? ""
        ReservationStatus.setTitle(reservation.reservation_status_word ?? "" , for: .normal)
        
//        if !histoty {
//            if reservation.reservation_status_word == "confirmed"{
//                CancelBtn.isHidden = true
//            }
//        }else {
//            CancelBtn.isHidden = true
//        }
        
        CancelBtn.isHidden = true
        
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link)
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
    
    @IBAction func CancelBtn_pressed(_ sender: Any) {
        
    }
    
    
    
    
}
