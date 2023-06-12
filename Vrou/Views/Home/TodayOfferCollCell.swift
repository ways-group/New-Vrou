//
//  TodayOfferCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/15/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class TodayOfferCollCell: UICollectionViewCell {
    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerTimer: UILabel!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var offerDescription: UILabel!
    @IBOutlet weak var offerPrice: UILabel!
    @IBOutlet weak var SalonLogo: UIImageView!
   
    var id = ""
    var days = 0
    var hrs = 0
    var mins = 0
    var sec = 0
    
    var timer = Timer()
    
    
    
    func UpdateView(offer:Offer) {
        SetImage(image: offerImage, link: offer.image ?? "")
        offerName.text = offer.offer_name ?? ""
        offerDescription.text = offer.offer_description ?? ""
        SetImage(image: SalonLogo, link: offer.salon_logo ?? "")

        
        //   offerTimer.text = "Ends After \(offer.days ?? "0")D: \(offer.hours ?? "0")H: \(offer.minutes ?? "0")M \(offer.seconds ?? "0")sec"
        
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0
        sec = Int(offer.seconds ?? "0") ?? 0
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimer.text = "Ends After \(hrs )H: \(mins )M: \(sec )sec"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimer.text = "ينتهي العرض يعد \(hrs )س: \(mins )د: \(sec )ث"
        }
        
        
        let currency = offer.currency ?? ""
        let finalString = (offer.new_price ?? "0") + currency
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        offerPrice.attributedText = amountText
        
        runTimer()
        
    }
    
    override func prepareForReuse() {
           timer.invalidate()
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
    
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
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
                        offerTimer.text = "Offer Ends!"
                    }
                }
            }
        }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimer.text = "Ends After \(hrs )H: \(mins )M: \(sec )sec"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimer.text = "ينتهي العرض بعد \(hrs )س: \(mins )د: \(sec )ث"
        }
    }
    
    
}
