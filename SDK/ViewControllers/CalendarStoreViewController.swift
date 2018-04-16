//
//  CalendarStoreViewController.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 02. 20..
//  Copyright © 2018. Balazs Vincze. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class CalendarStoreViewController: UINavigationController {
    
    // Set large title
    var largeTitle = true {
        didSet{
            if #available(iOS 11.0, *) {
                navigationBar.prefersLargeTitles = largeTitle
            }
        }
    }
    
    // Set tint color
    var tintColor = UIColor(red: 241/255.0, green: 102/255.0, blue: 103/255.0, alpha: 1){
        didSet{
            navigationBar.tintColor = tintColor
        }
    }
    
    // Initialize with an API Key page identifier and a title
    required init(apiKey: String, pageIdentifier: String?, title: String?) {
        super.init(nibName: nil, bundle: nil)
        
        // Set up Page View Controller
        let storyBoard = UIStoryboard.init(name: "SDK", bundle: nil)
        let pageVC = storyBoard.instantiateViewController(withIdentifier: "PagesViewController") as! PagesViewController
        pageVC.accessToken = apiKey
        pageVC.title = title
        pageVC.pageIdentifier = pageIdentifier
        viewControllers = [pageVC]
        
        // Customization
        navigationBar.tintColor = tintColor
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = largeTitle
        }
    }
    
    // Initialize with an API Key and a page identifier
    convenience init(apiKey: String, pageIdentifier: String?) {
        self.init(apiKey: apiKey, pageIdentifier: pageIdentifier, title: nil)
    }
    
    // Initialize with an API Key and a title
    convenience init(apiKey: String, title: String?) {
        self.init(apiKey: apiKey, pageIdentifier: nil, title: title)
    }
    
    // Initialize only with an API Key
    convenience init(apiKey: String) {
        self.init(apiKey: apiKey, pageIdentifier: nil, title: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
