//
//  OfferTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView

class OfferTableCell: UITableViewCell {

    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerTimer: UILabel!
    @IBOutlet weak var offerNameLbl: UILabel!
    @IBOutlet weak var offerPriceLbl: UILabel!
    @IBOutlet weak var offerDescriptionLbl: UILabel!
    @IBOutlet weak var salonNameLbl: UILabel!
    @IBOutlet weak var salonLocation: UILabel!
    @IBOutlet weak var offerRate: HCSStarRatingView!
    
    var mins = 0
    var hrs = 0
    var days = 0
    
    var timer = Timer()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    func UpdateView(offer:Offer) {
        
        offerImage.SetImage(link: offer.image ?? "")
        offerImage.layer.cornerRadius = 10
        offerImage.layer.maskedCorners = [.layerMinXMinYCorner]
        
        offerTimer.layer.cornerRadius = 10
        offerTimer.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0

        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimer.text = "Ends After | \(offer.days ?? "0")D: \(offer.hours ?? "0")H: \(offer.minutes ?? "0")M"
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimer.text = "ينتهي العرض بعد | \(offer.days ?? "0")يوم: \(offer.hours ?? "0")س: \(offer.minutes ?? "0")د"
        }
        
        offerNameLbl.text = offer.offer_name ?? ""
        
        let priceText = NSMutableAttributedString.init(string: "\(offer.new_price ?? "")\(offer.currency ?? "")")
        priceText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9, weight: .semibold)], range: NSMakeRange((offer.new_price?.count ?? 0),offer.currency?.count ?? 0))
        
        offerPriceLbl.attributedText = priceText
        offerDescriptionLbl.text = offer.offer_description ?? ""
        
        salonNameLbl.text = offer.salon_name ?? ""
        salonLocation.text = offer.city_name ?? ""
        offerRate.value = CGFloat(truncating: NumberFormatter().number(from: offer.salon_rate ?? "0.0") ?? 0)
        
        runTimer()
    }
    
    
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 60, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        
    }
    
    override func prepareForReuse() {
        timer.invalidate()
    }
    
        
    @objc func updateTimer() {
        
        if mins > 0 {
            mins -= 1
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
        
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimer.text = "Ends After | \(days )D: \(hrs )H: \(mins )M"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimer.text = "ينتهي العرض بعد | \(days )يوم: \(hrs )س: \(mins )د"
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    @IBAction func ReservationBtn_pressed(_ sender: Any) {
        
    }
    
    
    
    
    
}
