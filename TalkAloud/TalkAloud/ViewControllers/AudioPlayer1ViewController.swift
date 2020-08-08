//
//  AudioPlayer1ViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/4/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioPlayer1ViewController: UIViewController, AudioEngineStateChangeDelegate {
    
    
    @IBOutlet var audioPlayerVisualizer: AudioPlayerVisualizerView!
    @IBOutlet var audioRecordingNameLabel: UILabel!
    @IBOutlet var audioRecordingDetailLabel: UILabel!
    @IBOutlet var audioRecordingMoreOptionButton: UIButton!
    @IBOutlet var progressSlider: AudioSlider!
    @IBOutlet var audioPlayerCurrentTimeLabel: UILabel!
    @IBOutlet var audioPlayerRemainingTimeLabel: UILabel!
    @IBOutlet var goBackFifteenSecondsButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var goForwardFifteenSecondsButton: UIButton!
    private var progressTimer: Timer?
    private var visualizerTimer: Timer?
    var audioRecordingName: String?
    var audioRecordingDetail: String?
    private var isAudioPlaying = false {
        didSet {
            updateUI(audioState: AudioEngine.sharedInstance.audioState)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressSlider.delegate = self
        self.audioRecordingNameLabel.text = audioRecordingName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAudioPlaying = true
        setupSlider()
        initializeTimer()
        audioPlayerVisualizer.waveforms.removeAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
        visualizerTimer?.invalidate()
        
        AudioEngine.sharedInstance.stop()
    }
    
    @IBAction func playAndPauseButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .paused {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            play()
        } else if AudioEngine.sharedInstance.audioState == .playing {
            AudioEngine.sharedInstance.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func rewindAction(_ sender: Any) {
        AudioEngine.sharedInstance.rewindFifteenSeonds()
    }
    
    @IBAction func skipForwardAction(_ sender: Any) {
        AudioEngine.sharedInstance.skipFifteenSeconds()
    }
    
    private func initializeTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let currentAudioDuration = AudioEngine.sharedInstance.getCurrentAudioDuration()
            let currentAudioTime = AudioEngine.sharedInstance.getCurrentAudioTime()
            let remainingTime = currentAudioDuration - currentAudioTime
            
            self.progressSlider.value = currentAudioTime
            
            self.audioPlayerCurrentTimeLabel.text = self.timeToString(time: TimeInterval(currentAudioTime))
            self.audioPlayerRemainingTimeLabel.text = self.timeToString(time: TimeInterval(remainingTime))
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
        resetView()
    }
    
    private func resetView() {
        audioPlayerCurrentTimeLabel.text = "0:00"
        audioPlayerRemainingTimeLabel.text = "0:00"
        progressSlider.value = 0
        audioPlayerVisualizer.waveforms.removeAll()
    }
    
    func play() {
        if AudioEngine.sharedInstance.getCurrentAudioTime() > 0 {
            AudioEngine.sharedInstance.play()
        } else {
            setupSlider()
            initializeTimer()
        }
    }
    
    func updateUI(audioState: AudioEngineState) {
        switch audioState {
        case .paused:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        case .playing:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            audioPlayerVisualizer.active = true
            audioPlayerVisualizer.isHidden = false
            displayAudioVisualizer(audioState: audioState)
        case .stopped:
            progressTimer?.invalidate()
            visualizerTimer?.invalidate()
            resetView()
            audioPlayerVisualizer.isHidden = true
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        case .recording:
            print("Should never be recording here")
        }
    }
    
    func didUpdateAudioState(with audioState: AudioEngineState) {
        updateUI(audioState: audioState)
    }
    
}

extension AudioPlayer1ViewController: AudioSliderDelegate {
    func didChangeScrolling(in audioSlider: UISlider) {
        AudioEngine.sharedInstance.setAudioTime(playBackTime: audioSlider.value)
        initializeTimer()
    }
}
