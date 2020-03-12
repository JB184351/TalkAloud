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
            sender.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            audioEngine.play()
        } else if audioEngine.audioState == .playing {
            audioEngine.stop()
            recordAudioButton.isEnabled = true
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if audioEngine.audioState == .stopped {
            audioEngine.setupRecorder()
            sender.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            audioEngine.record()
        } else if audioEngine.audioState == .recording {
            sender.setImage(UIImage(systemName: "recordingtape"), for: .normal)
            audioEngine.stop()
        }
    }
}
