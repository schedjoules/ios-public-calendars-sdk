//
//  JSONLanguage.swift
//  ApiClient
//
//  Created by Balazs Vincze on 2018. 04. 02..
//  Copyright © 2018. SchedJoules. All rights reserved.
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

import Foundation

struct JSONLanguage: Localization {
    // Required properties
    let name: String
    let code: String
    let icon: URL?
}

// MARK: - Decodable protocol
extension JSONLanguage: Decodable {
    // JSON keys
    enum PageKeys: String, CodingKey {
        case name
        case code = "iso_639_1"
    }
    
    init(from decoder: Decoder) throws {
        // Get data container
        let container = try decoder.container(keyedBy: PageKeys.self)
        
        // Decode required properties
        let name = try container.decode(String.self, forKey: .name)
        let code = try container.decode(String.self, forKey: .code)
        
        self.init(name: name, code: code, icon: nil)
    }
}
