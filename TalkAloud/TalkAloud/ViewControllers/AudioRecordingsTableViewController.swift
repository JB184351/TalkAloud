//
//  AudioRecordingsTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/16/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioRecordingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioManager.sharedInstance.loadAllFiles()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioManager.sharedInstance.getAudioRecordingCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentAudio = AudioManager.sharedInstance.getRecordingForIndex(index: indexPath.row)
        
        let cellText = AudioManager.sharedInstance.getShortenedURL(audioRecording: currentAudio)
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath)
        audioCell.textLabel?.text = cellText
        return audioCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // setting to right recording
        AudioManager.sharedInstance.setSelectedRecording(index: indexPath.row)
        guard let url = AudioManager.sharedInstance.getPlayBackURL() else { return }
        AudioEngine.sharedInstance.play(withFileURL: url)
        self.tabBarController?.selectedIndex = 1
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath)
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            AudioManager.sharedInstance.removeFile(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            let ac = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
            ac.addTextField()
            
            let renameCellAction = UIAlertAction(title: "Done", style: .default) { [unowned ac] action in
                let newCellName = ac.textFields?[0].text
                
                if let newCellName = newCellName {
                    audioCell.textLabel?.text = newCellName
                    AudioManager.sharedInstance.renameFile(at: indexPath.row, newURL: newCellName)
                    self.tableView.reloadData()
                }
            }
            
            ac.addAction(renameCellAction)
            self.present(ac, animated: true)
            
        }
        
        editAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
    
}

