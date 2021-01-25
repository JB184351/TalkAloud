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
    
    @IBOutlet private var fileNameLabel: UILabel!
    @IBOutlet private var tagLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
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
        
        fileNameLabel?.text = cellFileName.removeFileExtension
        durationLabel.text = AudioEngine.sharedInstance.getDuration(for: model.url).secondsToMinutes()
        
        if !allTags.isEmpty {
            tagLabel?.text = allTags
        } else {
            tagLabel?.text = model.creationDate.localDescription
        }
    }
    
}
