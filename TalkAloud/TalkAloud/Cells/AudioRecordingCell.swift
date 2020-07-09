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
    
    func configureAudioRecordingCell(currentAudioRecording: AudioRecording) {
        let cellFileName = currentAudioRecording.fileName
        let tags = currentAudioRecording.tags
        var allTags = ""
        
        if let tags = tags {
            for tag in tags {
                allTags += tag + ", "
            }
            allTags.removeFirst()
            
            allTags = allTags.trimmingCharacters(in: .whitespaces)
            
            if tags.count > 1 {
                allTags.removeLast()
            }
        }
        
        self.fileNameLabel?.text = cellFileName
        self.tagLabel?.text = allTags
    }
}
