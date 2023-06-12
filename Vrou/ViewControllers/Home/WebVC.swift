//
//  WebVC.swift
//  BeautySalon
//
//  Created by MacBook Pro on 9/26/19.
//  Copyright © 2019 waysGroup. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController , WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var link = ""
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: link) ?? URL(string: "https://vrouapp.com/en")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
}



//
//extension WebVC {
//    
//
////    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
////
////        checkRequestForCallbackURL(request: request)
////    }
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        
//        checkRequestForCallbackURL()
//    }
//
//    func checkRequestForCallbackURL() -> Bool {
//            let requestURLString =  ""
//                //(request.url?.absoluteString)! as String
//            if requestURLString.hasPrefix(Instagram_API.INSTAGRAM_REDIRECT_URI) {
//                    let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
//                    handleAuth(authToken: requestURLString.substring(from: range.upperBound))
//                return false;
//        }
//                return true
//    }
//    
//    func handleAuth(authToken: String) {
//            print("Instagram authentication token ==", authToken)
//    }
//    
////    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void)
////    {
////        if(navigationAction.navigationType == .other)
////        {
////            if navigationAction.request.url != nil
////            {
////                //do what you need with url
////                self.delegate.openURL(url: navigationAction.request.url!)
////            }
////            decisionHandler(.cancel)
////            return
////        }
////        decisionHandler(.allow)
////    }
//    
//    
//}
