//
//  NoConnectionVC.swift
//  Vrou
//
//  Created by Mac on 10/22/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit

class NoConnectionVC: UIViewController {
    override func viewDidLoad() {
        let offerImage = UIImage.gifImageWithName("Animation - 1733891015564")
        noConnectionImage.image = offerImage
    }
    
    var callbackClosure: (() -> Void)?
    
    override func viewWillDisappear(_ animated: Bool) {
        callbackClosure?()
    }
    
    
    @IBOutlet weak var noConnectionImage: UIImageView!
    @IBAction func TryAgainBtn_pressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
