//
//  PeopleCollCell.swift
//  Vrou
//
//  Created by Mac on 1/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCollCell: UICollectionViewCell {
    
    @IBOutlet weak var personImage: UIImageView!
    var id = ""
    
    func UpdateView(person:Person) {
        SetImage(image:personImage, link: person.image ?? "")
        id = "\(person.id ?? Int())"
        
    }
    
    func UpdateView(image:String) {
        SetImage(image:personImage, link: image)
    }
    
    
    func SetImage(image:UIImageView , link:String) {
           let url = URL(string:link )
           //image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
           image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
           image.sd_setImage(with: url, completed: nil)
       }
}
