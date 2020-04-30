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
    
    
    @IBOutlet var playAudioButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioEngine.sharedInstance.delegate = self
        recordAudioButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Doing this on ViewWillAppear because in the future
        // when I have the option to delete recording from the
        // Audio Player View I will know that this check will always
        // happen
        if AudioManager.sharedInstance.isArrayEmpty() {
            playAudioButton.isEnabled = false
        } else {
            playAudioButton.isEnabled = true
        }
        updateUI(audioState: AudioEngine.sharedInstance.audioState)
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .stopped {
            recordAudioButton.isEnabled = false
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            let playBackURL = AudioManager.sharedInstance.getPlayBackURL()
            AudioEngine.sharedInstance.play(withFileURL: playBackURL)
        } else if AudioEngine.sharedInstance.audioState == .playing {
            AudioEngine.sharedInstance.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            recordAudioButton.isEnabled = false
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .stopped {
            AudioEngine.sharedInstance.setupRecorder(fileURL: AudioManager.sharedInstance.getNewRecordingURL())
            sender.setImage(UIImage(named: "stopbutton"), for: .normal)
            playAudioButton.isEnabled = false
            AudioEngine.sharedInstance.record()
        } else if AudioEngine.sharedInstance.audioState == .recording {
            sender.setImage(UIImage(named: "recordbutton"), for: .normal)
            playAudioButton.isEnabled = true
            AudioEngine.sharedInstance.stop()
        }
    }
    
    private func updateUI(audioState: AudioEngineState) {
        switch audioState {
        case .stopped:
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAudioButton.isEnabled = true
        case .playing:
            playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            recordAudioButton.isEnabled = false
        case .recording:
            break
        }
    }
    
    @IBAction func skipForwardAction(_ sender: Any) {
        AudioEngine.sharedInstance.skipFifteenSeconds()
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        AudioEngine.sharedInstance.rewindFifteenSeonds()
    }
    
    func didUpdateAudioState(with audioState: AudioEngineState) {
        updateUI(audioState: audioState)
    }
}
