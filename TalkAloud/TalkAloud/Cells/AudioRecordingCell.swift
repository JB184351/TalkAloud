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
            
            if !tags.isEmpty {
                allTags.removeLast()
            }
        }
        
        self.fileNameLabel?.text = cellFileName
        self.tagLabel?.text = allTags
    }
    
    @IBAction func moreButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let audioRecordingOptionViewControler = storyboard.instantiateViewController(identifier: "AudioRecodrdingOptionsViewController") as! AudioRecodrdingOptionsViewController
        
        // Don't have option to push view controller here how should I do it?
    }
    
}
