//
//  Extensions.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array where Element : Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}
