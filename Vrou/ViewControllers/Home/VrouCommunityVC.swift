//
//  VrouCommunityVC.swift
//  Vrou
//
//  Created by Mac on 1/7/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class VrouCommunityVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var galleryCollection: UICollectionView!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var PostsTable: UITableView!
    @IBOutlet weak var PostTxtView: UITextView!
    
    // Mark - Variables
    let imagePicker = UIImagePickerController()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PostTxtView.textColor = UIColor.lightGray
        PostTxtView.delegate = self
       
        
        PostsTable.delegate = self
        PostsTable.dataSource = self
        PostsTable.separatorStyle = .none
        
        SetUpCollectionView(collection: galleryCollection)
        
        imagePicker.delegate = self
        
        HeaderView.frame = CGRect(x: HeaderView.frame.origin.x, y: HeaderView.frame.origin.y, width: HeaderView.frame.width, height: 280) // OR 208 without GalleryCollectionView
        
    }
    
    func SetUpCollectionView(collection:UICollectionView){
        collection.delegate = self
        collection.dataSource = self
    }
    
    // MARK: - Photo/Video Button
    @IBAction func photoVideoBtn_pressed(_ sender: Any) {
        // To be Updated : add ActionSheet to choose between image OR video To handle multiple selection for images & single selection for video
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        present(imagePicker, animated: true, completion: nil)
    }
    
}


// MARK: - UIImagePickerDelegate
extension VrouCommunityVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // dataImage = [pickedImage.pngData()!]
            
        }
        
        //Submit(url: ApiManager.Apis.uploadImage.description)
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - TextViewDelegate
extension VrouCommunityVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What’s on your mind ?"
            textView.textColor = UIColor.lightGray
        }
    }
    
}

// MARK: - CollectionViewDelegate
extension VrouCommunityVC : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        if collectionView == CentersCollection {
//            return centerSearch.data?.count ?? 0
//        }
        
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == galleryCollection {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostMiniImageCollCell", for: indexPath) as? PostMiniImageCollCell {
                
                //cell.UpdateView(salon: centerSearch.data?[indexPath.row] ?? CenterSearchData())
                
                return cell
            }
        }
        
        return ForYouCollCell()
        
        
        
    }
    
    
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        if collectionView == galleryCollection {
//
//            let height:CGSize = CGSize(width: self.CentersCollection.frame.width , height: CGFloat(90))
//
//            return height
//        }
//
//        return CGSize()
//
//    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//
//
//        return 0;
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//
//        return 0
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if collectionView == CentersCollection {
//            let salon_id = centerSearch.data?[indexPath.row].id ?? 0
//            NavigationUtils.goToSalonProfile(from: self, salon_id: salon_id)
//
//        }
        
    }
    
    
}



// MARK: - TableViewDelegate
extension VrouCommunityVC: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return serviceSearch.data?.count ?? 0
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ComunityPostTableCell", for: indexPath) as? ComunityPostTableCell {
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            // cell.UpdateView(service: serviceSearch.data?[indexPath.row] ?? ServiceSearchData())
            return cell
        }
        
        return CenterServicesTableCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let vc = UIStoryboard(name: "Center", bundle: nil).instantiateViewController(withIdentifier: "ReservationVC") as! ReservationVC
        //        vc.ServiceID = "\(serviceSearch.data?[indexPath.row].id ?? Int())"
        //        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
}

