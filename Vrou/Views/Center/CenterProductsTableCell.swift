//
//  CenterProductsTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/22/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

protocol CenterProductsTableCellDelegate {
    func LikeOffer(id:String, index:Int)
    func AddToCart(id:String)
}

class CenterProductsTableCell: UITableViewCell {

    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var newPriceLbl: UILabel!
    @IBOutlet weak var brandImage: UIImageView!
    @IBOutlet weak var buyBtn: UIButton!
    
    var delegate : CenterProductsTableCellDelegate!
    
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
    
    
    func UpdateView(product:SalonProduct, Note:String , price:String, index:Int) {
        productImage.SetImage(link: product.main_image ?? "")
        NameLbl.text = product.product_name ?? ""
        brandImage.SetImage(link: product.brand_image ?? "")
        let currency = " \(product.currency ?? "")"
        let finalString = "\(price) \(currency)"
        let amountText = NSMutableAttributedString.init(string: finalString)
        amountText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .semibold),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1)], range: NSMakeRange(finalString.count-currency.count,currency.count))
        newPriceLbl.attributedText = amountText
        DescriptionLbl.text = product.product_description ?? ""
        
        if product.product_status != "" && product.product_status != nil {
            discountView.isHidden = false
            discountLbl.text = product.product_status ?? ""
        }
        
        id = "\(product.id ?? Int())"
        self.index = index
        
        if User.shared.isLogedIn() {
            if product.is_favourite == 1 {
                likeBtn.setImage(UIImage(named: "icons8-heart-filled"), for: .normal)
            }else {
                likeBtn.setImage(UIImage(named: "icons8-heart"), for: .normal)
            }
        }
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            buyBtn.setImage(UIImage(named: "ar_buy_icon"), for: .normal)
        }
    }

    
    
    @IBAction func LikeBtn_pressed(_ sender: Any) {
        if let delegate = delegate {
            delegate.LikeOffer(id: id, index: index)
        }
    }
    
    @IBAction func BuyBtn_pressed(_ sender: Any) {
        if let delegate = delegate {
            delegate.AddToCart(id: id)
        }
    }

}
