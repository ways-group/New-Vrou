//
//  SubCategoryProductCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/12/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class SubCategoryProductCollCell: UICollectionViewCell {
    
    @IBOutlet weak var DiscountView: UIView!
    @IBOutlet weak var DiscountLbl: UILabel!
    @IBOutlet weak var ProductImage: UIImageView!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var ProductPrice: UILabel!
    @IBOutlet weak var ProductDescription: UILabel!
    @IBOutlet weak var NoteLbl: UILabel!
    
    func UpdateView(product:SalonProduct, Note:String , price:String) {
        SetImage(image: ProductImage, link: product.main_image ?? "")
        ProductName.text = product.product_name ?? ""
        ProductPrice.text = price
        
        let currency = " \(product.currency ?? "")"
        let finalString = "\(price) \(currency)"
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        ProductPrice.attributedText = amountText
        ProductDescription.text = product.product_description ?? ""
        NoteLbl.text = Note
        
        if product.product_status != "" && product.product_status != nil {
            DiscountView.isHidden = false
            DiscountLbl.text = product.product_status ?? ""
        }
        
    }
    
    
    
    func UpdateView(product:Product, Note:String , price:String) {
        SetImage(image: ProductImage, link: product.main_image ?? "")
        ProductName.text = product.product_name ?? ""
        ProductPrice.text = price
        
        let currency = " \(product.currency ?? "")"
        let finalString = "\(price) \(currency)"
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        ProductPrice.attributedText = amountText
        ProductDescription.text = product.product_description ?? ""
        NoteLbl.text = Note
        
        if product.product_status != "" && product.product_status != nil {
            DiscountView.isHidden = false
            DiscountLbl.text = product.product_status ?? ""
        }
    }
    
    
    func UpdateView(product:ProductSearchData) {
        SetImage(image: ProductImage, link: product.main_image ?? "")
        ProductName.text = product.product_name ?? ""
        // ProductPrice.text = price
        
        //  let currency = " \(product.currency ?? "")"
        //           let finalString = "\(price) \(currency)"
        //           let amountText = NSMutableAttributedString.init(string: finalString)
        //           amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        //           ProductPrice.attributedText = amountText
        ProductDescription.text = product.product_description ?? ""
        // NoteLbl.text = Note
        
        if product.product_status != "" && product.product_status != nil {
            DiscountView.isHidden = false
            DiscountLbl.text = product.product_status ?? ""
        }
        
    }
    
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
    
}
