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
    
    // Intialized AudioEngine object so properties and methods can be used for later
    var audioEngine = AudioEngine()
    
    @IBOutlet var playAudioButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .stopped {
            recordAudioButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            audioEngine.play()
        } else if audioEngine.audioState == .play {
            audioEngine.stop()
            recordAudioButton.isEnabled = true
            sender.setTitle("Play", for: .normal)
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .stopped {
            audioEngine.setupRecorder()
            sender.setTitle("Stop", for: .normal)
            do {
                try audioEngine.getAudioRecordingSession().setCategory(.playAndRecord, mode: .default)
                try audioEngine.getAudioRecordingSession().setActive(true)
                audioEngine.record()
            } catch {
                print("Failed to record")
            }
        } else if audioEngine.audioState == .record {
            sender.setTitle("Record", for: .normal)
            audioEngine.stop()
        }
    }
}
