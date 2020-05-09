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
    @IBOutlet var progressSlider: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var remainingTimeLabel: UILabel!
    private var progressTimer: Timer?
    private var isFirstRun = false  {
        didSet {
            updateUI(audioState: AudioEngine.sharedInstance.audioState)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstRun = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSlider()
        initializeTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .stopped {
            recordAudioButton.isEnabled = false
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            determinePlay()
        } else if AudioEngine.sharedInstance.audioState == .playing {
            AudioEngine.sharedInstance.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            recordAudioButton.isEnabled = true
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .stopped || AudioEngine.sharedInstance.audioState == .finished {
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
    
    @IBAction func skipForwardAction(_ sender: Any) {
        AudioEngine.sharedInstance.skipFifteenSeconds()
    }
    
    @IBAction func rewindAction(_ sender: Any) {
        AudioEngine.sharedInstance.rewindFifteenSeonds()
    }
    
    private func initializeTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let currentAudioDuration = AudioEngine.sharedInstance.getCurrentAudioDuration()
            let currentAudioTime = AudioEngine.sharedInstance.getCurrentAudioTime()
            let remainingAudioTime = currentAudioDuration - currentAudioTime
            
            self.progressSlider.value = currentAudioTime
            
            self.currentTimeLabel.text = self.timeToString(time: TimeInterval(currentAudioTime))
            self.remainingTimeLabel.text = self.timeToString(time: TimeInterval(remainingAudioTime))
        })
    }
    
    func timeToString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func setupSlider() {
        let maxValue = AudioEngine.sharedInstance.getCurrentAudioDuration()
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = maxValue
        progressSlider.value = 0
        resetDurationLabels()
    }
    
    private func resetDurationLabels() {
        currentTimeLabel.text = "0:00"
        remainingTimeLabel.text = "0:00"
    }
    
    private func updateUI(audioState: AudioEngineState) {
        switch audioState {
        case .stopped:
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAudioButton.isEnabled = true
            recordAudioButton.isEnabled = true
        case .playing:
            playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playAudioButton.isEnabled = true
            recordAudioButton.isEnabled = false
        case .recording:
            progressTimer?.invalidate()
            progressSlider.value = 0
            resetDurationLabels()
        case .finished:
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAudioButton.isEnabled = true
            recordAudioButton.isEnabled = true
            progressTimer?.invalidate()
            progressSlider.value = 0
            resetDurationLabels()
        }
    }
    
    func determinePlay() {
        if AudioEngine.sharedInstance.getCurrentAudioTime() > 0 {
            AudioEngine.sharedInstance.play()
        } else {
            guard let playBackURL = AudioManager.sharedInstance.getLatesRecording() else { return }
            AudioEngine.sharedInstance.setupAudioPlayer(fileURL: playBackURL)
            AudioEngine.sharedInstance.play()
            if progressSlider.value == 0 {
                setupSlider()
                initializeTimer()
            }
        }
    }
    
    func didUpdateAudioState(with audioState: AudioEngineState) {
        if isFirstRun {
            updateUI(audioState: audioState)
        }
    }
}
