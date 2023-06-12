//
//  MostPopularCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/8/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class MostPopularCollCell: UICollectionViewCell {
    
    @IBOutlet weak var BackImage: UIImageView!
    @IBOutlet weak var CenterLogo: UIImageView!
    @IBOutlet weak var CenterName: UILabel!
    
    var size = CGRect()
    
    override func awakeFromNib() {
        
        // AddBackgroundEffect(image: BackImage)
        
    }
    
    
    func updateView(center:SliderPopularSalon) {
        SetImage(image: BackImage, link: center.salon_background ?? "")
        SetImage(image: CenterLogo, link: center.salon_logo ?? "")
        CenterName.text = center.salon_name ?? ""
    }
    
    func AddBackgroundEffect(image:UIImageView) {
        
        // let view = UIView(frame: image.frame)
        let view = UIView(frame: size)
        
        let gradient = CAGradientLayer()
        
        gradient.frame = view.frame
        
        gradient.colors = [UIColor.white.cgColor, UIColor.white.cgColor]
        
        gradient.locations = [-1.0, 0.8]
        
        view.layer.insertSublayer(gradient, at: 0)
        
        image.addSubview(view)
        
        image.bringSubviewToFront(view)
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
    
    
}
