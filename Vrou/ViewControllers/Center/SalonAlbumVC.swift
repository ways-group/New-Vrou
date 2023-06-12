//
//  SalonAlbumVC.swift
//  Vrou
//
//  Created by Mac on 12/11/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD
import AVKit

class SalonAlbumVC: UIViewController {

    @IBOutlet weak var AlbumCollection: UICollectionView!
    var album_id = ""
    var type = ""
    var album = Album()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AlbumCollection.delegate = self
        AlbumCollection.dataSource = self
        GetAlbumData()
        
    }
    
    


}



extension SalonAlbumVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
     let c = album.data?.count ?? 0
    
    return c
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InCenterAlbumCollCell", for: indexPath) as? InCenterAlbumCollCell {

            cell.UpdateView(album: album.data?[indexPath.row] ?? AlbumData(), type: type)

            return cell
        }
 
    
    
    
    return CenterGalleryCollCell()
}


func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let height:CGSize = CGSize(width: self.AlbumCollection.frame.width/2.01 , height: self.AlbumCollection.frame.height/4.01)

        return height
}
    

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    
    return 0;
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
    return 0
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    
    if type == "0" {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SalonGalleryViewController") as! SalonGalleryViewController
        
        vc.selected_image = album.data?[indexPath.row].image ?? ""
        vc.selected_index = indexPath
        vc.album  =  album.data
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }else if type == "1" {
        playVideo(url: URL(string: album.data?[indexPath.row].video ?? "")!)
    }
    

}
    
    
    func playVideo(url: URL) {
         let player = AVPlayer(url: url)
         
         let vc = AVPlayerViewController()
         vc.player = player
         
         self.present(vc, animated: true) { vc.player?.play() }
     }

}




extension SalonAlbumVC {
    
    func GetAlbumData() {
        HUD.show(.progress , onView: view)
        ApiManager.shared.ApiRequest(URL: "\(ApiManager.Apis.AlbumData.description)\(album_id)&type=\(type)" , method: .get, Header: [ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier], ExtraParams: "", view: self.view) { (data, tmp) in
            
            if tmp == nil {
                HUD.hide()
                do {
                    self.album = try JSONDecoder().decode(Album.self, from: data!)
                    self.AlbumCollection.reloadData()
                    
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
                
            }else if tmp == "401" {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.GetAlbumData()
                }
                self.present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    
    
}
