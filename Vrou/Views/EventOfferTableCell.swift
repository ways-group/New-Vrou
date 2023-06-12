//
//  EventOfferTableCell.swift
//  Vrou
//
//  Created by Mac on 1/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SDWebImage

protocol EventOfferDelegate {
    func Accept_Reject(OfferID:String, action:String) // 0 : reject , 1:accept
}

class EventOfferTableCell: UITableViewCell {

    @IBOutlet weak var salonImage: UIImageView!
    @IBOutlet weak var salonNameLbl: UILabel!
    @IBOutlet weak var salonCityLbl: UILabel!
    @IBOutlet weak var salonServicesLbl: UILabel!
    @IBOutlet weak var starsView: HCSStarRatingView!
    @IBOutlet weak var offerPrice: UILabel!
    @IBOutlet weak var optionsView: UIView!
    
    var delegate : EventOfferDelegate!
    var id = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func UpdateView(offer:EventOffer, available_status:String) {
        SetImage(image: salonImage, link: offer.salon?.salon_logo ?? "")
        salonNameLbl.text = offer.salon?.salon_name ?? ""
        salonCityLbl.text = offer.salon?.city?.city_name ?? ""
        id = "\(offer.id ?? Int())"
        
        starsView.value = CGFloat(Double(offer.salon?.rating ?? "0.0") ?? 0.0)
       
        let price = offer.price ?? "0.0" + " "
        offerPrice.text = price + " " + (offer.salon?.currency?.currency_name ?? "")
        
        if available_status  == "1" {
            optionsView.isHidden = false
        }else {
            optionsView.isHidden = true
        }
        
        
        var f_loop = false
        var tmp = ""
        offer.service_categories?.forEach({ (service) in
            if f_loop {
                 tmp += ", " + (service.service_category ?? "")
            }else {
                 tmp += (service.service_category ?? "")
                f_loop = true
            }
        })
        
        salonServicesLbl.text = tmp
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    @IBAction func RejectBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.Accept_Reject(OfferID: id, action: "0")
        }
    }
    
    
    @IBAction func AcceptBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.Accept_Reject(OfferID: id, action: "1")
        }
    }
    
    
    func SetImage(image:UIImageView , link:String) {
          let url = URL(string:link )
          image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
          image.sd_setImage(with: url, completed: nil)
      }
    
    
}
