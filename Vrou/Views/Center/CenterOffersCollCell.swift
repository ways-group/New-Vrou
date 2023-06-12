//
//  CenterOffersCollCell.swift
//  Vrou
//
//  Created by Mac on 1/8/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class CenterOffersCollCell: UICollectionViewCell {
    
    @IBOutlet weak var OfferImage: UIImageView!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var offerDescription: UILabel!
    @IBOutlet weak var offerPrice: UILabel!
    @IBOutlet weak var offerTime: UILabel!
    
    var mins = 0
    var hrs = 0
    var days = 0
    var sec = 0
    
    var timer = Timer()
    
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
            }else {
                if hrs > 0 {
                    hrs -= 1
                    mins = 59
                }else {
                    if days > 0 {
                        days -= 1
                        hrs = 23
                        mins = 59
                    }else {
                        offerTime.text = "Offer Ends!"
                    }
                }
            }
        }
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTime.text = "\(days )D: \(hrs )H: \(mins )M: \(sec )sec"
        }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar"  {
            offerTime.text = "\(days )يوم: \(hrs )س: \(mins )د: \(sec )ث"
        }
        
    }
    
    
    func UpdateView(offer:SalonOffer , currency:String) {
        
        SetImage(image: OfferImage, link: offer.image ?? "")
        offerName.text = offer.offer_name ?? ""
        offerDescription.text = offer.offer_description ?? ""
        
        
        let currency = currency
        let finalString = "\(offer.new_price ?? "") \(currency)"
        offerPrice.text = finalString
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTime.text = "\(offer.days ?? "0")D: \(offer.hours ?? "0")H: \(offer.minutes ?? "0")M \(offer.seconds ?? "0")sec"
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTime.text = "\(offer.days ?? "0")يوم: \(offer.hours ?? "0")س: \(offer.minutes ?? "0")د \(offer.seconds ?? "0")ث"
        }
        
        
        runTimer()
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
}
