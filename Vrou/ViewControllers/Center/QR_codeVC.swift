//
//  QR_codeVC.swift
//  BeautySalon
//
//  Created by Islam Elgaafary on 10/9/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class QR_codeVC: UIViewController {

    @IBOutlet weak var SalonLogo: UIImageView!
    @IBOutlet weak var SalonName: UILabel!
    @IBOutlet weak var SalonCategory: UILabel!
    @IBOutlet weak var QRImage: UIImageView!
    
    var QrCodeLink = ""
    var salonLogo = UIImage()
    var salonName = ""
    var salonCategory = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetImage(image: QRImage, link: QrCodeLink)
        SalonLogo.image = salonLogo
        SalonName.text  = salonName
        SalonCategory.text = salonCategory
        // Do any additional setup after loading the view.
    }
  
    
    @IBAction func X_btnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func ShareBtn_pressed(_ sender: Any) {
        
        let url = URL(string: QrCodeLink) ?? URL(string:"https://vrou.com")
        if let data = try? Data(contentsOf: url!)
        {
            let image: UIImage = UIImage(data: data) ?? UIImage()
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "LogoPlaceholder"), options: .highPriority , completed: nil)
    }
    
}
