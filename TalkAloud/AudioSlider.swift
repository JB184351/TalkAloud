//
//  AudioSlider.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 5/12/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol AudioSliderDelegate: class {
    func didChangeScrolling(in audioSlider: UISlider)
    func didBeginScrolling(in audioSlider: UISlider)
    func didEndScrolling(in audioSlider: UISlider)
}

class AudioSlider: UISlider {
    
    weak var delegate: AudioSliderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTargets()
    }
    
    private func addTargets() {
        addTarget(self, action: #selector(didStartScrubbing(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        addTarget(self, action: #selector(didEndScrubbing(_:)), for: .valueChanged)
    }
    
    @objc private func didStartScrubbing(_ sender: UISlider) {
        delegate?.didBeginScrolling(in: sender)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        delegate?.didChangeScrolling(in: sender)
    }
    
    @objc private func didEndScrubbing(_ sender: UISlider) {
        delegate?.didEndScrolling(in: sender)
    }
    
    
    
}
