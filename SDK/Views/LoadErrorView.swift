//
//  LoadErrorView.swift
//  iOS-SDK
//
//  Created by Balazs Vincze on 2018. 02. 21..
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

protocol LoadErrorViewDelegate: class {
    func refreshPressed()
}

class LoadErrorView: UIView {
    weak var delegate: LoadErrorViewDelegate?
    
    @IBAction func refresPressed(_ sender: UIButton) {
        delegate?.refreshPressed()
    }
    
    @IBOutlet weak var refreshButton: UIButton!{
        didSet{
            refreshButton.layer.borderColor = UIColor(red: 241/255.0, green: 102/255.0, blue: 103/255.0, alpha: 1).cgColor
            refreshButton.layer.cornerRadius = 4
            refreshButton.layer.borderWidth = 1
            refreshButton.layer.masksToBounds = true
        }
    }
}
