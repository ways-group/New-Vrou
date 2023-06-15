//
//  TutorialCollectionViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//
import UIKit
import SDWebImage

class TutorialCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tutorialBy: UILabel!
    @IBOutlet weak var tutorialDetials: UILabel!
    
    func configure(item: TutorialDetailsModel){
        img.sd_setImage(with: URL.init(string: item.preview_image ?? ""), completed: nil)
        title.text = item.title
        tutorialBy.text = item.uploaded_by
        tutorialDetials.text = item.details
    }
}


