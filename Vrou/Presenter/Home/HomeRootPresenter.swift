//
//  HomeRootPresenter.swift
//  Vrou
//
//  Created by Esraa Masuad on 4/9/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//
var firstOpen = true
 class HomeRootPresenter: BasePresenter {
    var router: RouterManagerProtocol!
    init(router: RouterManagerProtocol) {
         self.router = router
    }
    func goToLogin(){
        router.push(view: View.loginVC, presenter: BasePresenter.self, item: BaseItem())
    }
    
}
