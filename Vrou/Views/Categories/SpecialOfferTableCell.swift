//
//  SpecialOfferTableCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SDWebImage

class SpecialOfferTableCell: UITableViewCell {
    
    
    @IBOutlet weak var OfferImage: UIImageView!
    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var OfferName: UILabel!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var Stars: HCSStarRatingView!
    @IBOutlet weak var OfferDescription: UILabel!
    
    
    func UpdateView(offer:Offer) {
        SetImage(image: OfferImage, link:offer.image ?? "")
        SetImage(image: SalonLogo, link: offer.salon_logo ?? "")
        OfferName.text = offer.offer_name ?? ""
        SalonName.text = offer.salon_name ?? ""
        Stars.value = CGFloat(truncating: NumberFormatter().number(from: offer.salon_rate ?? "0.0") ?? 0)
        OfferDescription.text = offer.offer_description ?? ""
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "BeautyLogo"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        // Initialization code
    //    }
    //
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //
    //        // Configure the view for the selected state
    //    }
    
}
