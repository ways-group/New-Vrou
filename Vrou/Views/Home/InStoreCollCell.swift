//
//  InStoreCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
class InStoreCollCell: UICollectionViewCell {
    
    @IBOutlet weak var inStoreImage: UIImageView!
    @IBOutlet weak var InStoreName: UILabel!
    @IBOutlet weak var SalonIcon: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var StatusView: UIView!
    @IBOutlet weak var StatusLbl: UILabel!
    
    
    
    func UpdateView(product:Product) {
        SetImage(image: inStoreImage, link: product.main_image ?? "")
        InStoreName.text = product.product_name ?? ""
        SetImage(image: SalonIcon, link: product.store_logo ?? "")
        SalonName.text = product.store_name ?? ""
        SalonCategory.text = product.store_type ?? ""
        
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
