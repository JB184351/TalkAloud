//
//  NewAudioRecordingViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/3/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class NewAudioRecordingViewController: UIViewController {

    @IBOutlet var audioRecordingTimeLabel: UILabel!
    @IBOutlet var audioRecordingVisualizer: AudioPlayerVisualizerView!
    @IBOutlet var recordButton: UIButton!
    private var progressTimer: Timer?
    private var visualizerTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetView()
        AudioEngine.sharedInstance.stop()
    }
    
    @IBAction func recordButtonAction(_ sender: Any) {
        if AudioEngine.sharedInstance.audioState == .stopped || AudioEngine.sharedInstance.audioState == .paused {
            
            guard let url = AudioManager.sharedInstance.createNewAudioRecording()?.url else { return }
            AudioEngine.sharedInstance.setupRecorder(fileURL: url)
            AudioEngine.sharedInstance.record()
            recordButton.setImage(UIImage(named: "stopbutton"), for: .normal)
            intializeRecordingTimer()
            displayAudioVisualizer(audioState: AudioEngine.sharedInstance.audioState)
            audioRecordingVisualizer.active = true
            audioRecordingVisualizer.isHidden = false
        } else if AudioEngine.sharedInstance.audioState == .recording {
            recordButton.setImage(UIImage(named: "recordbutton"), for: .normal)
            AudioEngine.sharedInstance.stop()
            resetView()
            visualizerTimer?.invalidate()
        }
    }
    
    private func intializeRecordingTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let recordingTime = AudioEngine.sharedInstance.getCurrentAudioRecorderDuration()
            //print(recordingTime)
            self.audioRecordingTimeLabel.text = self.timeToString(time: TimeInterval(recordingTime))
        })
    }
    
    func timeToString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        return String(format: "%2i:%02i", minutes, seconds)
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
    }
}
