//
//  AudioRecodrdingOptionsViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

struct MoreOptionsModel {
    var title: String?
    var icon: String?
    
    var action: () -> Void
}

class MoreOptionsViewConroller: UIViewController {

    @IBOutlet var moreOptionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        moreOptionsTableView.dataSource = self
        moreOptionsTableView.delegate = self
    }
    
    // ViewController should be driven by a model with name and icons

}

extension MoreOptionsViewConroller: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1 Rename
        // 2 Add Tag
        // 3 Share
        // 4 Delete
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Rename Cell"
            return cell
        case 1:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Add Tag"
            return cell
        case 2:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Share"
            return cell
        case 3:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Delete"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        switch row {
        case 0:
            print("Rename Cell")
        case 1:
            print("Add Tag")
        case 2:
            print("Share")
        case 3:
            print("Delete")
        default:
            return
        }
    }
}
