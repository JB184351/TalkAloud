//
//  MoreOptionsViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/22/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol MoreOptionsDelegate: class {
    func didDelete(selectedRecording: AudioRecording?)
    func didAddTag(for selectedRecording: AudioRecording?)
    func didRemoveTags(for selectedRecording: AudioRecording?)
    func didUpdateFileName(for selectedRecording: AudioRecording)
}

class MoreOptionsViewController: UIViewController {
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    public var currentlySelectedRecording: AudioRecording?
    public weak var delegate: MoreOptionsDelegate?
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    @IBOutlet private var tableView: UITableView!
    private var moreOptions = [MoreOptionsModel]()
        
    //==================================================
    // MARK: - Lifecycle Methods
    //==================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "MoreOptionsCell", bundle: nil), forCellReuseIdentifier: "MoreOptionsCell")
        createMoreOptionModelObjects()
    }
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
    private func createMoreOptionModelObjects() {
        let rename = MoreOptionsModel(title: "Rename", icon: "pencil.tip") {
            self.renameAction()
        }
        
        let share = MoreOptionsModel(title: "Share", icon: "square.and.arrow.up") {
            self.shareAction()
        }
        
        let delete = MoreOptionsModel(title: "Delete", icon: "trash") {
            self.deleteAction()
        }
        
        let editTag = MoreOptionsModel(title: "Edit Tag", icon: "tag") {
            self.editTagAction()
        }
        
        moreOptions.append(rename)
        moreOptions.append(editTag)
        moreOptions.append(share)
        moreOptions.append(delete)
    }
    
    
    
    private func renameAction() {
        let editAlertController = UIAlertController(title: "Change name", message: nil, preferredStyle: .alert)
        editAlertController.addTextField()
        
        let renameFileAction = UIAlertAction(title: "Done", style: .default) { [unowned editAlertController] action in
            let newFileName = editAlertController.textFields?[0].text
            
            if let newFileName = newFileName?.removeTrailingWhiteSpaces {
                var errorMessage: Error?
                
                if newFileName == "" || newFileName == " " {
                    errorMessage = nil
                } else {
                    errorMessage = AudioManager.sharedInstance.renameFile(with: self.currentlySelectedRecording!, newFileName: newFileName)
                }
                
                self.delegate?.didUpdateFileName(for: self.currentlySelectedRecording!)
                if errorMessage != nil {
                    let ac = UIAlertController(title: "Same File Name Exists Already!", message: errorMessage?.localizedDescription, preferredStyle: .alert)
                    let doneAction = UIAlertAction(title: "Done", style: .default)
                    ac.addAction(doneAction)
                    self.present(ac, animated: true)
                }
            }
        }
        
        let cancelRenameAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        editAlertController.addAction(renameFileAction)
        editAlertController.addAction(cancelRenameAction)
        
        editAlertController.view.tintColor = .white
        editAlertController.overrideUserInterfaceStyle = .dark
        
        present(editAlertController, animated: true)
    }
    
    private func shareAction() {
        let audioRecordingItem = [currentlySelectedRecording?.url]
        let ac = UIActivityViewController(activityItems: audioRecordingItem as [Any], applicationActivities: nil)
        ac.overrideUserInterfaceStyle = .dark
        present(ac, animated: true)
    }
    
    private func deleteAction() {
        let deleteAlertController = UIAlertController(title: "Are you sure you want to delete?", message: "You won't be able to recover this file", preferredStyle: .alert)
        let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive, handler:  { _ in
            self.dismiss(animated: true, completion: {
                self.delegate?.didDelete(selectedRecording: self.currentlySelectedRecording)
            })
        })
        
        let cancelDeleteAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        deleteAlertController.addAction(deleteAlertAction)
        deleteAlertController.addAction(cancelDeleteAction)
        
        deleteAlertController.view.tintColor = .white
        deleteAlertController.overrideUserInterfaceStyle = .dark
        
        self.present(deleteAlertController, animated: true)
    }
    
    private func editTagAction() {
        guard let currentRecordingTags = self.currentlySelectedRecording?.tags else { return }
        
        let tagAlertController = UIAlertController(title: "Edit Tag", message: "Blank tags will not be accepted", preferredStyle: .alert)
        tagAlertController.addTextField()
        
        let addTagAction = UIAlertAction(title: "Add", style: .default) { [unowned tagAlertController] action in
            guard let tagName = tagAlertController.textFields?[0].text?.removeTrailingWhiteSpaces else { return }
    
            if tagName.isEmpty || tagName.containsOnlyWhiteSpaces {
                self.editTagAction()
            }
    
            if !tagName.isEmpty && !tagName.containsOnlyWhiteSpaces {
                AudioManager.sharedInstance.setTag(for: self.currentlySelectedRecording!, tag: tagName)
                self.delegate?.didAddTag(for: self.currentlySelectedRecording)
            }
        }
        
        let cancelTagAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let removeTagAction = UIAlertAction(title: "Remove Tags", style: .destructive) { (UIAlertAction) in
            self.delegate?.didRemoveTags(for: self.currentlySelectedRecording!)
            // Added a dismiss here incase we are filtering
            // makes it clear that a new recording should be selected
            self.dismiss(animated: true)
        }
        
        if currentRecordingTags.count < 1 {
            removeTagAction.isEnabled = false
        }
        
        tagAlertController.addAction(addTagAction)
        tagAlertController.addAction(removeTagAction)
        tagAlertController.addAction(cancelTagAction)
        
        tagAlertController.view.tintColor = .white
        tagAlertController.overrideUserInterfaceStyle = .dark
            
        self.present(tagAlertController, animated: true)
    }
    
}

//==================================================
// MARK: - TableView DataSource
//==================================================

extension MoreOptionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moreOptionsCell = tableView.dequeueReusableCell(withIdentifier: "MoreOptionsCell", for: indexPath) as! MoreOptionsCell
        
        moreOptionsCell.moreOptionsLabel.text = moreOptions[indexPath.row].title
        moreOptionsCell.moreOptionsButton.setImage(UIImage(systemName: moreOptions[indexPath.row].icon!), for: .normal)
        
        return moreOptionsCell
    }
    
}

//==================================================
// MARK: - TableView Delegate
//==================================================

extension MoreOptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        let currentOption = moreOptions[index].action
        
        currentOption()
    }
    
}
