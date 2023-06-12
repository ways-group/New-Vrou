//
//  MultiChooseTableCell.swift
//  Vrou
//
//  Created by Mac on 1/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class MultiChooseTableCell: UITableViewCell {

    @IBOutlet weak var TxtTableCell: UILabel!
    var id = ""
    var name = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if  SelectedServiceCategoriesEvent.choosenIDs.firstIndex(of: id) != nil {
            self.contentView.backgroundColor = #colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1)
            TxtTableCell.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        if selected {
            // backgroundView?.backgroundColor =
            self.contentView.backgroundColor = #colorLiteral(red: 0.6897211671, green: 0.1131197438, blue: 0.460976243, alpha: 1)
            TxtTableCell.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            SelectedServiceCategoriesEvent.choosenIDs.append(id)
            SelectedServiceCategoriesEvent.choosenNames.append(name)
            
        }else {
            self.contentView.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            TxtTableCell.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            if let i = SelectedServiceCategoriesEvent.choosenIDs.firstIndex(of: id) {
                SelectedServiceCategoriesEvent.choosenIDs.remove(at: i)
                SelectedServiceCategoriesEvent.choosenNames.remove(at: i)
            }
        }
        
        
    }
    

   
    
    func UpdateView(cat:Category) {
        TxtTableCell.text = cat.service_category ?? ""
        id = "\(cat.id ?? Int())"
        name =  cat.service_category ?? ""

    }
    
    

}

