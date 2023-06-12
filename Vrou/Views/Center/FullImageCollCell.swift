//
//  FullImageCollCell.swift
//  Vrou
//
//  Created by Mac on 11/24/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

class FullImageCollCell: UICollectionViewCell {
    
    
    @IBOutlet weak var Image: UIImageView!
    
    
    func UpdateView(image:String, video:Bool) {
        
        if video {
            Image.image = createVideoThumbnail(from: URL(string:image)!)
        }else {
            SetImage(image: Image, link: image)
        }
       
        
    }
    
    
    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.backgroundColor = #colorLiteral(red: 0.8115878807, green: 0.8115878807, blue: 0.8115878807, alpha: 1)
        image.sd_setImage(with: url, completed: nil)
    }
    
    
    private func createVideoThumbnail(from url: URL) -> UIImage? {

        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.maximumSize = CGSize(width: frame.width, height: frame.height)

        let time = CMTimeMakeWithSeconds(0.5, preferredTimescale:60)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        }
        catch {
          print(error.localizedDescription)
          return nil
        }

    }
    
}
