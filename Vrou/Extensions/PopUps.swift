//
//  PopUps.swift
//  Vrou
//
//  Created by Mac on 12/10/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import Foundation

extension UILabel {

    var isTruncated: Bool {

        guard let labelText = text else {
            return false
        }

        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }
    
    var TxtActualHeight: CGFloat {

          let labelText = text

        let labelTextSize = (labelText as! NSString).boundingRect(
             with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
             options: .usesLineFragmentOrigin,
             attributes: [.font: font],
             context: nil).size

         return labelTextSize.height
     }
    
}
