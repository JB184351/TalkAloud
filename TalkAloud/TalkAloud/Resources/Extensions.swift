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

extension Int {
    
    func secondsToMinutes() -> String {
        let minutes = self / 60 % 60
        let seconds = self % 60
        
        return String(format: "%2i:%02i", minutes, seconds)
    }
    
}

extension TimeInterval {
    
    func timeToString() -> String {
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        
        return String(format: "%2i:%02i", minutes, seconds)
    }
    
}

// Make Date Extension to Human Readable Format.
extension Date {
    
    var localDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")
        
        let localeString = dateFormatter.string(from: self)
        return localeString
    }
    
}

// Used in AudioPlayerVisualizer Class
extension Int {
    
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
    
}

extension String {
    
    var removeFileExtension: String {
        
        if self.hasSuffix(".m4a") {
            return (self as NSString).deletingPathExtension
        }
        
        return self
    }
    
    var removeTrailingWhiteSpaces: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    var containsOnlyWhiteSpaces: Bool {
        for char in self {
            if char != " " {
                return false
            }
        }
        
        return true
    }
}

extension UIView {
    
    func addRoundedCorners(withBorder: Bool = true, andCornerRadius: CGFloat = 8.0) {
        layer.cornerRadius = andCornerRadius
        layer.masksToBounds = true
        layer.borderWidth = withBorder ? 2.0 : 0.0
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }
    
}

