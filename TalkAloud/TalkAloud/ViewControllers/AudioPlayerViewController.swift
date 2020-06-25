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
    private var visualizerTimer: Timer?
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
        
        // Reset the visualizer in case we start playing
        // another recording in the middle of playing another recording
        audioPlayerVisualizer.waveforms.removeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
        visualizerTimer?.invalidate()
        // Added this here to avoid additional complexity of timers when
        // switching back between AudioRecordingsViewController and
        // the AudioPlayerViewController
        AudioEngine.sharedInstance.stop()
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
            guard let url = AudioManager.sharedInstance.getNewRecordingURL()?.url else { return }
            
            AudioEngine.sharedInstance.setupRecorder(fileURL: url)
            sender.setImage(UIImage(named: "stopbutton"), for: .normal)
            playAudioButton.isEnabled = false
            // Removing before recording in case we start recording while paused
            audioPlayerVisualizer.waveforms.removeAll()
            AudioEngine.sharedInstance.record()
            displayAudioVisualizer(audioState: AudioEngine.sharedInstance.audioState)
        } else if AudioEngine.sharedInstance.audioState == .recording {
            sender.setImage(UIImage(named: "recordbutton"), for: .normal)
            AudioEngine.sharedInstance.stop()
            playAudioButton.isEnabled = true
            audioPlayerVisualizer.waveforms.removeAll()
            visualizerTimer?.invalidate()
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
    
    private func displayAudioVisualizer(audioState: AudioEngineState) {
        visualizerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            AudioEngine.sharedInstance.updateMeters(audioState: audioState)
            let peakPower = AudioEngine.sharedInstance.getPeakPower(audioState: audioState)
            
            let positivePeakPower = abs(peakPower)
            var power: Float = 0.0
            
            if positivePeakPower <= 20 {
                power = (positivePeakPower + 10) / 2
            } else if positivePeakPower <= 1 {
                power = (positivePeakPower + 10) / 100
            } else {
                power = 0
            }
            
            DispatchQueue.main.async {
                self.audioPlayerVisualizer.waveforms.append(Int(power))
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
            visualizerTimer?.invalidate()
        case .playing:
            playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playAudioButton.isEnabled = true
            recordAudioButton.isEnabled = false
            audioPlayerVisualizer.active = true
            audioPlayerVisualizer.isHidden = false
            displayAudioVisualizer(audioState: audioState)
        case .recording:
            progressTimer?.invalidate()
            progressSlider.value = 0
            resetDurationLabels()
            audioPlayerVisualizer.active = true
            audioPlayerVisualizer.isHidden = false
        case .stopped:
            audioPlayerVisualizer.isHidden = true
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAudioButton.isEnabled = false
            recordAudioButton.isEnabled = true
            progressTimer?.invalidate()
            visualizerTimer?.invalidate()
            progressSlider.value = 0
            audioPlayerVisualizer.waveforms.removeAll()
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

