//
//  VideoPlayerVC.swift
//  Vrou
//
//  Created by Mac on 10/31/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SDWebImage

class VideoPlayerVC: UIViewController {

    @IBOutlet weak var videoView: UIView!
    var player : AVPlayer!
    var avPlayerLayer : AVPlayerLayer!
  
    @IBOutlet weak var salonName: UILabel!
    @IBOutlet weak var salonCatgeory: UILabel!
    @IBOutlet weak var salonImage: UIImageView!
    @IBOutlet weak var PlayBtn: UIButton!
    
    var link = ""
    var id = ""
    var salon_name = ""
    var salon_Image = ""
    var playing = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // SetSalon Data
        SetImage(image: salonImage, link: salon_Image)
        salonName.text = salon_name
        ///////
        
        player = AVPlayer(url: URL(string: link)!)
        avPlayerLayer = AVPlayerLayer(player: player)
      //  avPlayerLayer.videoGravity = AVLayerVideoGravity.resize
        videoView.layer.addSublayer(avPlayerLayer)
        player.play()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer.frame = videoView.layer.bounds
    }
    
    @IBAction func PlayPauseBtn_pressed(_ sender: Any) {
        if playing {
            playing = false
            player.pause()
            PlayBtn.setImage(#imageLiteral(resourceName: "icons8-play_filled"), for: .normal)
        }else {
            playing = true
            player.play()
             PlayBtn.setImage(#imageLiteral(resourceName: "icons8-pause_filled"), for: .normal)
        }
        
    }
    

    
    func SetImage(image:UIImageView , link:String) {
        let url = URL(string:link )
        image.sd_setImage(with: url, placeholderImage:UIImage(), options: .highPriority , completed: nil)
    }
    
    
    
    @IBAction func SalonBtn_pressed(_ sender: Any) {
        NavigationUtils.goToSalonProfile(from: self, salon_id: Int(id) ?? 0)

    }
    
    
}
