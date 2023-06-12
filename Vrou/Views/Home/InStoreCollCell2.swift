//
//  InStoreCollCell2.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class InStoreCollCell2: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var salonIcon: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var ProductPrice: UILabel!
    @IBOutlet weak var ProductDescription: UILabel!
    @IBOutlet weak var StatusView: UIView!
    @IBOutlet weak var StatusLbl: UILabel!
    
    
    func UpdateView(product:Product) {
        SetImage(image: productImage, link: product.main_image ?? "")
        SetImage(image: salonIcon, link: product.store_logo ?? "")
        
        SalonName.text = product.store_name ?? ""
        SalonCategory.text = product.store_type ?? "" 
        ProductName.text = product.product_name ?? ""
        ProductDescription.text = product.product_description ?? ""
        
        let currency = " \(product.currency ?? "")"
        let finalString = (product.sales_price ?? "0") + currency
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        
        ProductPrice.attributedText = amountText
        
        
        
        if product.product_status != "" && product.product_status != nil {
            StatusView.isHidden = false
            StatusLbl.text = product.product_status ?? ""
        }
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
}
