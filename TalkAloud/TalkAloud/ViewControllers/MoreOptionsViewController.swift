//
//  MoreViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/22/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class MoreOptionsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var moreOptions = [MoreOptionsModel]()
    var currentlySelectedRecording: AudioRecording?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoreOptions")
        createMoreOptionModelObjects()
    }
    
    
    func createMoreOptionModelObjects() {
        let rename = MoreOptionsModel(title: "Rename", icon: nil) {
            self.renameAction()
        }
        
        let share = MoreOptionsModel(title: "Share", icon: nil) {
            self.shareAction()
        }
        
        let delete = MoreOptionsModel(title: "Delete", icon: nil) {
            self.deleteAction()
        }
        
        let editTag = MoreOptionsModel(title: "Edit Tag", icon: nil) {
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
            
            if let newFileName = newFileName {
                let errorMessage = AudioManager.sharedInstance.renameFile(with: self.currentlySelectedRecording!, newFileName: newFileName)
                
                if errorMessage != nil {
                    let ac = UIAlertController(title: "Same File Name Exists Already!", message: errorMessage?.localizedDescription, preferredStyle: .alert)
                    let doneAction = UIAlertAction(title: "Done", style: .default)
                    ac.addAction(doneAction)
                    self.present(ac, animated: true)
                }
            }
        }
        editAlertController.addAction(renameFileAction)
        present(editAlertController, animated: true)
    }
    
    private func shareAction() {
        let audioRecordingItem = [currentlySelectedRecording?.url]
        let ac = UIActivityViewController(activityItems: audioRecordingItem, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    private func deleteAction() {
        let deleteAlertController = UIAlertController(title: "Are you sure you want to delete?", message: "You won't be able to recover this file", preferredStyle: .alert)
        let deleteAlertAction = UIAlertAction(title: "Delete", style: .destructive, handler:  { _ in
            AudioManager.sharedInstance.removeAudioRecording(with: self.currentlySelectedRecording!)
        })
        let cancelDeleteAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        deleteAlertController.addAction(deleteAlertAction)
        deleteAlertController.addAction(cancelDeleteAction)
        self.present(deleteAlertController, animated: true)
    }
    
    private func editTagAction() {
        let tagAlertController = UIAlertController(title: "Edit Tag", message: nil, preferredStyle: .alert)
        tagAlertController.addTextField()
        
        let addTagAction = UIAlertAction(title: "Add", style: .default) { [unowned tagAlertController] action in
            let tagName = tagAlertController.textFields?[0].text
            
            if let tagName = tagName {
                AudioManager.sharedInstance.setTag(for: self.currentlySelectedRecording!, tag: tagName)
            }
        }
        
        let cancelTagAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let removeTagAction = UIAlertAction(title: "Remove Tags", style: .destructive) { (UIAlertAction) in
            AudioManager.sharedInstance.removeTag(for: self.currentlySelectedRecording!)
        }
        
        tagAlertController.addAction(addTagAction)
        tagAlertController.addAction(removeTagAction)
        tagAlertController.addAction(cancelTagAction)

        self.present(tagAlertController, animated: true)
    }
    
}

extension MoreOptionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreOptions")!
        
        cell.textLabel?.text = moreOptions[indexPath.row].title
        
        return cell
    }
    
    
}

extension MoreOptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        
        let currentOption = moreOptions[index].action
        
        currentOption()
    }
}
