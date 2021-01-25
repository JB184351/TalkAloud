//
//  PlayerViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/4/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController, AudioEngineStateChangeDelegate {
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    @IBOutlet private var audioPlayerVisualizer: AudioPlayerVisualizerView!
    @IBOutlet private var audioRecordingNameLabel: UILabel!
    @IBOutlet private var audioRecordingDetailLabel: UILabel!
    @IBOutlet private var progressSlider: AudioSlider!
    @IBOutlet private var audioPlayerCurrentTimeLabel: UILabel!
    @IBOutlet private var audioPlayerRemainingTimeLabel: UILabel!
    @IBOutlet private var goBackFifteenSecondsButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var goForwardFifteenSecondsButton: UIButton!
    private lazy var moreOptionsTransitioningDelegate = MoreOptionsPresentationManager()
    private var progressTimer: Timer?
    private var visualizerTimer: Timer?
    private var audioRecordingName: String?
    private var audioRecordingDetail: String?
    private var isAudioPlaying = false {
        didSet {
            updateUI(audioState: AudioEngine.sharedInstance.audioState)
        }
    }
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    public var currentAudioRecording: AudioRecording?
    
    //==================================================
    // MARK: - Life Cycle Methods
    //==================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressSlider.delegate = self
        self.audioRecordingNameLabel.text = currentAudioRecording?.fileName.removeFileExtension
        self.audioRecordingDetailLabel.text = currentAudioRecording?.creationDate.localDescription
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isAudioPlaying = true
        setupSlider()
        initializeTimer()
        audioPlayerVisualizer.waveforms.removeAll()
        self.audioRecordingNameLabel.text = currentAudioRecording?.fileName.removeFileExtension
        self.audioRecordingDetailLabel.text = currentAudioRecording?.creationDate.localDescription
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressTimer?.invalidate()
        visualizerTimer?.invalidate()
        audioRecordingNameLabel.text = "File Name"
        audioRecordingDetailLabel.text = "Metadata Will Go Here"
        AudioEngine.sharedInstance.stop()
    }
    
    //==================================================
    // MARK: - Action
    //==================================================
    
    @IBAction private func playAndPauseButtonAction(_ sender: UIButton) {
        if AudioEngine.sharedInstance.audioState == .paused {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            play()
        } else if AudioEngine.sharedInstance.audioState == .playing {
            AudioEngine.sharedInstance.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else if AudioEngine.sharedInstance.audioState == .stopped {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            play()
        }
    }
    
    @IBAction private func rewindAction(_ sender: Any) {
        AudioEngine.sharedInstance.rewindFifteenSeonds()
    }
    
    @IBAction private func skipForwardAction(_ sender: Any) {
        AudioEngine.sharedInstance.skipFifteenSeconds()
    }
    
    @IBAction private func moreButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let moreOptionsViewController = storyboard.instantiateViewController(identifier: "AudioRecodrdingOptionsViewController") as! MoreOptionsViewController
        
        moreOptionsViewController.currentlySelectedRecording = currentAudioRecording
        moreOptionsViewController.delegate = self
        
        moreOptionsViewController.transitioningDelegate = moreOptionsTransitioningDelegate
        moreOptionsViewController.modalPresentationStyle = .custom
        
        self.navigationController?.present(moreOptionsViewController, animated: true)
    }
    
    private func initializeTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let currentAudioDuration = AudioEngine.sharedInstance.getCurrentAudioDuration()
            let currentAudioTime = AudioEngine.sharedInstance.getCurrentAudioTime()
            let remainingTime = currentAudioDuration - currentAudioTime
            
            self.progressSlider.value = currentAudioTime
            
            let currentTimeInterval = TimeInterval(currentAudioTime)
            let remainingTimeInterval = TimeInterval(remainingTime)
            
            self.audioPlayerCurrentTimeLabel.text = currentTimeInterval.timeToString()
            self.audioPlayerRemainingTimeLabel.text = remainingTimeInterval.timeToString()
        })
    }
    
    //==================================================
    // MARK: - UI Update/Set Methods
    //==================================================
    
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
    
    private func updateUI(audioState: AudioEngineState) {
        switch audioState {
        case .paused:
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            visualizerTimer?.invalidate()
        case .playing:
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            audioPlayerVisualizer.active = true
            audioPlayerVisualizer.isHidden = false
            displayAudioVisualizer(audioState: audioState)
            initializeTimer()
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
    
    //==================================================
    // MARK: - Public Methods
    //==================================================
    
    public func play() {
        if AudioEngine.sharedInstance.getCurrentAudioTime() > 0 {
            AudioEngine.sharedInstance.play()
        } else if AudioEngine.sharedInstance.audioState == .stopped {
            AudioEngine.sharedInstance.play(withFileURL: currentAudioRecording!.url)
        } else {
            setupSlider()
            initializeTimer()
        }
    }
    
    public func didUpdateAudioState(with audioState: AudioEngineState) {
        updateUI(audioState: audioState)
    }
    
}

//==================================================
// MARK: - AudioSlider Delegate
//==================================================

extension PlayerViewController: AudioSliderDelegate {
    
    func didChangeScrolling(in audioSlider: UISlider) {
        AudioEngine.sharedInstance.setAudioTime(playBackTime: audioSlider.value)
        initializeTimer()
    }
    
}

//==================================================
// MARK: - MoreOptions Delegate
//==================================================

extension PlayerViewController: MoreOptionsDelegate {
    
    func didDelete(selectedRecording recording: AudioRecording?) {
        guard let tags = recording?.tags else { return }
        
        AudioManager.sharedInstance.removeAudioRecording(with: recording!)
        AudioManager.sharedInstance.removeTagsFromTagModelDataSource(tags: tags)
        self.navigationController?.popViewController(animated: true)
    }
    
    func didAddTag(for selectedRecording: AudioRecording?) {
        print("Added tag to recording")
    }
    
    func didRemoveTags(for selectedRecording: AudioRecording?) {
        guard let tags = selectedRecording?.tags else { return }
        
        AudioManager.sharedInstance.removeTag(for: selectedRecording!)
        AudioManager.sharedInstance.removeTagsFromTagModelDataSource(tags: tags)
    }
    
    func didUpdateFileName(for selectedRecording: AudioRecording) {
        audioRecordingNameLabel.text = selectedRecording.fileName
    }
    
}


