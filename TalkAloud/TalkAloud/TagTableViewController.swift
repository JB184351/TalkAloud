//
//  TagTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class TagTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
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
        self.dismiss(animated: true) {
            if let audioRecordingsTableViewController = self.storyboard?.instantiateViewController(identifier: "AudioRecordingsTableViewController") as? AudioRecordingsTableViewController {
                let selectedTag = AudioManager.sharedInstance.getTagForIndex(index: indexPath.row)
                audioRecordingsTableViewController.isFiltered = true
                audioRecordingsTableViewController.filter(by: selectedTag)
            } else {
                print("Whoops!")
            }
            
        }
    }
}
