//
//  ArrayExtension.swift
//  iOS-SDK
//
//  Created by Alberto Huerdo on 2019. 01. 02..
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import Foundation

extension Array {
    
    func splitBy(size: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, self.count)])
        }
    }
    
}


extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
    
}
