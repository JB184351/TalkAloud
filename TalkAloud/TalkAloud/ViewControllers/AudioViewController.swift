//
//  ViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 3/2/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController, AudioEngineStateChangeDelegate {
    // Intialized AudioEngine object so properties and methods can be used for later
    var audioEngine = AudioEngine()
    var audioManager = AudioManager()
    var currentURL: URL!
    @IBOutlet var playAudioButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine.delegate = self
        recordAudioButton.isEnabled = true
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .stopped {
            recordAudioButton.isEnabled = false
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            let playBackURL = audioManager.getPlaybackURL()
            audioEngine.play(withFileURL: playBackURL!)
        } else if audioEngine.audioState == .playing {
            audioEngine.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            recordAudioButton.isEnabled = false
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .stopped {
            currentURL = audioManager.getNewRecordingURL()
            audioEngine.setupRecorder(fileURL: currentURL)
            sender.setImage(UIImage(named: "stopbutton"), for: .normal)
            playAudioButton.isEnabled = false
            audioEngine.record(toFileURL: currentURL)
        } else if audioEngine.audioState == .recording {
            sender.setImage(UIImage(named: "recordbutton"), for: .normal)
            playAudioButton.isEnabled = true
            audioEngine.stop()
        }
    }
    
    func didUpdateAudioState(with audioState: AudioEngineState) {
        if audioState == .stopped {
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            recordAudioButton.isEnabled = true
        }
    }
}
