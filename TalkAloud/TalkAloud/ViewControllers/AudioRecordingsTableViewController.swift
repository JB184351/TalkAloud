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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioManager.sharedInstance.loadAllFiles()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioManager.sharedInstance.getAudioRecordingCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentAudio = AudioManager.sharedInstance.getRecordingForIndex(index: indexPath.row)
        
        let cellText = AudioManager.sharedInstance.getShortenedURL(audioRecording: currentAudio)
        let audioCell = tableView.dequeueReusableCell(withIdentifier: "audio", for: indexPath)
        audioCell.textLabel?.text = cellText
        return audioCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // setting to right recording
        AudioManager.sharedInstance.setSelectedRecording(index: indexPath.row)
        let url = AudioManager.sharedInstance.getPlayBackURL()
        AudioEngine.sharedInstance.setupAudioPlayer(fileURL: url!)
        AudioEngine.sharedInstance.play()
        
        
        self.tabBarController?.selectedIndex = 1
        
    }
}

