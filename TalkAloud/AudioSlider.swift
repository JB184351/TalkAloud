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
        addTarget(self, action: #selector(sliderValueChanged(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        addTarget(self, action: #selector(sliderValueChanged(_:)), for: .editingDidEnd)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        delegate?.didBeginScrolling(in: sender)
    }
    
    
}
