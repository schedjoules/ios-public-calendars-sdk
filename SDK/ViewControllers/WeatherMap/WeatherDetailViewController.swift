//
//  WeatherDetailViewController.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 7/4/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import UIKit
import MapKit

class WeatherDetailViewController: UIViewController {

    init(annotation: MKAnnotation) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupProperties() {
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBottomBarWhenPushed = true
        view.backgroundColor = .white
    }

}
