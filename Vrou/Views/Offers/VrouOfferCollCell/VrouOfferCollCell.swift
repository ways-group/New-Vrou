//
//  VrouOfferCollCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class VrouOfferCollCell: UICollectionViewCell {

    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerTitleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func UpdateView(offer:OfferCategory) {
        offerImage.SetImage(link: offer.image ?? "")
        offerTitleLbl.text = offer.offer_category_name ?? ""
    }
    
    

}
