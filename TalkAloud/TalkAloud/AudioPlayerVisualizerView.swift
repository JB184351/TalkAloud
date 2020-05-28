//
//  AudioPlayerVisualizer.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 5/23/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioPlayerVisualizerView: UIView {
    // Bar width
    var barWidth: CGFloat = 4.0
    // Indicate that waveform should draw active/inactive state
    var active = false {
        didSet {
            if self.active {
                self.color = UIColor.red.cgColor
            } else {
                self.color = UIColor.gray.cgColor
            }
        }
    }
    // Color for bars
    var color = UIColor.gray.cgColor
    // Given waveforms
    var waveforms: [Int] = Array(repeating: 0, count: 100)
    
    // MARK: - Init
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.backgroundColor = UIColor.clear
    }
    
    // MARK: - Draw bars
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0)
        context.fill(rect)
        context.setLineWidth(1)
        context.setStrokeColor(self.color)
        let width = rect.size.width
        let height = rect.size.height
        let t = Int(width / self.barWidth)
        let s = max(0, self.waveforms.count - t)
        let middle = height / 2
        let r = self.barWidth / 2
        let x = middle - r
        var bar: CGFloat = 0
        for i in s ..< self.waveforms.count {
            var v = height * CGFloat(self.waveforms[i]) / 50.0
            if v > x {
                v = x
            }
            else if v < 3 {
                v = 3
            }
            let oneX = bar * self.barWidth
            var oneY: CGFloat = 0
            let twoX = oneX + r
            var twoY: CGFloat = 0
            var twoS: CGFloat = 0
            var twoE: CGFloat = 0
            var twoC: Bool = false
            let threeX = twoX + r
            let threeY = middle
            if i % 2 == 1 {
                oneY = middle - v
                twoY = middle - v
                twoS = -180.degreesToRadians
                twoE = 0.degreesToRadians
                twoC = false
            }
            else {
                oneY = middle + v
                twoY = middle + v
                twoS = 180.degreesToRadians
                twoE = 0.degreesToRadians
                twoC = true
            }
            context.move(to: CGPoint(x: oneX, y: middle))
            context.addLine(to: CGPoint(x: oneX, y: oneY))
            context.addArc(center: CGPoint(x: twoX, y: twoY), radius: r, startAngle: twoS, endAngle: twoE, clockwise: twoC)
            context.addLine(to: CGPoint(x: threeX, y: threeY))
            context.strokePath()
            bar += 1
        }
    }

}

extension Int {
  var degreesToRadians: CGFloat {
    return CGFloat(self) * .pi / 180.0
  }
}
