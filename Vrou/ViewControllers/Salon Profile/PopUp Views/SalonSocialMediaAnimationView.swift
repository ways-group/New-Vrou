//
//  SalonSocialMediaAnimationView.swift
//  Vrou
//
//  Created by Esraa Masuad on 5/3/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

class SalonSocialMediaAnimationView: UIViewController {
    
    @IBOutlet weak var stack_view: UIStackView!
    @IBOutlet weak var container_view: UIView!
    @IBOutlet weak var close_btn: UIStackView!
    
    var salonId = 0
    var salonAbout: SalonAboutData? = SalonAboutData()
    var parentView: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.stack_view.subviews.forEach { (item) in
//            item.isHidden = true
//        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveLinear, animations: {
            self.stack_view.subviews.forEach { (item) in
                item.isHidden = false
            }
        }, completion: nil)
    }
}

extension SalonSocialMediaAnimationView {
    
    @IBAction func dismissAction(_ button: UIButton){
        UIView.animate(withDuration: 0.9, delay: 0.0, options: .curveLinear, animations: {
            self.stack_view.subviews.forEach { (item) in
                item.isHidden = false
            }
        }, completion: { (bool) in
            self.dismiss(animated: false)
        })
    }
    
    @IBAction func socialMedia_bottonsAction(_ button: UIButton){
        let url: NSURL = URL(string: "TEL://\(salonAbout?.main_branch?.phone ?? "")")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
}
