//
//  CategoryHeaderCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var id = ""
    var parentId = ""
    func configure(item: Category?) {
        lbl.text = item?.category_name ?? ""
        img.sd_setImage(with: URL.init(string: item?.image ?? ""), completed: nil)
     }
    
    override var isSelected: Bool {
        didSet {
            mainView.shadowColor = isSelected ? #colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
    }
    func UpdateView(item: Category?) {
        lbl.text = item?.category_name ?? ""
        img.sd_setImage(with: URL.init(string: item?.image ?? ""), completed: nil)
        id = "\(item?.id ?? Int())"
        parentId = item?.parent_id ?? ""
        
    }
      
}
