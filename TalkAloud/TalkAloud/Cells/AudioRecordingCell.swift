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
    
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    weak var delegate: AudioRecordingCellDelegate?
    var selectedRecording: AudioRecording?
    
    func setup(with model: AudioRecording) {
        selectedRecording = model
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
    
    @IBAction func moreButtonAction(_ sender: Any) {
        delegate?.didTappedMoreButton(for: self)
    }
    
}
