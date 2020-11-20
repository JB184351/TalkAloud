//
//  AudioRecordingsTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/16/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioRecordingsViewController: UIViewController {
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    private var audioRecordings = [AudioRecording]()
    private var tagModelDataSource = [TagModel]()
    @IBOutlet private var recordingsTableView: UITableView!
    
    //==================================================
    // MARK: - LifeCycle Methods
    //==================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioRecordings = AudioManager.sharedInstance.loadAudioRecordings(with: nil)!
        getAllTags()
        recordingsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove all tags so we don't get
        // duplicates in our datasource upon return
        tagModelDataSource.removeAll()
    }
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func tappedLeftButton(_ sender: Any) {
        presentTagTableViewController()
    }
    
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
    private func loadAudioRecordings(with tags: [String]?) {
        audioRecordings = AudioManager.sharedInstance.loadAudioRecordings(with: tags)!
        recordingsTableView.reloadData()
    }
    
    private func getAllTags() {
        let allTags = AudioManager.sharedInstance.getAllAudioRecordingTags()
        
        if let tags = allTags {
            for tag in tags {
                let tagModel = TagModel(tag: tag)
                tagModelDataSource.append(tagModel)
            }
        }
    }
    
    private func setupTableView() {
        recordingsTableView.dataSource = self
        recordingsTableView.delegate = self
        recordingsTableView.register(UINib(nibName: "AudioRecordingCell", bundle: nil), forCellReuseIdentifier: "AudioRecordingCell")
        recordingsTableView.register(UINib(nibName: "TagCell", bundle: nil), forCellReuseIdentifier: "TagCell")
    }
    
    private func presentTagTableViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tagFilterViewController = storyboard.instantiateViewController(identifier: "TagTableViewController") as! TagTableViewController
        let navigationController = UINavigationController(rootViewController: tagFilterViewController)
        tagFilterViewController.delegate = self
        self.present(navigationController, animated: true)
    }
    
}

//==================================================
// MARK: - Tag Filter Delegate
//==================================================

extension AudioRecordingsViewController: TagFilterDelegate {
    
    func didUpdateTagToFilter(by tags: [String]?) {
        loadAudioRecordings(with: tags)
    }
    
}

//==================================================
// MARK: - AudioRecordingCell Delegate
//==================================================

extension AudioRecordingsViewController: AudioRecordingCellDelegate {
    
    func didTappedMoreButton(for cell: AudioRecordingCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let audioRecordingOptionViewControler = storyboard.instantiateViewController(identifier: "AudioRecodrdingOptionsViewController") as! MoreOptionsViewController
        
        audioRecordingOptionViewControler.currentlySelectedRecording = audioRecordings[recordingsTableView.indexPath(for: cell)!.row]
        
        self.navigationController?.pushViewController(audioRecordingOptionViewControler, animated: true)
    }
    
}

//==================================================
// MARK: - TableView Data Source
//==================================================

extension AudioRecordingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return audioRecordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentAudio: AudioRecording
        currentAudio = audioRecordings[indexPath.row]
        
        if indexPath.section == 0 {
            let tagCell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as! TagCell
            tagCell.setup(with: tagModelDataSource)
            return tagCell
        }
        
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingCell", for: indexPath) as! AudioRecordingCell
        audioCell.setup(with: currentAudio)
        audioCell.delegate = self
        return audioCell
    }
    
}

//==================================================
// MARK: - TableView Delegate
//==================================================

extension AudioRecordingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // setting to right recording
        AudioManager.sharedInstance.setSelectedRecording(index: indexPath.row)
        guard let url = AudioManager.sharedInstance.getPlayBackURL() else { return }
        AudioEngine.sharedInstance.play(withFileURL: url)
        
        let selectedAudioRecording = audioRecordings[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let audioPlayerViewController = storyboard.instantiateViewController(identifier: "AudioPlayerViewController") as! PlayerViewController
        AudioEngine.sharedInstance.delegate = audioPlayerViewController
        audioPlayerViewController.currentAudioRecording = selectedAudioRecording
        self.navigationController?.pushViewController(audioPlayerViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentRecording = audioRecordings[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let deleteAlertController = UIAlertController(title: "Are you sure you want to delete?", message: "You won't be able to recover this file", preferredStyle: .alert)
            let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive, handler:  { _ in
                AudioManager.sharedInstance.removeAudioRecording(with: currentRecording)
                self.audioRecordings.remove(at: indexPath.row)
                self.recordingsTableView.deleteRows(at: [indexPath], with: .automatic)
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
                    let errorMessage = AudioManager.sharedInstance.renameFile(with: currentRecording, newFileName: newFileName)
                    
                    if errorMessage != nil {
                        let ac = UIAlertController(title: "Same File Name Exists Already!", message: errorMessage?.localizedDescription, preferredStyle: .alert)
                        let doneAction = UIAlertAction(title: "Done", style: .default)
                        ac.addAction(doneAction)
                        self.present(ac, animated: true)
                    }
                    
                    self.recordingsTableView.reloadRows(at: [indexPath], with: .automatic)
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
                    AudioManager.sharedInstance.setTag(for: currentRecording, tag: tagName)
                    let tagModel = TagModel(tag: tagName)
                    self.tagModelDataSource.append(tagModel)
                }
                
                self.recordingsTableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            let cancelTagAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }
            
            let removeTagAction = UIAlertAction(title: "Remove Tags", style: .destructive) { (UIAlertAction) in
                AudioManager.sharedInstance.removeTag(for: currentRecording)
                self.recordingsTableView.reloadRows(at: [indexPath], with: .automatic)
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
