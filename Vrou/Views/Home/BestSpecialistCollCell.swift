//
//  BestSpecialistCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class BestSpecialistCollCell: UICollectionViewCell {
    
    @IBOutlet weak var SpecialistImage: UIImageView!
    @IBOutlet weak var SpecialistName: UILabel!
    @IBOutlet weak var SpecialistCategory: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    var id = ""
    var reservation = false
    
    func UpdateView(specialist:Specialist) {
        SetImage(image: SpecialistImage, link: specialist.salon_background ?? "")
        SpecialistName.text = specialist.salon_name ?? ""
        SpecialistCategory.text = specialist.category?.category_name ?? ""
        id = "\(specialist.id ?? Int())"
    }
    
    func UpdateView(employee:Employee) {
        SpecialistName.text = employee.employee_name ?? ""
        SetImage(image: SpecialistImage, link: employee.image ?? "")
        id = "\(employee.id ?? Int())"
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
       // image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
         image.sd_setImage(with: url, completed: nil)
    }
    
    override var isSelected: Bool {
        didSet {
            if reservation {
                SpecialistName.textColor = isSelected ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                mainView.backgroundColor = isSelected ? #colorLiteral(red: 0.6833723187, green: 0.1359050274, blue: 0.4578525424, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
    }
    
    
    
}
