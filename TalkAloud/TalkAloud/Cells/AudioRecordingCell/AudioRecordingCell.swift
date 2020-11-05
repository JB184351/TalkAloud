//
//  AudioRecordingCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/1/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol AudioRecordingCellDelegate: class {
    func didTappedMoreButton(for cell: AudioRecordingCell)
}

class AudioRecordingCell: UITableViewCell {
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    weak var delegate: AudioRecordingCellDelegate?
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    // Virgil: IBOutlets aren't private :) You can make them tho
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var tagLabel: UILabel!
    
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
    // Virgil: IBActions aren't private :) You can make them tho
    @IBAction private func moreButtonAction(_ sender: Any) {
        delegate?.didTappedMoreButton(for: self)
    }
    
    //==================================================
    // MARK: - Public Methods
    //==================================================
    
    public func setup(with model: AudioRecording) {
        let cellFileName = model.fileName
        let tags = model.tags
        var allTags = ""
        
        if let tags = tags {
            for tag in tags {
                allTags += tag + ", "
            }
            
            allTags = allTags.trimmingCharacters(in: .whitespaces)
            
            if !tags.isEmpty {
                allTags.removeLast()
            }
        }
        
        self.fileNameLabel?.text = cellFileName
        self.tagLabel?.text = allTags
    }
    
}
