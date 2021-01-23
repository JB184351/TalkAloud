//
//  NewTagCollectionViewCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 1/16/21.
//  Copyright © 2021 Justin Bengtson. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {

    @IBOutlet var roundedCotainerView: UIView!
    @IBOutlet var tagLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedCotainerView.addRoundedCorners()
    }
    
    public func setup(with model: TagModel) {
        tagLabel.text = model.tag
        roundedCotainerView.sizeThatFits(model.tag.size(withAttributes: nil))
        
        if model.isTagSelected {
            self.roundedCotainerView.backgroundColor = .gray
        } else {
            self.roundedCotainerView.backgroundColor = .darkGray
        }
        
    }

}
