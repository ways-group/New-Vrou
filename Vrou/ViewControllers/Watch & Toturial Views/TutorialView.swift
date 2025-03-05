//
//  TutorialView.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//
import UIKit
import PKHUD
 
class TutorialView: BaseVC<TutorialPresenter, BaseItem> {

    @IBOutlet weak var noTutorialImage: UIImageView!
    @IBOutlet weak var noTutorialView: UIView!
    @IBOutlet weak var helloUser : Hi!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.register(UINib(nibName: "TutorialCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TutorialCollectionViewCell")
            collectionView.register(UINib(nibName: String(describing: LoadingCollectionViewCell.self), bundle: nil),forCellWithReuseIdentifier: String(describing: LoadingCollectionViewCell.self))
        }
    }
    var tutorialsList: [TutorialDetailsModel] = []
    var requested = false
    var uiSupport = UISupport()
    var toArabic = ToArabic()
    //pagination
    var has_more_pages = false
    var is_loading = false
    var current_page = 0
    override func viewDidLoad() {
        let offerImage = UIImage.gifImageWithName("Makeup artist")
        noTutorialImage.image = offerImage
        helloUser.vc = self
        setCustomNavagationBar()
        presenter = TutorialPresenter(router: RouterManager(self), parent: self)
        HUD.show(.progress)
        getData()
    }
    
    override func bindind() {
        helloUser.vc = self
        setCustomNavagationBar()
        presenter = TutorialPresenter(router: RouterManager(self), parent: self)
        HUD.show(.progress)
        getData()
    }
     @IBAction func openSideMenu(_ button: UIButton){
            Vrou.openSideMenu(vc: self)
     }
    @IBAction func SearchBtn_pressed(_ sender: Any) {
           let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
           keyWindow?.rootViewController = vc
       }
}
extension TutorialView {
    func getData() {
        var FinalURL = ""
        current_page += 1
        FinalURL = "\(ApiManager.Apis.getTutorials.description)?page=\(current_page)"
        ApiManager.shared.ApiRequest(URL: FinalURL, method: .get, Header:[ "Accept": "application/json","locale": UserDefaults.standard.string(forKey: "Language") ?? "en" , "timezone": TimeZoneValue.localTimeZoneIdentifier ], ExtraParams: "", view: self.view) { (data, tmp) in
            if tmp == nil {
                HUD.hide()
                self.is_loading = false
                do {
                    let data_ = try JSONDecoder().decode(TutorialGeneralModel.self, from: data!)
                    self.tutorialsList.append(contentsOf: (data_.data?.tutorials.data)!)
                    //get pagination data
                    let paginationModel = data_.pagination
                    self.has_more_pages = paginationModel?.has_more_pages ?? false
                    print("has_more_pages ==>\(self.has_more_pages)")
                    self.noTutorialView.isHidden = true
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                    if(self.tutorialsList.count == 0){
                        self.noTutorialView.isHidden = false
                        self.collectionView.isHidden = true
                    }
                }catch {
                    HUD.flash(.label("Something went wrong Please try again later") , onView: self.view , delay: 1.6 , completion: nil)
                }
            }else if tmp == "NoConnect" {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NoConnectionVC") as? NoConnectionVC else { return }
                vc.callbackClosure = { [weak self] in
                    self?.getData()
                }
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

extension TutorialView : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let pager = (tutorialsList.count >= 1) ? (has_more_pages ? 1 : 0): 0
        print("pager items num ==> \(pager)")
        return (tutorialsList.count) + pager
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row >= (tutorialsList.count)) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
            cell.loader.startAnimating()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TutorialCollectionViewCell", for: indexPath) as! TutorialCollectionViewCell
        let item = tutorialsList[indexPath.row]
        cell.configure(item: item)
        return cell
        
    }
    //check for pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row >= (tutorialsList.count) ){
            if has_more_pages && !is_loading {
                print("start loading")
                self.getData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let half_width = self.collectionView.frame.width/2
        let height:CGSize = CGSize(width: half_width , height: (half_width + 80))
        return height
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.openVideo(url: tutorialsList[indexPath.row].video ?? "")
    }
    
    
}
