//
//  InCenterAlbumCollCell.swift
//  Vrou
//
//  Created by Mac on 12/11/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
import AlamofireImage

class InCenterAlbumCollCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var PlayBtnImage: UIImageView!
 
    var type = ""
    
    func UpdateView(album:AlbumData , type:String) {
        
        self.type = type
        
        if type == "0" {
            SetImage(image: albumImage, link: album.image ?? "")
            PlayBtnImage.isHidden = true
            
        }else if type == "1" {
            SetImage(image: albumImage, link: album.image ?? "")
        }
        
    }
    
    
    func SetImage(image:UIImageView , link:String) {
         let url = URL(string:link )
         image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
     }
    
    
}
