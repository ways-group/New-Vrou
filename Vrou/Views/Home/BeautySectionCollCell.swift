//
//  BeautySectionCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class BeautySectionCollCell: UICollectionViewCell {
    
    
    @IBOutlet weak var CategoryImage: UIImageView!
    @IBOutlet weak var CategoryName: UILabel!
    @IBOutlet weak var sectionView: UIView!
    
    var id = ""
    var parentId = ""
    func UpdateView(category:Category) {
        CategoryName.text = category.category_name ?? ""
        SetImage(image: CategoryImage, link: category.image ?? "")
        id = "\(category.id ?? Int())"
        parentId = category.parent_id ?? ""
        
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
         image.sd_setImage(with: url, completed: nil)
    }
    
    override var isSelected: Bool {
        didSet {
            sectionView.shadowColor = isSelected ? #colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1) : #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        }
        
    }
    
}
