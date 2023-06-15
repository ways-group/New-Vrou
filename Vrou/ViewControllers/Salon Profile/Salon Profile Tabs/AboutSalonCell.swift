//
//  AboutSalonCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/22/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

 
import UIKit

class AboutSalonCell: UITableViewCell {
   //outlet
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var rootCollectionView: UICollectionView!{
        didSet{
            self.rootCollectionView.register(UINib(nibName: String(describing: SalonFeaturesCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SalonFeaturesCell.self))
            self.rootCollectionView.register(UINib(nibName: String(describing: ServicesCollCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ServicesCollCell.self))
        }
    }
    //data
    var currentCellType = 0
    var top_and_bottom_adsList:[Ad]?

    var main_ads : MainAd?
    var tutorials: [TutorialDetailsModel]?
    var in_store: [Product]?
    var specialist: [Employee]? = []
    var gallery_list: [SalonAlbum]? = []
    var videos_list: [SalonAlbum]? = []
    var features_list: [SalonFeatures]? = []
    var parentView: AboutSalonView!
    var router: RouterManagerProtocol!
    
    func configure(info: (id:Int, title:String)){
        rootCollectionView.delegate = self
        rootCollectionView.dataSource = self
        title_lbl.text = info.title
        currentCellType = info.id
        specialist  = parentView.specialist
        gallery_list = parentView.gallery_list
        videos_list = parentView.videos_list
        features_list = parentView.features_list
        rootCollectionView.reloadData()
        router = RouterManager(parentView)
        
        var min = 3
        switch currentCellType {
        case 2: min = 4
        case 3: min = 6
        default: min = 3
        }

        ToArabic().ReverseCollectionDirection_2(collectionView: rootCollectionView , MinCellsToReverse: min)
    }
}

extension AboutSalonCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentCellType {
        case 0:
            return gallery_list?.count ?? 0
        case 1:
            return videos_list?.count ?? 0
        case 2:
            return specialist?.count ?? 0
        case 3:
            return features_list?.count ?? 0
        default:
            return 0
        }
     }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if currentCellType == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SalonFeaturesCell.self), for: indexPath) as! SalonFeaturesCell
            cell.configure(item: features_list?[indexPath.row])
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ServicesCollCell.self), for: indexPath) as! ServicesCollCell
        currentCellType == 0 ? cell.setAlbum(item: gallery_list?[indexPath.row]) : (currentCellType == 1) ?
            cell.setAlbum(item: videos_list?[indexPath.row]) :
            cell.setSpecialist(item: specialist?[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentCellType {
        case 2: return CGSize(width: self.contentView.bounds.width/3.2, height: 150)
        case 3: return CGSize(width: self.contentView.bounds.width/5, height: 50)
        default: return CGSize(width: self.contentView.bounds.width/2.2, height: 150)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 0
       }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentCellType {
        case 0:
            openAlbum(item: gallery_list?[indexPath.row])
        case 1:
            openAlbum(item: videos_list?[indexPath.row])
        default:
           break
        }
    }
    
    func openAlbum(item: SalonAlbum?){
        let vc =  View.salonAlbumVC.identifyViewController(viewControllerType: SalonAlbumVC.self)
        vc.album_id = "\(item?.id ?? 0)"
        vc.type = item?.type ?? ""
        router.push(controller: vc)
    }
}
