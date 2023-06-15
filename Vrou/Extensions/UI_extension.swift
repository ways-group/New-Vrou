//
//  UI_extension.swift
//  Aloona
//
//  Created by Islam Elgaafary on 4/24/19.
//  Copyright © 2019 Islam Elgaafary. All rights reserved.
//

import Foundation
import UIKit
import MOLH


struct globalValues {
   static var sideMenu_selected = 0
   static var ShakingEnabled = true
}


extension UIView {
    
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
                layer.masksToBounds = false
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
}


extension UIView {
    
    enum Direction: Int {
        case topToBottom = 0
        case bottomToTop
        case leftToRight
        case rightToLeft
    }
    
    func applyGradient(colors: [Any]?, locations: [NSNumber]? = [0.0, 1.0], direction: Direction = .topToBottom) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        switch direction {
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
        case .bottomToTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            
        case .leftToRight:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
        case .rightToLeft:
            gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        }
        
        self.layer.addSublayer(gradientLayer)
    }
}

 extension CALayer {
    func addGradienBorder(colors:[UIColor],width:CGFloat = 1) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame =  self.bounds //CGRect(origin: CGPoint.zero, size: self.bounds.size)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.colors = colors.map({$0.cgColor})
        gradientLayer.cornerRadius = 5
        gradientLayer.masksToBounds = true
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer

        self.addSublayer(gradientLayer)
    }
}
extension UIFont {
    class func appRegularFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: Constants.App.regularFont, size: size)!
    }
    
    class func appBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: Constants.App.boldFont, size: size)!
    }
}

extension UILabel{
    
   @objc var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of:"-Bd") == nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
    
    @objc var substituteFontNameBold : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of:"-Bd") != nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
}

struct Constants {
    
    // APPLICATION
    struct App {
        // Font
        static let regularFont = NSLocalizedString("AppRegularFont", comment: "")
        static let boldFont = NSLocalizedString("AppBoldFont", comment: "")
        
        // Font
        static let regularFont_ar = NSLocalizedString("AppRegularFont_ar", comment: "")
        static let boldFont_ar = NSLocalizedString("AppBoldFont_ar", comment: "")
        
    }
}

extension  String{
    func ar() -> String{
        return NSLocalizedString(self, comment: "")
    }
}

class ImageMirror: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let current_lang = UserDefaults.standard.string(forKey: "Language") ?? "en"
        
        if current_lang == "ar" {
            if let _img = self.image {
                self.image = UIImage(cgImage: _img.cgImage!, scale:_img.scale , orientation: UIImage.Orientation.upMirrored)
            }
        }
    }
}
class Hi: UIBarButtonItem {
    
    let welcomeBtn =  UIButton(type: .custom)
    var vc: UIViewController!
    let hi_txt = "Hi beautiful..".ar()
    let createAccount_txt = "Create an account or login".ar()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let s = self.welcomeStr
        let current_lang = UserDefaults.standard.string(forKey: "Language") ?? "en"
        
        if User.shared.isLogedIn() {
            self.title =  (hi_txt + " " + (User.shared.data?.user?.name ?? ""))
            self.setTitleTextAttributes([ NSAttributedString.Key.font: UIFont(name: "QuentellCFMedium-Medium", size: 14)!], for: [])
            self.action = #selector(pressedAction)
        }
        else{
            welcomeBtn.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            welcomeBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            welcomeBtn.setTitleColor(.white, for: .normal)
            welcomeBtn.contentHorizontalAlignment = current_lang == "ar" ? .leading : .fill
            welcomeBtn.addTarget(self, action: #selector(self.pressedAction), for: .touchUpInside)
            if current_lang == "en" {
                welcomeBtn.setAttributedTitle(s, for: .normal)
            }else{
                welcomeBtn.titleLabel?.font = UIFont(name: "Tajawal-Light", size: 10)
                welcomeBtn.setTitle(hi_txt + "\n" + createAccount_txt, for: .normal)
            }
            self.customView = welcomeBtn
            let currWidth = self.customView?.widthAnchor.constraint(equalToConstant: 200)
            currWidth?.isActive = true
            let currHeight = self.customView?.heightAnchor.constraint(equalToConstant: 200)
            currHeight?.isActive = true
            welcomeBtn.layoutIfNeeded()
        }
        
    }
    @objc func pressedAction()  {
        if vc != nil {
            let router = RouterManager(vc)
            !User.shared.isLogedIn() ?
                router.push(view: View.loginVC, presenter: BasePresenter.self, item: BaseItem())
                : router.push(controller:   View.userProfileVC.identifyViewController(viewControllerType: ProfileVC.self))
        }
    }
    
    lazy var welcomeStr: NSMutableAttributedString = {
        let s =  NSMutableAttributedString(string: hi_txt + "\n" + createAccount_txt)
        s.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "QuentellCFMedium-Medium", size: 14)!, range: NSMakeRange(0, hi_txt.count - 1))
        s.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 10), range: NSMakeRange(hi_txt.count, createAccount_txt.count + 1))
        s.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "whiteColor")!, range: NSMakeRange(0, s.string.count))
        return s
    }()
}

