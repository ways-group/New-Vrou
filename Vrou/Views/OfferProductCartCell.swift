//
//  OfferProductCartCell.swift
//  BeautySalon
//
//  Created by Mac on 10/17/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
import SwipeCellKit

protocol Counter {
    func Add(number:String , id:String , inStock:String) -> String
    func Remove(number:String , id:String) -> String
}

class OfferProductCartCell: SwipeTableViewCell {
    var delegate2 : Counter!
    
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var offerDescription: UILabel!
    @IBOutlet weak var offerPrice: UILabel!
    @IBOutlet weak var counterView: UIView!
    // @IBOutlet weak var Number: UIButton!
    @IBOutlet weak var Number: UILabel!
    
    var id = ""
    var in_stock = ""
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
    
    
    func UpdateView(offer:OfferCartDetails) {
        SetImage(image: offerImage, link: offer.item?.image ?? "")
        offerName.text = offer.item?.offer_name ?? ""
        offerDescription.text = offer.item?.offer_description ?? ""
        offerPrice.text = "\(offer.item?.sales_price ?? "") \(offer.item?.currency ?? "")"
        counterView.isHidden = true
        id = "\(offer.item?.id ?? Int())"
    }
    
    
    func UpdateView(product:OfferCartDetails) {
        SetImage(image: offerImage, link: product.item?.main_image ?? "")
        offerName.text = product.item?.product_name ?? ""
        offerDescription.text = product.item?.product_description ?? ""
        offerPrice.text = "\(product.item?.sales_price ?? "") \(product.item?.currency ?? "")"
        counterView.isHidden = false
        Number.text = "\(product.qty ?? "1")"
        id = "\(product.item?.id ?? Int())"
        in_stock = product.item?.count ?? "0"
    }
    
    func UpdateView_myPurchses(offerProduct:PurchasesProductOffer) {
        SetImage(image: offerImage, link: offerProduct.image ?? "")
        offerName.text = offerProduct.offer_name ?? ""
        offerDescription.text = offerProduct.offer_description ?? ""
        offerPrice.text = "\(offerProduct.item_price ?? "") \(offerProduct.currency ?? "")"
        counterView.isHidden = true
        id = "\(offerProduct.id ?? Int())"
    }
    
    func UpdateView_myPurchses2(productOffer:PurchasesProductOffer) {
        SetImage(image: offerImage, link: productOffer.image ?? "")
        offerName.text = productOffer.product_name ?? ""
        offerDescription.text = productOffer.product_description ?? ""
        offerPrice.text = "\(productOffer.item_price ?? "") \(productOffer.currency ?? "")"
        counterView.isHidden = false
        Number.text = "\(productOffer.qty ?? "1")"
        id = "\(productOffer.id ?? Int())"
    }
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    @IBAction func NegativeBtn_pressed(_ sender: Any) {
        
        if let delegate2 = self.delegate2 {
            Number.text =  delegate2.Remove(number: Number.text ?? "1", id: id)
        }
        
        
        
        
    }
    
    
    @IBAction func PositiveBtn_pressed(_ sender: Any) {
        if let delegate2 = self.delegate2 {
            Number.text =  delegate2.Add(number: Number.text ?? "1", id: id, inStock:in_stock)
        }
    }
    
    
    
    
}

