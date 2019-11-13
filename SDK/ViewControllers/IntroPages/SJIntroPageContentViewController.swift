//
//  SJIntroPageContentViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 11/13/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit

class SJIntroPageContentViewController: UIViewController {
    
    init(color: UIColor) {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
