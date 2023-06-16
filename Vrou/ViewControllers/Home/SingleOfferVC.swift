//
//  SingleOfferVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/16/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage

class SingleOfferVC: UIViewController {

    @IBOutlet weak var AdImage: UIImageView!
    
    var image = ""
    var link = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetImage(image: AdImage, link: image)
        setTransparentNavagtionBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTransparentNavagtionBar()
    }
    
    @IBAction func AdBtn_pressed(_ sender: Any) {
       let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "WebVC") as! WebVC
        vc.link = link
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func SetImage(image:UIImageView , link:String) {
           let url = URL(string:link )
           image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
       }

    

}
