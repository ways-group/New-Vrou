//
//  OfferCollectionCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/11/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class OfferCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var OfferImage: UIImageView!
    @IBOutlet weak var OfferName: UILabel!
    
    
    func UpdateView(offer:Offer) {
        SetImage(image: OfferImage, link: offer.image ?? "")
        OfferName.text = offer.offer_name ?? ""
    }
    
    
    func UpdateView(offerCatgeory:OfferCategoriesData) {
        SetImage(image: OfferImage, link: offerCatgeory.image ?? "")
        OfferName.text = offerCatgeory.offer_name ?? ""
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
}
