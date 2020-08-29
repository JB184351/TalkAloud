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
            print("Share")
        }
        
        let delete = MoreOptionsModel(title: "Delete", icon: nil) {
            self.deleteAction()
        }
        
        let editTag = MoreOptionsModel(title: "Edit Tag", icon: nil) {
            print("Editing Tags")
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
