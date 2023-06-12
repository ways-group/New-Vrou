//
//  CenterServicesTableCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class CenterServicesTableCell: UITableViewCell {
    
    @IBOutlet weak var OfferImage: UIImageView!
    @IBOutlet weak var Salonlogo: UIImageView!
    @IBOutlet weak var OfferName: UILabel!
    @IBOutlet weak var OfferDescription: UILabel!
    @IBOutlet weak var OfferTime: UILabel!
    @IBOutlet weak var OfferPrice: UILabel!
    
    @IBOutlet weak var ServiceDuration: UILabel!
    
    var mins = 0
    var hrs = 0
    var days = 0
    var sec = 0
    
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
    }
    
    override func prepareForReuse() {
        timer.invalidate()
    }
    
    @objc func updateTimer() {
        
        if sec > 0 {
            sec -= 1
        }else{
            if mins > 0 {
                mins -= 1
                sec = 59
                //  return
            }else {
                if hrs > 0 {
                    hrs -= 1
                    mins = 59
                    // return
                }else {
                    if days > 0 {
                        days -= 1
                        hrs = 23
                        mins = 59
                        //  return
                    }else {
                        OfferTime.text = "Offer Ends!"
                    }
                }
            }
        }
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            OfferTime.text = "Ends After \(days )D: \(hrs )H: \(mins )M: \(sec )sec"
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
            OfferTime.text = "ينتهي العرض بعد \(days )يوم: \(hrs )س: \(mins )د: \(sec )ث"
        }
        
    }
    
    
    func UpdateView(offer:SalonOffer , currency:String) {
        
        SetImage(image: OfferImage, link: offer.image ?? "")
        //  SetImage(image: Salonlogo, link: offer.salon_logo ?? "") //To be EDITED
        OfferName.text = offer.offer_name ?? ""
        OfferDescription.text = offer.offer_description ?? ""
        
        
        let currency = currency
        let finalString = "\(offer.new_price ?? "") \(currency)" 
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 7, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        // set the attributed string to the UILabel object
        //
        OfferPrice.attributedText = amountText
        //  PriceLbl.text = offer.new_price ?? "0"
        
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0
        //    OfferTime.text = "Ends After \n\(days )D: \(hrs )H: \(mins )M: \(sec )sec"
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            OfferTime.text = "Ends After \(offer.days ?? "0")D: \(offer.hours ?? "0")H: \(offer.minutes ?? "0")M \(offer.seconds ?? "0")sec"
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            OfferTime.text = "ينتهي العرض بعد \(offer.days ?? "0")يوم: \(offer.hours ?? "0")س: \(offer.minutes ?? "0")د \(offer.seconds ?? "0")ث"
        }
        
        
        runTimer()
    }
    
    
    func UpdateView(service:SalonService , price:String , currency:String) {
        
        SetImage(image: OfferImage, link: service.image ?? "")
        //  SetImage(image: Salonlogo, link: offer.salon_logo ?? "") //To be EDITED
        OfferName.text = service.service_name ?? ""
        OfferDescription.text = service.service_description ?? ""
        
        // let currency = " L.E"
        let finalString = "\(price) \(currency)"
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 7, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        
        if price == "0.00" {
            if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                OfferPrice.text = "Call Salon"
            }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                OfferPrice.text = "اتصل بالصالون"
            }
        }else {
            OfferPrice.attributedText = amountText
            
        }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            ServiceDuration.text = "\(service.service_duration ?? "0") minutes"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            ServiceDuration.text = "\(service.service_duration ?? "0") دقيقة"
        }
        
        
    }
    
    
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
}
