//
//  UIImage_extension.swift
//  Vrou
//
//  Created by Mac on 2/20/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import Foundation

extension UIImage {
    // image with rounded corners
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
   
    
}


extension UIImageView {
    
    public func AddBlurEffect(blueEffectStrength:Float) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = CGFloat(blueEffectStrength)
        blurEffectView.tag = 101
        self.addSubview(blurEffectView)
    }
    
    public func RemoveBlurEffect(){
        if let viewWithTag = self.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func ReverseImage() {
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
            self.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
}


extension UIView {
    
    public func AddViewBlurEffect(blueEffectStrength:Float, tag:Int) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = CGFloat(blueEffectStrength)
        blurEffectView.tag = tag
        self.addSubview(blurEffectView)
    }
    
    public func RemoveViewBlurEffect(tag:Int){
        if let viewWithTag = self.viewWithTag(tag) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    
    
}

@IBDesignable
class GradientColorView: UIView {

    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}


extension UIImageView {
    
    func SetImage(link:String) {
        let url = URL(string:link )
        self.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        self.sd_setImage(with: url, completed: nil)
    }
}
