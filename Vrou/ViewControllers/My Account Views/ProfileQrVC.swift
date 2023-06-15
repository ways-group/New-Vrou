//
//  ProfileQrVC.swift
//  Vrou
//
//  Created by Mac on 12/3/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileQrVC: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLbl: UILabel!
    @IBOutlet weak var CityLbl: UILabel!
    @IBOutlet weak var QRImage: UIImageView!
    @IBOutlet weak var QrCodeLbl: UILabel!
    @IBOutlet weak var walletCreditLbl: UILabel!
    @IBOutlet weak var walletTitleLbl: UILabel!
    
    var QrCodeLink = ""
    var QrCodeString = ""
    var ProfileImage = ""
    var ProfileName = ""
    var City = ""
    var credit = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetImage(image: profileImage, link: ProfileImage)
        SetImage(image: QRImage, link: QrCodeLink)
        profileNameLbl.text = ProfileName
        CityLbl.text = City
        QrCodeLbl.text = "ID: \(QrCodeString)"
        walletCreditLbl.text = credit
        walletTitleLbl.text = NSLocalizedString("WALLET", comment: "")
    }
    
    @IBAction func X_btn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
    
}
