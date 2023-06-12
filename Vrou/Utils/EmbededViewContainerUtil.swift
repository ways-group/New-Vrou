//
//  File.swift
//  Vrou
//
//  Created by MacBook Pro on 12/2/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//


import UIKit

class EmbededViewContainerUtil {
    class func embed(
        parent:UIViewController,
        container:UIView,
        child:UIViewController,
        previous:UIViewController?){
        
        
        var is_exist = false
        
        
        //check if child exist
        parent.children.forEach { (child_vc) in
            if (child.title == child_vc.title){
                
                //child_vc.beginAppearanceTransition(true, animated: true)
                //parent.show(child_vc, sender: nil)
                child_vc.willMove(toParent: parent)
                container.addSubview(child_vc.view)
                child_vc.didMove(toParent: parent)
                print("????? \(container.subviews.count)")
                is_exist = true
                return
                
            }
        }
        // }
        if !is_exist {
            //else add child as new
            child.willMove(toParent: parent)
            parent.addChild(child)
            container.addSubview(child.view)
            child.didMove(toParent: parent)
            let w = container.frame.size.width;
            let h = container.frame.size.height;
            child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        }
    }
    
    class func removeFromParent(vc:UIViewController){
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        
        vc.viewDidAppear(false)
    }
    
    class func embed( vc_ : UIViewController , withIdentifier id:String,  parent:UIViewController, container:UIView) {
        
        embed(
            parent: parent,
            container: container,
            child: vc_,
            previous: parent.children.first
        )
    }
}
