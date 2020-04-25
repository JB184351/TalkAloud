//
//  ViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 3/2/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController, AudioEngineStateChangeDelegate {
    
    // Intialized AudioEngine object so properties and methods can be used for later
    let audioEngine = AudioEngine()
    let audioManager = AudioManager.sharedInstance
    
    @IBOutlet var playAudioButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine.delegate = self
        recordAudioButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Doing this on ViewWillAppear because in the future
        // when I have the option to delete recording from the
        // Audio Player View I will know that this check will always
        // happen
        if audioManager.isArrayEmpty() {
            playAudioButton.isEnabled = false
        } else {
            playAudioButton.isEnabled = true
        }
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .stopped {
            recordAudioButton.isEnabled = false
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            let playBackURL = audioManager.getPlayBackURL()
            audioEngine.play(withFileURL: playBackURL)
        } else if audioEngine.audioState == .playing {
            audioEngine.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            recordAudioButton.isEnabled = false
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .stopped {
            audioEngine.setupRecorder(fileURL: audioManager.getNewRecordingURL())
            sender.setImage(UIImage(named: "stopbutton"), for: .normal)
            playAudioButton.isEnabled = false
            audioEngine.record()
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
