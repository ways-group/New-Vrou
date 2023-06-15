//
//  SelectServiceTableCell.swift
//  Vrou
//
//  Created by Islam Elgaafary on 5/4/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class SelectServiceTableCell: UITableViewCell {

    
    @IBOutlet weak var ServiceImage: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    
    @IBOutlet weak var selectBtn: UIButton!
    
    var id = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            selectBtn.setImage(#imageLiteral(resourceName: "selected"), for: .normal)
            SelectedServices.services.append(id)
        }else {
           selectBtn.setImage(#imageLiteral(resourceName: "unSelected"), for: .normal)
            if let index = SelectedServices.services.firstIndex(of: id) {
                SelectedServices.services.remove(at: index)
            }
        }

    }
    
    func SetData(service:Service) {
        ServiceImage.SetImage(link: service.image ?? "")
        serviceName.text = service.service_name ?? ""
        serviceDescription.text = service.service_description ?? ""
    }
    
}
