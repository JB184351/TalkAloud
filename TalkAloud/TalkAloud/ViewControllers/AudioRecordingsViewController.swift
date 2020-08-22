//
//  AudioRecordingsTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/16/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioRecordingsViewController: UIViewController {
    
    var isFiltered = false
    private var allAudioRecordings = AudioManager.sharedInstance.loadAllRecordings()
    private var filteredAudioRecordings = [AudioRecording]()
    @IBOutlet var recordingsTableView: UITableView!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingsTableView.dataSource = self
        recordingsTableView.delegate = self
        recordingsTableView.register(UINib(nibName: "AudioRecordingCell", bundle: nil), forCellReuseIdentifier: "AudioRecordingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isFiltered = false
        recordingsTableView.reloadData()
    }
    
    // MARK: - Public Methods
    
    func filter(by tags: [String]) {
        isFiltered = true
        filteredAudioRecordings = AudioManager.sharedInstance.filteredAudioRecordings(with: tags)
        recordingsTableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func tappedLeftButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tagFilterViewController = storyboard.instantiateViewController(identifier: "TagTableViewController") as! TagTableViewController
        let navigationController = UINavigationController(rootViewController: tagFilterViewController)
        tagFilterViewController.delegate = self
        self.present(navigationController, animated: true)
    }
    
    
}

extension AudioRecordingsViewController: TagFilterDelegate {
    func didUpdateTagToFilter(by tags: [String]?) {
        if let tags = tags {
            filter(by: tags)
        } else {
            isFiltered = false
            recordingsTableView.reloadData()
        }
    }
}

extension AudioRecordingsViewController: AudioRecordingCellDelegate {
    func didTappedMoreButton(for cell: AudioRecordingCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let audioRecordingOptionViewControler = storyboard.instantiateViewController(identifier: "AudioRecodrdingOptionsViewController") as! MoreOptionsViewController
        self.navigationController?.pushViewController(audioRecordingOptionViewControler, animated: true)
    }
    
}

extension AudioRecordingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return AudioManager.sharedInstance.filteredAudioRecordingsCount()
        } else {
            return AudioManager.sharedInstance.getAudioRecordingCount()
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentAudio: AudioRecording
        
        if isFiltered {
            currentAudio = AudioManager.sharedInstance.getFilteredRecordingForIndex(index: indexPath.row)
        } else {
           currentAudio = AudioManager.sharedInstance.getRecordingForIndex(index: indexPath.row)
        }
        
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingCell", for: indexPath) as! AudioRecordingCell
        audioCell.setup(with: currentAudio)
        audioCell.delegate = self
        return audioCell
    }
}
    
extension AudioRecordingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // setting to right recording
        AudioManager.sharedInstance.setSelectedRecording(index: indexPath.row)
        guard let url = AudioManager.sharedInstance.getPlayBackURL() else { return }
        AudioEngine.sharedInstance.play(withFileURL: url)
        
        let selectedAudioRecording = AudioManager.sharedInstance.getRecordingForIndex(index: indexPath.row)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let audioPlayerViewController = storyboard.instantiateViewController(identifier: "AudioPlayerViewController") as! PlayerViewController
        AudioEngine.sharedInstance.delegate = audioPlayerViewController
        audioPlayerViewController.currentAudioRecording = selectedAudioRecording
        self.navigationController?.pushViewController(audioPlayerViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
                    let errorMessage = AudioManager.sharedInstance.renameFile(at: indexPath.row, newFileName: newFileName)
                    
                    if errorMessage != nil {
                        let ac = UIAlertController(title: "Same File Name Exists Already!", message: errorMessage?.localizedDescription, preferredStyle: .alert)
                        let doneAction = UIAlertAction(title: "Done", style: .default)
                        ac.addAction(doneAction)
                        self.present(ac, animated: true)
                    }
                    
                    self.recordingsTableView.reloadData()
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
            
            let addTagAction = UIAlertAction(title: "Add", style: .default) { [unowned tagAlertController] action in
                let tagName = tagAlertController.textFields?[0].text
                
                if let tagName = tagName {
                    AudioManager.sharedInstance.setTag(at: indexPath.row, tag: tagName)
                }
                
                self.recordingsTableView.reloadData()
            }
            
            let cancelTagAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }
            
            let removeTagAction = UIAlertAction(title: "Remove Tags", style: .destructive) { (UIAlertAction) in
                AudioManager.sharedInstance.removeTag(at: indexPath.row)
                self.recordingsTableView.reloadData()
            }
            
            tagAlertController.addAction(addTagAction)
            tagAlertController.addAction(removeTagAction)
            tagAlertController.addAction(cancelTagAction)

            self.present(tagAlertController, animated: true)
        }
        
        editAction.backgroundColor = .blue
        tagAction.backgroundColor = .systemTeal
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, tagAction])
        return configuration
    }
}
