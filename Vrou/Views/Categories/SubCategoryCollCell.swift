//
//  SubCategoryCollCell.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/11/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class SubCategoryCollCell: UICollectionViewCell {
    
    
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var MarkView: UIView!
    
    var index = 0
    
    func IsSelected(index:Int) {
        MarkView.isHidden = false
        TitleLbl.font = UIFont.boldSystemFont(ofSize: 17.0)
    }
    
    func UpdateView(category:ProductCategory, index:Int) {
        TitleLbl.text = category.category_name ?? ""
        
        //        if firstRequest {
        //             MarkView.isHidden = index==0 ? false : true
        //        }else {
        //             MarkView.isHidden = true
        //        }
    }
    
    func UpdateView(category:ServiceCategory , index:Int) {
        TitleLbl.text = category.service_category ?? ""
        //MarkView.isHidden = index==0 ? false : true
    }
    
    override var isSelected: Bool {
        didSet {
            MarkView.isHidden = isSelected ? false : true
        }
        
    }
    
    
    
    
}
