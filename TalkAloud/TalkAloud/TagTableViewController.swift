//
//  TagTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol TagFilterDelegate: class {
    func didUpdateTagToFilter(by tag: String)
}

class TagTableViewController: UITableViewController {
    
    weak var delegate: TagFilterDelegate?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let allTags = AudioManager.sharedInstance.getAllAudioRecordingTags() else { return 0 }
        return allTags.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentTag = AudioManager.sharedInstance.getTagForIndex(index: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingTags", for: indexPath)
        cell.textLabel?.text = currentTag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTag = AudioManager.sharedInstance.getTagForIndex(index: indexPath.row)
        self.delegate?.didUpdateTagToFilter(by: selectedTag)
        self.dismiss(animated: true)
    }
}
