//
//  OpenVideoPlayer.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//
import AVKit
import AVFoundation

func OpenVideoPlayer(vc :UIViewController, url : String)   {
    let audioSession =  AVAudioSession.sharedInstance()
    
    do{
        try audioSession.setCategory(.playback, mode: .default)
        let audioURL = URL.init(string: url)
        let player = AVPlayer(url: audioURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        vc.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
//        let url1: URL = URL(fileURLWithPath: url)
//        let thumbnail = url1.generateThumbnail()
        
    }catch {
        print(error)
    }
    
  
}
