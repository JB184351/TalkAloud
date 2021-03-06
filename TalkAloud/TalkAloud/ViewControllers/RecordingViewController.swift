//
//  RecordingViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/3/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    @IBOutlet private var audioRecordingTimeLabel: UILabel!
    @IBOutlet private var audioRecordingVisualizer: AudioPlayerVisualizerView!
    @IBOutlet private var recordButton: UIButton!
    private var progressTimer: Timer?
    private var visualizerTimer: Timer?
    
    //==================================================
    // MARK: - Life Cycle Methods
    //==================================================
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetView()
        AudioEngine.sharedInstance.stop()
    }
    
    //==================================================
    // MARK: - Action
    //==================================================
    
    @IBAction func recordButtonAction(_ sender: Any) {
        let audioState = AudioEngine.sharedInstance.audioState
    
        // TODO: Encapsulate logic in AudioEngine
        AVAudioSession.sharedInstance().requestRecordPermission { (isGranted) in
            DispatchQueue.main.async {
                if isGranted {
                    switch audioState {
                    case .stopped:
                        guard let url = AudioManager.sharedInstance.createNewAudioRecording()?.url else { return }
                        AudioEngine.sharedInstance.setupRecorder(fileURL: url)
                        AudioEngine.sharedInstance.record()
                        self.recordButton.setImage(UIImage(named: "stopbutton"), for: .normal)
                        self.intializeRecordingTimer()
                        self.displayAudioVisualizer(audioState: AudioEngine.sharedInstance.audioState)
                        self.audioRecordingVisualizer.active = true
                        self.audioRecordingVisualizer.isHidden = false
                    case .recording:
                        AudioEngine.sharedInstance.stop()
                        self.resetView()
                        self.visualizerTimer?.invalidate()
                    case .paused:
                        print("Paused should never be happening")
                    case .playing:
                        print("Should never get here")
                    }
                } else {
                    self.presentSettingsAlertController()
                }
            }
        }
        
    }
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
    private func intializeRecordingTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let recordingTime = AudioEngine.sharedInstance.getCurrentAudioRecorderDuration()
            let recordingTimeInterval = TimeInterval(recordingTime)
            self.audioRecordingTimeLabel.text = recordingTimeInterval.timeToString()
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
                self.audioRecordingVisualizer.waveforms.append(Int(power))
                self.audioRecordingVisualizer.setNeedsDisplay()
            }
        })
    }
    
    private func resetView() {
        audioRecordingTimeLabel.text = "0:00"
        progressTimer?.invalidate()
        visualizerTimer?.invalidate()
        audioRecordingVisualizer.waveforms.removeAll()
        audioRecordingVisualizer.isHidden = true
        recordButton.setImage(UIImage(named: "recordbutton"), for: .normal)
    }
    
    private func presentSettingsAlertController() {
        let settingsAlertController = UIAlertController (title: "Microphone Access Required", message: "Turn on microphone permissions in settings", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        settingsAlertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        settingsAlertController.addAction(cancelAction)
        
        present(settingsAlertController, animated: true, completion: nil)
    }
    
}
