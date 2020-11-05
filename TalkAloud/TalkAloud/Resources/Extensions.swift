//
//  Extensions.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import UIKit

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

extension TimeInterval {
    
    func timeToString() -> String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        
        return String(format: "%2i:%02i", minutes, seconds)
    }
    
}

// Used in AudioPlayerVisualizer Class
extension Int {
    
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
    
}

