//
//  TagTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol TagFilterDelegate: class {
    func didUpdateTagToFilter(by tags: [String]?)
}

class TagTableViewController: UITableViewController {
    
    weak var delegate: TagFilterDelegate?
    private var selectedTags = [String]()
    private var allTags = AudioManager.sharedInstance.getAllAudioRecordingTags() ?? []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTag = allTags[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingTags", for: indexPath)
        cell.textLabel?.text = currentTag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTag = allTags[indexPath.row]
        selectedTags.append(selectedTag)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectedTag = allTags[indexPath.row]
        guard let tagToRemoveIndex = selectedTags.firstIndex(of: deselectedTag) else { return }
        selectedTags.remove(at: tagToRemoveIndex)
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        if selectedTags.count >= 1 {
            self.delegate?.didUpdateTagToFilter(by: selectedTags)
        } else {
            self.delegate?.didUpdateTagToFilter(by: nil)
        }
        
        self.dismiss(animated: true)
    }
    
}
