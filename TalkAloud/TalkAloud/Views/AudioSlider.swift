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
}

class AudioSlider: UISlider {
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    weak var delegate: AudioSliderDelegate?
    
    //==================================================
    // MARK: - Init Methods
    //==================================================
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTargets()
    }
    
    //==================================================
    // MARK: - Update Slider Methods
    //==================================================
    
    private func addTargets() {
        addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        delegate?.didChangeScrolling(in: sender)
    }

}
