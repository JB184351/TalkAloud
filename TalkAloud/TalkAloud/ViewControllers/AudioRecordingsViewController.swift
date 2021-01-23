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
    private lazy var moreOptionsTransitioningDelegate = MoreOptionsPresentationManager()
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
//        recordingsTableView.rowHeight = 100
        recordingsTableView.reloadData()
    }
    
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
    private func loadAudioRecordings(with tagModel: [TagModel]?) {
        audioRecordings = AudioManager.sharedInstance.loadAudioRecordings(with: tagModel)!
        recordingsTableView.reloadData()
    }
    
    private func setupTableView() {
        recordingsTableView.dataSource = self
        recordingsTableView.delegate = self
        recordingsTableView.register(UINib(nibName: "AudioRecordingCell", bundle: nil), forCellReuseIdentifier: "AudioRecordingCell")
        recordingsTableView.register(UINib(nibName: "TagCell", bundle: nil), forCellReuseIdentifier: "TagCell")
        recordingsTableView.register(UINib(nibName: "TagCollectionViewTableViewCell", bundle: nil), forCellReuseIdentifier: "NewTagCell")
    }
    
}

//==================================================
// MARK: - Tag Filter Delegate
//==================================================

extension AudioRecordingsViewController: TagFilterDelegate {
    
    func didUpdateTagToFilter(with tag: TagModel) {
        AudioManager.sharedInstance.updateTagModel(with: tag)
        loadAudioRecordings(with: AudioManager.sharedInstance.getAllAudioRecordingTags())
    }
    
}

//==================================================
// MARK: - MoreOptions Delegate
//==================================================

extension AudioRecordingsViewController: MoreOptionsDelegate {
    
    func didDelete(selectedRecording: AudioRecording?) {
        guard let tags = selectedRecording?.tags else { return }
        
        AudioManager.sharedInstance.removeAudioRecording(with: selectedRecording!)
        AudioManager.sharedInstance.removeTagsFromTagModelDataSource(tags: tags)
        
        audioRecordings = AudioManager.sharedInstance.loadAudioRecordings()!
        self.recordingsTableView.reloadData()
    }
    
    func didAddTag(for selectedRecording: AudioRecording?) {
        self.recordingsTableView.reloadData()
    }
    
    func didRemoveTags(for recording: AudioRecording?) {
        guard let currentRecordingTags = recording?.tags else { return }
        
        AudioManager.sharedInstance.removeTag(for: recording!)
        AudioManager.sharedInstance.removeTagsFromTagModelDataSource(tags: currentRecordingTags)
        
        self.recordingsTableView.reloadData()
    }
    
    func didUpdateFileName(for selectedRecording: AudioRecording) {
        self.recordingsTableView.reloadData()
    }
    
}

//==================================================
// MARK: - AudioRecordingCell Delegate
//==================================================

extension AudioRecordingsViewController: AudioRecordingCellDelegate {
    
    func didTappedMoreButton(for cell: AudioRecordingCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let moreOptionsViewController = storyboard.instantiateViewController(identifier: "AudioRecodrdingOptionsViewController") as! MoreOptionsViewController
        
        moreOptionsViewController.delegate = self
        
        moreOptionsViewController.currentlySelectedRecording = audioRecordings[recordingsTableView.indexPath(for: cell)!.row]
        
        moreOptionsViewController.transitioningDelegate = moreOptionsTransitioningDelegate
        moreOptionsViewController.modalPresentationStyle = .custom
        
        self.navigationController?.present(moreOptionsViewController, animated: true)
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
        if indexPath.section == 0 {
            let tagCell = tableView.dequeueReusableCell(withIdentifier: "NewTagCell", for: indexPath) as! TagCollectionViewTableViewCell
            tagCell.updateTagCells()
            tagCell.delegate = self
            return tagCell
        }
        
        var currentAudio: AudioRecording
        currentAudio = audioRecordings[indexPath.row]
        
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
        
        let currentRecordingTags = AudioManager.sharedInstance.getTags(for: currentRecording)
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let deleteAlertController = UIAlertController(title: "Are you sure you want to delete?", message: "You won't be able to recover this file", preferredStyle: .alert)
            let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive, handler:  { _ in
                AudioManager.sharedInstance.removeAudioRecording(with: currentRecording)
                self.audioRecordings.remove(at: indexPath.row)
                AudioManager.sharedInstance.removeTagsFromTagModelDataSource(tags: currentRecordingTags)
                self.recordingsTableView.deleteRows(at: [indexPath], with: .none)
                self.recordingsTableView.reloadSections(IndexSet(integer: 0), with: .none)
            })
            
            let cancelDeleteAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            })
            
            deleteAlertController.addAction(deleteAlertAction)
            deleteAlertController.addAction(cancelDeleteAction)
            
            deleteAlertController.view.tintColor = .white
            deleteAlertController.overrideUserInterfaceStyle = .dark
            
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
            
            editAlertController.view.tintColor = .white
            editAlertController.overrideUserInterfaceStyle = .dark
            
            self.present(editAlertController, animated: true)
            
        }
        
        let tagAction = UIContextualAction(style: .normal, title: "Tag") { (action, view, completionHandler) in
            let tagAlertController = UIAlertController(title: "Edit Tag", message: nil, preferredStyle: .alert)
            tagAlertController.addTextField()
            
            let addTagAction = UIAlertAction(title: "Add", style: .default) { [unowned tagAlertController] action in
                let tagName = tagAlertController.textFields?[0].text
                
                if let tagName = tagName {
                    AudioManager.sharedInstance.setTag(for: currentRecording, tag: tagName)
                    let tagModel = TagModel(tag: tagName, isTagSelected: false)
                    AudioManager.sharedInstance.addTag(tagModel: tagModel)
                }
                
                self.recordingsTableView.reloadRows(at: [indexPath], with: .none)
                self.recordingsTableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            
            let cancelTagAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }
            
            let removeTagAction = UIAlertAction(title: "Remove Tags", style: .destructive) { (UIAlertAction) in
                AudioManager.sharedInstance.removeTagsFromTagModelDataSource(tags: currentRecordingTags)
                AudioManager.sharedInstance.removeTag(for: currentRecording)
                self.recordingsTableView.reloadRows(at: [indexPath], with: .none)
                self.recordingsTableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            
            tagAlertController.addAction(addTagAction)
            tagAlertController.addAction(removeTagAction)
            tagAlertController.addAction(cancelTagAction)
            
            tagAlertController.view.tintColor = .white
            tagAlertController.overrideUserInterfaceStyle = .dark
            
            self.present(tagAlertController, animated: true)
        }
        
        editAction.backgroundColor = .blue
        tagAction.backgroundColor = .systemTeal
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction, tagAction])
        return configuration
    }
    
}
