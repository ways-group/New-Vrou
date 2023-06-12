//
//  RelatedOffersCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class RelatedOffersCollCell: UICollectionViewCell {
    
    @IBOutlet weak var OfferImage: UIImageView!
    @IBOutlet weak var OfferName: UILabel!
    @IBOutlet weak var OfferDescription: UILabel!
    @IBOutlet weak var OfferTime: UILabel!
    @IBOutlet weak var OfferPrice: UILabel!
    
    var mins = 0
    var hrs = 0
    var days = 0
    var sec = 0
    
    var timer = Timer()
    var isTimerRunning = false //This will be used to make sure only one timer is created at a time.
    
    
    
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
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            OfferTime.text = "ينتهي العرض بعد \(days )يوم: \(hrs )س: \(mins )د: \(sec )ث"
        }
        
    }
    
    
    func UpdateView(offer:Offer) {
        SetImage(image: OfferImage, link: offer.image ?? "")
        OfferName.text = offer.offer_name ?? ""
        OfferDescription.text = offer.offer_description ?? ""
        
        let currency = " \(offer.currency ?? "")"
        let finalString = (offer.new_price ?? "0") + currency
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        // set the attributed string to the UILabel object
        //
        OfferPrice.attributedText = amountText
        
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0
        sec = Int(offer.seconds ?? "0") ?? 0
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            OfferTime.text = "Ends After \n\(days )D: \(hrs )H: \(mins )M: \(sec )sec"
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            OfferTime.text = "ينتهي العرض بعد \n\(days )يوم: \(hrs )س: \(mins )د: \(sec )ث"
        }
        runTimer()
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
}
