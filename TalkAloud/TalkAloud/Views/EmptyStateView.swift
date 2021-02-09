//
//  EmptyStateView.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 2/8/21.
//  Copyright © 2021 Justin Bengtson. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    //==================================================
    // MARK: - Setup
    //==================================================
    
    func setup() {
        backgroundColor = .red
    }
    
    //==================================================
    // MARK: - Life Cycle
    //==================================================
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //==================================================
    // MARK: - Layout
    //==================================================
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

