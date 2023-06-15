//
//  UserProfileGallaryVC.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/25/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import BSImagePicker
import Photos
import Alamofire
import AVKit
import BSImagePicker
import Photos

class UserProfileGallaryVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var MyPhotosCollection: UICollectionView!
    @IBOutlet weak var MyVideosCollection: UICollectionView!
    @IBOutlet weak var myPhotosHeight: NSLayoutConstraint!
    @IBOutlet weak var myvideosHieght: NSLayoutConstraint!
    @IBOutlet weak var addNewPhotos: UIButton!
    @IBOutlet weak var addNewVideos: UIButton!

    var images:[UserMedia]? = []
    var videos:[UserMedia]? = []
    let toArabic = ToArabic()
    var success = ErrorMsg()
    var FriendProfile = false
    let imagePicker = UIImagePickerController()
    var dataImage : [Data] = []
    var requested = false
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        GetProfileData()
        if FriendProfile {
            addNewPhotos.isHidden = true
            addNewVideos.isHidden = true
        }
    }
    
    @IBAction func NewPhotoBtn_pressed(_ sender: Any) {
        SelectImages()
    }
    
    @IBAction func NewVideoBtn_pressed(_ sender: Any) {
        SelectVideos()
    }
    func SelectImages()  {
        
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.albumButton.tintColor = UIColor.green
        imagePicker.cancelButton.tintColor = UIColor.red
        imagePicker.doneButton.tintColor = UIColor.purple
        imagePicker.doneButton.title = "Done"
        
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
            imagePicker.doneButton.title = "Done"
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
            imagePicker.doneButton.title = "Done"
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
            
            var counter = 0
            
            // prepare selected photos for uploading...... [UIImage TO DATA]
            self.dataImage.removeAll()
            for i in assets {
                
                PHImageManager.default().requestImage(for: i, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, info) in
                    
                    let degraded = info?[PHImageResultIsDegradedKey] as? Bool // To check if the real image (not the thunmbil) is choosen one
                    if degraded == nil || degraded == false {
                        self.dataImage.append((image?.jpegData(compressionQuality: 0.3))!)
                        counter+=1
                        if counter == assets.count {
                            self.UploadMedia(isImages: true)
                            return
                        }
                    }
                }
            }
        }, completion: {
            print("complete")
        })
    }
    
    // MARK: - ImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            dataImage = [pickedImage.jpegData(compressionQuality: 0.2)!]
            print("%%%%%%")
            print(dataImage)
            //self.UploadMedia(url: ApiManager.Apis.uploadUserMedia.description)
            
        }else {
            let chosenVideo = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            dataImage = [try! Data(contentsOf: chosenVideo, options: [])]
            // self.UploadMedia(url: ApiManager.Apis.uploadUserMedia.description, url2: chosenVideo)
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    func SelectVideos()  {
        
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.video]
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
            imagePicker.doneButton.title = "Done"
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
            imagePicker.doneButton.title = "Done"
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
            let counter = (assets.count) - 1
            print(counter)
            
            if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "en" {
                HUD.show(.label("Loading ..."), onView: self.view)
                
            }else if  UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
                HUD.show(.label("جار التحميل"), onView: self.view)
            }
            // prepare selected videos for uploading...... [VideoURL TO DATA]
            var counter_2 = 0
            self.dataImage.removeAll()
            for i in assets {
                PHImageManager.default().requestPlayerItem(forVideo: i, options: nil) { (avplayer, info) in
                    
                    let assetURL : AVURLAsset = avplayer?.asset as! AVURLAsset
                    guard let video_data = try? Data(contentsOf: assetURL.url) else {return}
                    print("video ^^^^^^^^=> \(video_data)")
                    let degraded = info?[PHImageResultIsDegradedKey] as? Bool // To check if the real image (not the thunmbil) is choosen one
                    if degraded == nil || degraded == false {
                        self.dataImage.append(video_data)
                        counter_2+=1
                        
                        if counter_2 == assets.count {
                            
                            self.UploadMedia(isImages: false)
                            return
                        }
                        
                    }
                }
            }
            
        }, completion: {
            print("completion")
        })
    }
    
}

// MARK: - CollectionViewDelegate
extension UserProfileGallaryVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == MyPhotosCollection {
//            if requested
//            {
//                if images?.count ?? 0 == 0 {
//                    myPhotosHeight.constant = 50
//                }else {
//                    collectionView.layoutIfNeeded()
//                    myPhotosHeight.constant = 350
//                }
//            }
            
            return images?.count ?? 0
        }
        
        
        if collectionView == MyVideosCollection {
//            if requested
//            {
//                if videos?.count ?? 0 == 0 {
//                    myvideosHieght.constant = 50
//                }else {
//                    collectionView.layoutIfNeeded()
//                    myvideosHieght.constant = 350
//                }
//            }
            return videos?.count ?? 0
        }
        
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == MyPhotosCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullImageCollCell", for: indexPath) as? FullImageCollCell {
                cell.UpdateView(image: images?[indexPath.row].path ?? "", video: false)
                return cell
            }
        }
        
        if collectionView == MyVideosCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullImageCollCell", for: indexPath) as? FullImageCollCell {
                cell.UpdateView(image: videos?[indexPath.row].path ?? "", video: false)
                return cell
            }
        }
        
        return FullImageCollCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == MyPhotosCollection || collectionView == MyVideosCollection {
            return CGSize(width: self.MyPhotosCollection.frame.width/3 , height: self.MyPhotosCollection.frame.height)
        }
        return CGSize()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 0 }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == MyVideosCollection {
            playVideo(url: URL(string: videos?[indexPath.row].path ?? "")!)
        }
        if collectionView == MyPhotosCollection {
            let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "SalonGalleryViewController") as! SalonGalleryViewController
            
            vc.selected_image = images?[indexPath.row].path ?? ""
            vc.selected_index = indexPath
            vc.Profile = true
            vc.ProfileAlbums  = images
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        self.present(vc, animated: true) { vc.player?.play() }
    }
}



// MARK: - API Requests
extension UserProfileGallaryVC {
    
    func GetProfileData() {
        HUD.show(.progress)
        let url = FriendProfile ? "\(ApiManager.Apis.UserProfile.description)\(userID)" : ApiManager.Apis.getUserGallery.description
        ApiManager.shared.ApiRequest(URL:  url, method: .get, Header: ["Authorization": "Bearer \(User.shared.TakeToken())",
            "Accept": "application/json",
            "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
                if tmp == nil {
                    HUD.hide()
                    do {
                        let decoded_data = try JSONDecoder().decode(Profile.self, from: data!)
                        if (self.FriendProfile){
                            self.videos = decoded_data.data?.user?.videos
                            self.images = decoded_data.data?.user?.images
                        }else{
                            self.videos = decoded_data.data?.videos
                            self.images = decoded_data.data?.images
                        }
                        self.MyPhotosCollection.reloadData()
                        self.MyVideosCollection.reloadData()
                        
                    }catch {
                        HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                    }
                }
        }
    }
    
    
    func UploadMedia(isImages : Bool){
        
        let url = ApiManager.Apis.uploadUserMedia.description
        
        if isImages {
            // HUD.show(.label("Uploading Media ..."), onView: self.view)
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            HUD.hide()
            
            var fileName = "image.jpeg"
            var mimeType = "image/jpeg"
            
            if (!isImages){
                fileName = "video.mp4"
                mimeType = "video/mp4"
            }
            
            for (index, item) in self.dataImage.enumerated() {
                multipartFormData.append(item, withName: "uploads[\(index)]", fileName: fileName, mimeType: mimeType)
                
                print("index multipart ==> \(index)")
            }
            
            
            
            print(multipartFormData)
            print(url)
            
        }, usingThreshold: UInt64.init(), to: url, method: .post , headers :
            [ "Authorization": "Bearer \(User.shared.TakeToken())","Accept": "application/json", "locale":UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ] )
        {
            
            
            (result) in
            switch result{
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    print(progress.fractionCompleted)
                    
                    let n = Float(progress.fractionCompleted)
                    //self.addPostController?.navigationController?.setProgress(n, animated: true)
                })
                
                upload.responseJSON { response in
                    if (response.response?.statusCode ?? 404) < 300{ //
                        
                        do {
                            self.success = try JSONDecoder().decode(ErrorMsg.self, from: response.data!)
                            HUD.flash(.label(self.success.msg?[0] ?? ""), onView: self.view, delay: 1.0, completion: nil)
                            if isImages {
                                self.GetProfileData()
                            }
                            
                        }catch {
                            HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                        }
                        
                    }else{
                        do {
                            let temp = try JSONDecoder().decode(ErrorMsg.self, from: response.data!)
                            HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                            HUD.hide()
                        }catch{
                            HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                        }
                    }
                    
                    if let err = response.error{
                        HUD.hide()
                        HUD.flash(.labeledError(title: "حدث خطأ", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                        print(err)
                        return
                    }
                    
                }
            case .failure(let error):
                HUD.flash(.labeledError(title: "حدث خطأ في رفع الصور", subtitle: nil), onView: self.view, delay: 1.0, completion: nil)
                print("Error in upload: \(error.localizedDescription)")
            }
        }
        
    }
}


