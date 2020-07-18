//
//  AudioRecordingCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/1/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioRecordingCell: UITableViewCell {
    
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    
    func setup(with model: AudioRecording) {
        let cellFileName = model.fileName
        let tags = model.tags
        var allTags = ""
        
        if let tags = tags {
            for tag in tags {
                allTags += tag + ", "
            }
            
            allTags = allTags.trimmingCharacters(in: .whitespaces)
            
            if tags.isEmpty == false {
                allTags.removeLast()
            }
        }
        
        self.fileNameLabel?.text = cellFileName
        self.tagLabel?.text = allTags
    }
}
