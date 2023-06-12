//
//  TodayTableCell.swift
//  Vrou
//
//  Created by Mac on 12/30/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class TodayTableCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
   
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var offerDescription: UILabel!
    @IBOutlet weak var offerPrice: UILabel!
    @IBOutlet weak var offerTimer: UILabel!
    @IBOutlet weak var SalonLogo: UIImageView!
    
    var id = ""
    var days = 0
    var hrs = 0
    var mins = 0
    var sec = 0
    
    var timer = Timer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func UpdateView(offer:Offer) {
        SetImage(image: offerImage, link: offer.image ?? "")
        offerName.text = offer.offer_name ?? ""
        offerDescription.text = offer.offer_description ?? ""
        SetImage(image: SalonLogo , link: offer.salon_logo ?? "")

        
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimer.text = "Ends After \n\(days )D: \(hrs )H: \(mins )M: \(sec )sec"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimer.text = "ينتهي العرض بعد \n\(days )يوم: \(hrs )س: \(mins )د: \(sec)ث"
        }
        
        let currency = " \(offer.currency ?? "")"
        let finalString = (offer.new_price ?? "0") + currency
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        offerPrice.attributedText = amountText
        
        runTimer()
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
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
                    offerTimer.text = "Offer Ends!"
                }
            }
        }
    }
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimer.text = "Ends After \n\(days )D: \(hrs )H: \(mins )M: \(sec )sec"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimer.text = "ينتهي العرض بعد \n\(days )يوم: \(hrs )س: \(mins )د: \(sec)ث"
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
