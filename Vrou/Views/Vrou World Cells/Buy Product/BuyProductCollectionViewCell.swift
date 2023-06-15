//
//  BuyProductCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/18/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class BuyProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var brand_img: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var ProductPrice: UILabel!
    @IBOutlet weak var ProductDescription: UILabel!
    
    func configure(product:Product?) {
        ProductName.text = product?.product_name ?? ""
        ProductPrice.text = product?.cost_price
        let currency = product?.currency ?? ""
        let finalString = "\(ProductPrice?.text ?? "") \(currency)"
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8, weight: .semibold),NSAttributedString.Key.foregroundColor: UIColor(named: "mainColor")!], range: NSMakeRange(finalString.count-currency.count,currency.count))
        ProductPrice.attributedText = amountText
        ProductDescription.text = product?.product_description ?? ""
        let status =  product?.product_status ?? ""
        if status != "" {
            statusLbl.isHidden = false
            statusLbl.text = product?.product_status ?? ""
        }else{
            statusLbl.isHidden = true
        }
        productImage.sd_setImage(with: URL.init(string: product?.main_image ?? ""), completed: nil)
        brand_img.sd_setImage(with: URL.init(string: product?.branch_name ?? ""), completed: nil)

    }
    
    @IBAction func like_btnAction(_ button: UIButton){
        print("like")
    }
    @IBAction func buy_btnAction(_ button: UIButton){
        print("buy")
    }
}
