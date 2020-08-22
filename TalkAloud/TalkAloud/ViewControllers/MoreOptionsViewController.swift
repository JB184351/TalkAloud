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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoreOptions")
        createMoreOptionModelObjects()
    }
    

    func createMoreOptionModelObjects() {
        let rename = MoreOptionsModel(title: "Rename", icon: nil) {
            print("Rename")
        }
        
        let share = MoreOptionsModel(title: "Share", icon: nil) {
            print("Share")
        }
        
        let delete = MoreOptionsModel(title: "Delete", icon: nil) {
            print("Delete")
        }
        
        let editTag = MoreOptionsModel(title: "Editt Tag(s)", icon: nil) {
            print("Editing Tags")
        }
        
        moreOptions.append(rename)
        moreOptions.append(editTag)
        moreOptions.append(share)
        moreOptions.append(delete)
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
