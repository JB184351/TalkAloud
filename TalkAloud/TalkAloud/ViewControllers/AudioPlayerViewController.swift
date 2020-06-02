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
    @IBOutlet var progressSlider: AudioSlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var remainingTimeLabel: UILabel!
    @IBOutlet var audioPlayerVisualizer: AudioPlayerVisualizerView!
    private var progressTimer: Timer?
    private var recordTimer: Timer?
    private var isFirstRun = false  {
        didSet {
            updateUI(audioState: AudioEngine.sharedInstance.audioState)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstRun = true
        progressSlider.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSlider()
        initializeTimer()
        let playBackURL = AudioManager.sharedInstance.getPlayBackURL()
        
        if playBackURL == nil {
            playAudioButton.isEnabled = false
        }
        
        // This is for when after playing a recording and coming back to the
        // audioState the progresstimer doesn't initialize immediately.
        if AudioEngine.sharedInstance.audioState == .stopped {
            progressTimer?.invalidate()
            resetDurationLabels()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .paused || AudioEngine.sharedInstance.audioState == .stopped {
            recordAudioButton.isEnabled = false
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playURL()
        } else if AudioEngine.sharedInstance.audioState == .playing {
            AudioEngine.sharedInstance.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            recordAudioButton.isEnabled = true
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .paused || AudioEngine.sharedInstance.audioState == .stopped {
            AudioEngine.sharedInstance.setupRecorder(fileURL: AudioManager.sharedInstance.getNewRecordingURL())
            sender.setImage(UIImage(named: "stopbutton"), for: .normal)
            playAudioButton.isEnabled = false
            AudioEngine.sharedInstance.record()
            initializeRecordTimer()
        } else if AudioEngine.sharedInstance.audioState == .recording {
            sender.setImage(UIImage(named: "recordbutton"), for: .normal)
            playAudioButton.isEnabled = true
            AudioEngine.sharedInstance.stop()
            recordTimer?.invalidate()
            audioPlayerVisualizer.waveforms.removeAll()
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
    
    private func initializeRecordTimer() {
        recordTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true, block: { _ in
            AudioEngine.sharedInstance.updateMeters()
            let peakPower = AudioEngine.sharedInstance.getPeakPower()
            
            DispatchQueue.main.async {
                self.audioPlayerVisualizer.waveforms.append(min(30, Int(peakPower)))
                self.audioPlayerVisualizer.setNeedsDisplay()
            }
        })
    }
    
    func timeToString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format: "%2i:%02i", minutes, seconds)
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
    
    func playURL() {
        if AudioEngine.sharedInstance.getCurrentAudioTime() > 0 {
            AudioEngine.sharedInstance.play()
        } else {
            guard let playBackURL = AudioManager.sharedInstance.getLatestRecording() else { return }
            AudioEngine.sharedInstance.play(withFileURL: playBackURL)
            setupSlider()
            initializeTimer()
        }
    }
    
    private func updateUI(audioState: AudioEngineState) {
        switch audioState {
        // Changed stopped to pause
        case .paused:
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAudioButton.isEnabled = true
            recordAudioButton.isEnabled = true
            audioPlayerVisualizer.isHidden = false
            audioPlayerVisualizer.active = true
        case .playing:
            playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playAudioButton.isEnabled = true
            recordAudioButton.isEnabled = false
            audioPlayerVisualizer.active = true
            audioPlayerVisualizer.isHidden = false
        case .recording:
            progressTimer?.invalidate()
            progressSlider.value = 0
            resetDurationLabels()
            audioPlayerVisualizer.active = true
            audioPlayerVisualizer.isHidden = false
        case .stopped:
            audioPlayerVisualizer.active = false
            audioPlayerVisualizer.isHidden = true
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAudioButton.isEnabled = false
            recordAudioButton.isEnabled = true
            progressTimer?.invalidate()
            progressSlider.value = 0
            resetDurationLabels()
        }
    }
    
    
    func didUpdateAudioState(with audioState: AudioEngineState) {
        if isFirstRun {
            updateUI(audioState: audioState)
        }
    }
}

extension AudioPlayerViewController: AudioSliderDelegate {
    func didChangeScrolling(in audioSlider: UISlider) {
        AudioEngine.sharedInstance.setAudioTime(playBackTime: audioSlider.value)
        initializeTimer()
    }
}

