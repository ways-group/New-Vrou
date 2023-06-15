//
//  TitleAndDescriptionCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/18/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class TitleAndDescriptionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!

    func configure(item: Salon?){
        img.sd_setImage(with: URL.init(string: item?.salon_background ?? ""), completed: nil)
        title.text = item?.salon_name ?? ""
        var details_txt = item?.category?.category_name ?? ""
        let area = item?.area?.area_name ?? ""
        let category = item?.search_category_name ?? ""
        details_txt = (details_txt == "") ? ((area == "") ? category : area) : details_txt
        details.text = details_txt
       // details.text = item?.city?.city_name ?? ""
    }

}
