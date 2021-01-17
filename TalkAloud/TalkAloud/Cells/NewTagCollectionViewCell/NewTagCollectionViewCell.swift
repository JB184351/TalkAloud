//
//  NewTagCollectionViewCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 1/16/21.
//  Copyright © 2021 Justin Bengtson. All rights reserved.
//

import UIKit

class NewTagCollectionViewCell: UICollectionViewCell {

    @IBOutlet var roundedCotainerView: UIView!
    @IBOutlet var tagLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedCotainerView.addRoundedCorners()
    }
    
    public func setup(with model: TagModel) {
        tagLabel.text = model.tag
        
        if model.isTagSelected {
            self.roundedCotainerView.backgroundColor = .red
        } else {
            self.roundedCotainerView.backgroundColor = .darkGray
        }
        
    }

}
