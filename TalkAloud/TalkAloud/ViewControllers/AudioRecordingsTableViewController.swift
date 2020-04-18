//
//  AudioRecordingsTableViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/16/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioRecordingsTableViewController: UITableViewController {
    
    let audioManager = AudioManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioManager.getAudioRecordingCount()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Whatever")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentAudio = audioManager.getSelectedRecording(selectedRecording: indexPath.row)
        
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath)
        audioCell.textLabel?.text = currentAudio.absoluteString
        return audioCell
    }

   

}
