//
//  TutorialPresenter.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/13/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

class TutorialPresenter: BasePresenter {
    var router: RouterManagerProtocol!
    var parentView: UIViewController!
    init(router: RouterManagerProtocol, parent: UIViewController) {
         self.router = router
        self.parentView  = parent
    }
    
    func openVideo(url:String){
        OpenVideoPlayer(vc :parentView, url : url)
    }
}

