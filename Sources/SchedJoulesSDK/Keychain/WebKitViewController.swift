//
//  WebKitViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 4/29/20.
//  Copyright © 2020 SchedJoules. All rights reserved.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController {
    var webView: WKWebView!
    let url: URL
    
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension WebKitViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("did finish")
    }
}


extension WebKitViewController: WKUIDelegate {
    
}
