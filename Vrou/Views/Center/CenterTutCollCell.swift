//
//  CenterTutCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/14/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class CenterTutCollCell: UICollectionViewCell {
    
    @IBOutlet weak var VideoImage: UIImageView!
    
    func UpdateView(video:Video) {
        SetImage(image: VideoImage, link: video.image ?? "")
    }

    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        //image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
}
