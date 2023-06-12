//
//  collectionCollCell.swift
//  Vrou
//
//  Created by Mac on 1/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class collectionCollCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var ItemImage: UIImageView!
    
    func UpdateView(item:CollectionsItems) {
        SetImage(image: ItemImage, link: item.item_image ?? "")
    }
    
    func SetImage(image:UIImageView , link:String) {
          let url = URL(string:link )
          image.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
          image.sd_setImage(with: url, completed: nil)
      }
    
}
