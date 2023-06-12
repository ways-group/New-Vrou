//
//  WelcomeBeautyVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/5/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import MOLH

class WelcomeBeautyVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var StartImage: UIImageView!
    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var Welcometxt: UILabel!
    

    // MARK: - Variables
    let toArabic = ToArabic()
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            toArabic.ReverseImage(Image: StartImage)
            toArabic.ReverseImage(Image: ArrowImage)
            toArabic.ReverseLabelAlignment(label: Welcometxt)
        }
    }
    
    
    // MARK: - StartBtn
    @IBAction func StartBtn_pressed(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForYouVC") as! ForYouVC
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
