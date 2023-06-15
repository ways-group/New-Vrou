//
//  TodayOfferCollCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol OfferReservationDelegate {
    func ReservationOffer(id:String)
}


class TodayOfferCell: UICollectionViewCell {

    @IBOutlet weak var salonLogo: UIImageView!
    @IBOutlet weak var salonNameLbl: UILabel!
    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerNameLbl: UILabel!
    @IBOutlet weak var offerPriceLbl: UILabel!
    @IBOutlet weak var offerDescription: UILabel!
    
    var delegate: OfferReservationDelegate!
    var id = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func UpdateView(offer:Offer) {
        salonLogo.SetImage(link: offer.salon_logo ?? "")
        salonNameLbl.text = offer.salon_name ?? ""
        
        offerImage.SetImage(link: offer.image ?? "")
        offerNameLbl.text = offer.offer_name ?? ""
        
        let priceText = NSMutableAttributedString.init(string: "\(offer.new_price ?? "")\(offer.currency ?? "")")
        priceText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9, weight: .semibold)], range: NSMakeRange((offer.new_price?.count ?? 0),offer.currency?.count ?? 0))
        
        offerPriceLbl.layoutIfNeeded()
        offerPriceLbl.attributedText = priceText
        offerDescription.text = offer.offer_description ?? ""
    }
    
    
    @IBAction func ReservationBtn_pressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.ReservationOffer(id: id)
        }
    }
    
}
