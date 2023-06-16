//
//  HomeRootView.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import SideMenu
import XLPagerTabStrip

class HomeRootView: BaseButtonBarPagerTabStripViewController<HomeRootTabsCollectionViewCell> {
    
    var presenter : HomeRootPresenter!
    @IBOutlet weak var helloUser : Hi!
    @IBOutlet weak var myView: UIView!
   
    @IBAction func openSideMenu(_ button: UIButton){
        Vrou.openSideMenu(vc: self)
    }

    @IBAction func SearchBtn_pressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "CentersSearchNavController") as! CentersSearchNavController
        keyWindow?.rootViewController = vc
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "HomeRootTabsCollectionViewCell", bundle: Bundle(for: HomeRootTabsCollectionViewCell.self), width: { _ in
            return 4
        })
    }
    
    override func viewDidLoad() {
        settings.style.selectedBarBackgroundColor = .clear
        changeCurrentIndexProgressive = { [weak self] (oldCell: HomeRootTabsCollectionViewCell?, newCell: HomeRootTabsCollectionViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.oldCellConfigue()
            newCell?.newCellConfigure()
        }
         super.viewDidLoad()
        setCustomNavagationBar()
        presenter = HomeRootPresenter(router: RouterManager(self))
        helloUser.vc = self
        myView.layer.cornerRadius = 10
        myView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layoutIfNeeded()
    }
    override func viewWillAppear(_ animated: Bool) {
        setCustomNavagationBar()
        super.viewWillAppear(animated)
        if UserDefaults.standard.string(forKey: "Language") ?? "en" == "ar" {
        containerView.isScrollEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setCustomNavagationBar()
        super.viewDidAppear(animated)
         self.view.layoutIfNeeded()
    }

    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let vrouWorldView = View.vrouWorldView.identifyViewController(viewControllerType: VrouWorldView.self)
        let offersVC = View.offersVC.identifyViewController(viewControllerType: OffersVC.self)
        let homeServicesVC = View.HomeServicesVC.identifyViewController(viewControllerType: HomeServicesVC.self)
        let marketPlace = View.shopViewController.identifyViewController(viewControllerType: ShopViewController.self)
        return [vrouWorldView,  offersVC, homeServicesVC, marketPlace]
    }
    
    override func configure(cell: HomeRootTabsCollectionViewCell, for indicatorInfo: IndicatorInfo) {
        cell.icon_img.image = indicatorInfo.image
        cell.title_lbl.text = indicatorInfo.title?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged && toIndex > -1 && toIndex < viewControllers.count {
            let child = viewControllers[toIndex] as! IndicatorInfoProvider // swiftlint:disable:this force_cast
            UIView.performWithoutAnimation({ [weak self] () -> Void in
                guard let me = self else { return }
                me.navigationItem.leftBarButtonItem?.title =  child.indicatorInfo(for: me).title
            })
        }
    }
    
    override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
    }
}

