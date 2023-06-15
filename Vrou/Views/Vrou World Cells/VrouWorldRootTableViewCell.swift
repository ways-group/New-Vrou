//
//  VrouWorldRootTableViewCell.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/18/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit

class VrouWorldRootTableViewCell: UITableViewCell {
   //outlet
    @IBOutlet weak var title_lbl: UILabel!
    @IBOutlet weak var viewAll_btn: UIButton!
    @IBOutlet weak var rootCollectionView: UICollectionView!{
        didSet{
            self.rootCollectionView.register(UINib(nibName: String(describing: SponsorsSliderCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SponsorsSliderCollectionViewCell.self))
            self.rootCollectionView.register(UINib(nibName: String(describing: TutorialCollectionViewCell.self), bundle: nil),forCellWithReuseIdentifier: String(describing: TutorialCollectionViewCell.self))
            self.rootCollectionView.register(UINib(nibName: String(describing: TitleAndDescriptionCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: TitleAndDescriptionCollectionViewCell.self))
            self.rootCollectionView.register(UINib(nibName: String(describing: BuyProductCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: BuyProductCollectionViewCell.self))
            self.rootCollectionView.register(UINib(nibName: String(describing: ServiceReservationCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ServiceReservationCollectionViewCell.self))
        }
    }
    //data
    var currentCellType = 0
//    var top_ads : [Ad]?
//    var bottom_ads:[Ad]?
    var top_and_bottom_adsList:[Ad]?

    var main_ads : MainAd?
   // var categories : [Category]?
    var tutorials: [TutorialDetailsModel]?
    var in_store: [Product]?
    
    var allSalonsList: [Salon]?
    var beauty_center_category_id :Int?
    var salon_category_id: Int?
    var spa_category_id:Int?
    var makeup_artists_category_id: Int?
    var specialists_category_id: Int?
    var stores_category_id: Int?
    var parentView: UIViewController!
    var router: RouterManagerProtocol!
    
    func configure(info: (id:Int, title:String, viewall:Bool)){
        rootCollectionView.delegate = self
        rootCollectionView.dataSource = self
        title_lbl.text = info.title
        viewAll_btn.isHidden = !info.viewall
        currentCellType = info.id
        rootCollectionView.reloadData()
        router = RouterManager(parentView)
    
        var min = 3
        switch currentCellType {
        case 9, 3:
            min =  2
        default:
            min = 3
        }
        ToArabic().ReverseCollectionDirection_2(collectionView: rootCollectionView, MinCellsToReverse: min)
    }
    @IBAction func viewAll(_ button: UIButton){
        print("view all")
        switch currentCellType {
        case 1:
            globalValues.sideMenu_selected = 3 //to select toturial txt in side menu
            router.push(view: .tutorialView, presenter: TutorialPresenter.self, item: BaseItem())
        case 4:
            globalValues.sideMenu_selected = 4
            NavigationUtils.goto_specificViewByIdentifier(from: parentView, identifier: NavigationUtils.shop_vc)
        default://remember to send category id
             globalValues.sideMenu_selected = 1
            router.push(view: .centerViewController, presenter: BasePresenter.self, item: BaseItem())
        }
    }
}

extension VrouWorldRootTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentCellType {
        case 0,9:
            return top_and_bottom_adsList?.count ?? 0
        case 5:
            return 1
        case 1:
            return tutorials?.count ?? 0
        case 4:
            return in_store?.count ?? 0
        default:
            return allSalonsList?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch currentCellType {
        case 0,5,9:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SponsorsSliderCollectionViewCell.self), for: indexPath) as! SponsorsSliderCollectionViewCell
            (currentCellType == 5 ) ? cell.configureMainAds(item: main_ads ?? MainAd()) : cell.configure(item: top_and_bottom_adsList?[indexPath.row] ?? Ad())
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TutorialCollectionViewCell.self), for: indexPath) as! TutorialCollectionViewCell
            cell.configure(item: (tutorials?[indexPath.row])!)
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ServiceReservationCollectionViewCell.self), for: indexPath) as! ServiceReservationCollectionViewCell
            cell.UpdateView(salon: allSalonsList?[indexPath.row])
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BuyProductCollectionViewCell.self), for: indexPath) as! BuyProductCollectionViewCell
            cell.configure(product: in_store?[indexPath.row])
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TitleAndDescriptionCollectionViewCell.self), for: indexPath) as! TitleAndDescriptionCollectionViewCell
            cell.configure(item: allSalonsList?[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.contentView.bounds.width/2.75, height: (collectionView.bounds.height*0.9))
        switch currentCellType {
        case 0://top ads
            return  CGSize(width: self.contentView.bounds.width/2.5, height:  200)
        case 1://tutorial
            let width = self.contentView.bounds.width/2.75
            return  CGSize(width: width, height:  (width + 80))
        case 9://bottom ads
            return  CGSize(width: self.contentView.bounds.width/1.5, height: collectionView.bounds.height)
        case 5://main ads
            return CGSize(width: (self.contentView.bounds.width - 20), height: collectionView.bounds.height)
        case 3: //service reservation & store
            return  CGSize(width: self.contentView.bounds.width/1.7, height: contentView.bounds.height*0.9)
        case 4: //service reservation & store
            return  CGSize(width: self.contentView.bounds.width/2.2, height: collectionView.bounds.height)
        default:
            return size
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
        case 0,9://top & bottom ads
            let item = top_and_bottom_adsList?[indexPath.row]
            OpenAdsOrSalonProfile(item)
           break
        case 5://main ad
            goToSingleOffer()
        case 1:
            OpenVideoPlayer(vc :parentView, url : tutorials?[indexPath.row].video ?? "")
        case 4:
            goToProductDetails(in_store?[indexPath.row])
        default:
            NavigationUtils.goToSalonProfile(from: parentView, salon_id: allSalonsList?[indexPath.row].id ?? 0)
            break
        }
    }
    
    func OpenAdsOrSalonProfile(_ item: Ad?) {
        if item?.link_type == "1" {
            let vc =  View.webVC.identifyViewController(viewControllerType: WebVC.self)
            vc.link = item?.link ?? ""
            parentView.navigationController?.pushViewController(vc, animated: true)
        }
        else if item?.link_type == "2" {
            let salon_id = Int(item?.salon_id ?? "0") ?? 0
            NavigationUtils.goToSalonProfile(from: parentView, salon_id: salon_id)
        }
    }
    func goToSingleOffer(){
        let vc = View.singleOfferVC.identifyViewController(viewControllerType: SingleOfferVC.self)
        vc.link = main_ads?.link ?? ""
        vc.image = main_ads?.image ?? ""
        parentView.navigationController?.pushViewController(vc, animated: true)
    }
    func goToProductDetails(_ item: Product?){
        let vc = View.OfferVC.identifyViewController(viewControllerType: OfferVC.self)
        vc.productID = "\(item?.id ?? 0)"
        parentView.navigationController?.pushViewController(vc, animated: true)
    }
}
