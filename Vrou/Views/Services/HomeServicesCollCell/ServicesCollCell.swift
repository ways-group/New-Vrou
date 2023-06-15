//
//  ServicesCollCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/19/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class ServicesCollCell: UICollectionViewCell {

    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var specialist_Cell = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var isSelected: Bool{
        didSet{
            if specialist_Cell {
                mainView.borderColor = isSelected ? UIColor(named: "mainColor")! : UIColor(named: "whiteColor")!
                mainView.shadowColor = isSelected ? UIColor(named: "mainColor") : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
        }
    }
    
    func UpdateView_home(category:Category?) {
        serviceImage.SetImage(link: category?.image ?? "")
        serviceLbl.text = category?.service_category ?? ""
    }

    func setAlbum(item: SalonAlbum?) {
        serviceImage.SetImage(link: item?.image ?? "")
        serviceLbl.text = item?.name ?? ""
    }

    func setSpecialist(item: Employee?) {
        specialist_Cell = true
        serviceImage.SetImage(link: item?.image ?? "")
        serviceLbl.text = item?.employee_name ?? ""
    }
}
