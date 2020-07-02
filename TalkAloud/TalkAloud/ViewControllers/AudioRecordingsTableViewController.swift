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
        tableView.register(UINib(nibName: "AudioRecordingCell", bundle: nil), forCellReuseIdentifier: "audio")
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AudioManager.sharedInstance.loadAllRecordings()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioManager.sharedInstance.getAudioRecordingCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentAudio = AudioManager.sharedInstance.getRecordingForIndex(index: indexPath.row)
        
        let cellFileName = currentAudio.fileName
        let tagName = currentAudio.tags
        
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath) as! AudioRecordingCell
        audioCell.fileNameLabel?.text = cellFileName
        audioCell.tagLabel?.text = tagName
        
        
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
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let deleteAlertController = UIAlertController(title: "Are you sure you want to delete?", message: "You won't be able to recover this file", preferredStyle: .alert)
            let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive, handler:  { _ in
                AudioManager.sharedInstance.removeFile(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
            let cancelDeleteAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            })
            
            deleteAlertController.addAction(deleteAlertAction)
            deleteAlertController.addAction(cancelDeleteAction)
            self.present(deleteAlertController, animated: true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            let editAlertController = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
            editAlertController.addTextField()
            
            let renameFileAction = UIAlertAction(title: "Done", style: .default) { [unowned editAlertController] action in
                let newFileName = editAlertController.textFields?[0].text
                
                if let newFileName = newFileName {
                    let audioCell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath) as! AudioRecordingCell
                    audioCell.fileNameLabel?.text = newFileName
                    let errorMessage = AudioManager.sharedInstance.renameFile(at: indexPath.row, newFileName: newFileName)
                    
                    if errorMessage != nil {
                        let ac = UIAlertController(title: "Same File Name Exists Already!", message: errorMessage?.localizedDescription, preferredStyle: .alert)
                        let doneAction = UIAlertAction(title: "Done", style: .default)
                        ac.addAction(doneAction)
                        self.present(ac, animated: true)
                    }
                    
                    self.tableView.reloadData()
                }
                
            }
            
            let cancelEditAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            })
            
            editAlertController.addAction(renameFileAction)
            editAlertController.addAction(cancelEditAction)
            self.present(editAlertController, animated: true)
            
        }
        
        let tagAction = UIContextualAction(style: .normal, title: "Tag") { (action, view, completionHandler) in
            let tagAlertController = UIAlertController(title: "Edit Tag", message: nil, preferredStyle: .alert)
            tagAlertController.addTextField()
            
            let addTagAction = UIAlertAction(title: "Done", style: .default) { [unowned tagAlertController] action in
                let tagName = tagAlertController.textFields?[0].text
                
                let audioCell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath) as! AudioRecordingCell
                audioCell.tagLabel?.text = tagName
                AudioManager.sharedInstance.setTag(at: indexPath.row, tag: tagName ?? "")
                
                self.tableView.reloadData()
            }
            
            let cancelTagAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }
            
            tagAlertController.addAction(addTagAction)
            tagAlertController.addAction(cancelTagAction)
            self.present(tagAlertController, animated: true)
        }
        
        editAction.backgroundColor = .blue
        tagAction.backgroundColor = .systemTeal
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, tagAction])
        return configuration
    }
}

