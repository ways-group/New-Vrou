//
//  SalonOfferTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol SalonOfferTableCellDelegate {
    func LikeOffer(id:String, index:Int)
    func AddToCart(id:String)
}


class SalonOfferTableCell: UITableViewCell {

    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerNameLbl: UILabel!
    @IBOutlet weak var offerDescriptionLbl: UILabel!
    @IBOutlet weak var offerTimeLbl: UILabel!
    @IBOutlet weak var newPriceLbl: UILabel!
    @IBOutlet weak var oldPriceLbl: UILabel!
    @IBOutlet weak var heartIcon: UIButton!
    @IBOutlet weak var buyBtn: UIButton!

    var delegate : SalonOfferTableCellDelegate!
    
    var mins = 0
    var hrs = 0
    var days = 0
    
    var timer = Timer()
    var id = ""
    var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func UpdateView(offer:Offer, index:Int) {
        offerImage.SetImage(link: offer.image ?? "")
        offerNameLbl.text = offer.offer_name ?? ""
        offerDescriptionLbl.text = offer.offer_description ?? ""
        
        mins = Int(offer.minutes ?? "0") ?? 0
        hrs = Int(offer.hours ?? "0") ?? 0
        days = Int(offer.days ?? "0") ?? 0

        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimeLbl.text = "Ends After | \(offer.days ?? "0")D: \(offer.hours ?? "0")H: \(offer.minutes ?? "0")M"
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimeLbl.text = "ينتهي العرض بعد | \(offer.days ?? "0")يوم: \(offer.hours ?? "0")س: \(offer.minutes ?? "0")د"
        }
        
        let NewpriceText = NSMutableAttributedString.init(string: "\(offer.new_price ?? "")\(offer.currency ?? "")")
        NewpriceText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9, weight: .semibold)], range: NSMakeRange((offer.new_price?.count ?? 0),offer.currency?.count ?? 0))
        
        newPriceLbl.attributedText = NewpriceText
        
            
        let OldpriceText: NSMutableAttributedString =  NSMutableAttributedString(string: "\(offer.old_price ?? "")\(offer.currency ?? "")")
        OldpriceText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, OldpriceText.length))
        
        oldPriceLbl.attributedText = OldpriceText
        
        if User.shared.isLogedIn() {
            if offer.is_favourite == 1 {
               heartIcon.setImage(UIImage(named: "icons8-heart-filled"), for: .normal)
            }else {
               heartIcon.setImage(UIImage(named: "icons8-heart"), for: .normal)
            }
        }
        
       if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
             buyBtn.setImage(UIImage(named: "ar_buy_offer_icon"), for: .normal)
        }
        id = "\(offer.id ?? Int())"
        self.index = index
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
                    offerTimeLbl.text = "Offer Ends!"
                }
            }
        }
        
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
            offerTimeLbl.text = "Ends After | \(days )D: \(hrs )H: \(mins )M"
            
        }else if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            offerTimeLbl.text = "ينتهي العرض بعد | \(days )يوم: \(hrs )س: \(mins )د"
        }
    }

    
    
    
    @IBAction func BuyOfferBtn_pressed(_ sender: Any) {
       if let delegate = delegate {
           delegate.AddToCart(id: id)
       }
    }
    
    
    
    @IBAction func HeartBtn_pressed(_ sender: Any) {
       
        if let delegate = delegate {
            delegate.LikeOffer(id: id, index: index)
        }
    }
    
}
