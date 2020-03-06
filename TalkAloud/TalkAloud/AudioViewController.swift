//
//  ViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 3/2/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    
    // Audio Engine class with these properties
    var audioEngine = AudioEngine()
    
    @IBOutlet var playAudioButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        // Use enum to determine state of audio of being playable
        if audioEngine.audioState == .none {
            audioEngine.audioState = .play
        }
        
        if audioEngine.audioState == .play {
            recordAudioButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            audioEngine.preparePlayer()
            audioEngine.audioPlayer.play()
            audioEngine.audioState = .stop
        } else if audioEngine.audioState == .stop {
            // Call Audio Engine .stop that will call these methods
            audioEngine.audioPlayer.stop()
            recordAudioButton.isEnabled = true
            sender.setTitle("Play", for: .normal)
            audioEngine.audioState = .none
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .none {
            audioEngine.audioState = .record
        }
    
        if audioEngine.audioState == .record {
            audioEngine.setupRecorder()
            sender.setTitle("Stop", for: .normal)
            do {
                try audioEngine.audioRecordingSession.setCategory(.playAndRecord, mode: .default)
                try audioEngine.audioRecordingSession.setActive(true)
                audioEngine.audioRecorder.record()
            } catch {
                print("Failed to record")
            }
            audioEngine.audioState = .stop
        } else if audioEngine.audioState == .stop {
            sender.setTitle("Record", for: .normal)
            audioEngine.audioRecorder.stop()
            audioEngine.audioState = .none
        }
    }
}

