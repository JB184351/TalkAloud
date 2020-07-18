//
//  TagTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 7/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol TagFilterDelegate: class {
    func didUpdateTagToFilter(by tags: [String])
}

class TagTableViewController: UITableViewController {
    
    weak var delegate: TagFilterDelegate?
    private var indexes = [Int]()
    private var selectedTags = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioManager.sharedInstance.getAllAudioRecordingTags() ?? []
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioManager.sharedInstance.getAllTagsCount()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentTag = AudioManager.sharedInstance.getTagForIndex(index: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingTags", for: indexPath)
        cell.textLabel?.text = currentTag
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.allowsMultipleSelection = true
        if let selectedCells = tableView.indexPathsForSelectedRows {
            for selectedCell in selectedCells {
                indexes.append(selectedCell.row)
            }
        }
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
        selectedTags = AudioManager.sharedInstance.getTagsForIndexes(indexes: indexes)
        
        if selectedTags.count >= 1 {
            self.delegate?.didUpdateTagToFilter(by: selectedTags)
            indexes.removeAll()
        } else {
            self.delegate?.didUpdateTagToFilter(by: [])
            indexes.removeAll()
        }
    }
    
}
