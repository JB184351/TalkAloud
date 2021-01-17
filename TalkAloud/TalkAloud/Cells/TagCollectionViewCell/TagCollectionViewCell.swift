//
//  TagCollectionViewCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 11/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var roundedContainerView: UIView!
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    override func awakeFromNib() {
        roundedContainerView.backgroundColor = .blue
        roundedContainerView.addRoundedCorners(withBorder: false, andCornerRadius: 25.0)
    }
    
    public func setup(with model: TagModel) {
        tagLabel.text = model.tag
        
        if model.isTagSelected {
            self.backgroundColor = .red
        } else {
            self.backgroundColor = .darkGray
        }
        
    }
}
