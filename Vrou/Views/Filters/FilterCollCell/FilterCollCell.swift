//
//  FilterCollCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/14/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class FilterCollCell: UICollectionViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    enum filter_type {
        case type
        case rate
    }
    
    var currentFilter = filter_type.type
    var id = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    override func select(_ sender: Any?) {
      
    }
    
    override var isSelected: Bool {
        didSet {
      
            titleLbl.textColor = isSelected ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 0.8)
            mainView.backgroundColor = isSelected ? #colorLiteral(red: 0.03921568627, green: 0.02745098039, blue: 0.3764705882, alpha: 0.9) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            if currentFilter == .type
            {
                if isSelected {
                    Filter_data.filter_type = id
                }
            }
        }
        
    }

    
    func UpdateView(title:String,id:String) {
        titleLbl.text = title
        self.id = id
    }
    
    func UpdateView_stars(title:String) {
        currentFilter = .rate
        titleLbl.text = "\(title) star"
        id = title
    }
    
    
}
