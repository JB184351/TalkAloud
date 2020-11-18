//
//  TagCollectionViewCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 11/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var tagLabel: UILabel!
    
    public func setup(with model: TagModel) {
        tagLabel.text = model.tag
    }
}
