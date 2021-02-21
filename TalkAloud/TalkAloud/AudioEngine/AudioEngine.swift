//
//  AudioEngine.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 3/4/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioEngineStateChangeDelegate: class {
    func didUpdateAudioState(with audioState: AudioEngineState)
}

protocol MicrophonePermissionStatusDelegate: class {
    func didUpdateMicrophonePermissions(isGranted: Bool)
}

// Class is responsible for Recording and Playing an AudioRecording
class AudioEngine: NSObject {
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    weak var delegate: AudioEngineStateChangeDelegate?
    weak var microphonePermissionDelegate: MicrophonePermissionStatusDelegate?
    static let sharedInstance = AudioEngine()
    public private(set) var audioState: AudioEngineState = .stopped {
        didSet {
            delegate?.didUpdateAudioState(with: audioState)
        }
    }
    public private(set) var areRecordingPermissionsGranted: Bool = false {
        didSet {
            microphonePermissionDelegate?.didUpdateMicrophonePermissions(isGranted: handleMicrophonePermission())
        }
    }
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let audioRecordingSession = AVAudioSession.sharedInstance()
    
    private override init() {}
        
    //==================================================
    // MARK: - AudioEngine Setup
    //==================================================
    
    // Intializing audioPlayer here to make clear when I'm initializing and playing
    public func setupAudioPlayer(fileURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            audioPlayer?.isMeteringEnabled = true
        } catch {
            if let err = error as Error? {
                print("AVAudioPlayer error: \(err.localizedDescription)")
                audioPlayer = nil
            }
        }
    }
    
    // Intializing audioRecorder here to make clear
    // when I'm initializing the audioRecorder and actually recording
    public func setupRecorder(fileURL: URL) {
        let settings = [AVFormatIDKey: Int(kAudioFormatAppleLossless), AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey : 320000, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String: Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        } catch {
            if let err = error as Error? {
                print("AVAudioRecorder error: \(err.localizedDescription)")
                audioRecorder = nil
            } else {
                audioRecorder?.delegate = self
                audioRecorder?.prepareToRecord()
            }
        }
    }
    
    //==================================================
    // MARK: - Gets/Updates Peak Power
    //==================================================
    
    public func getPeakPower(audioState: AudioEngineState) -> Float {
        switch audioState {
        case .playing:
            return audioPlayer?.peakPower(forChannel: 0) ?? -160.0
        case .recording:
            return audioRecorder?.peakPower(forChannel: 0) ?? -160.0
        case .paused:
            return 0
        case .stopped:
            return 0
        }
    }
    
    public func updateMeters(audioState: AudioEngineState) {
        switch audioState {
        case .playing:
            audioPlayer?.updateMeters()
        case .recording:
            audioRecorder?.updateMeters()
        case .paused:
            print("Paused")
        case .stopped:
            print("Stopped")
        }
    }
    
    //==================================================
    // MARK: - Current Time/Duration Methods
    //==================================================
    
    public func getCurrentAudioRecorderDuration() -> Float {
        return Float(audioRecorder?.currentTime ?? 0.0)
    }
    
    public func getCurrentAudioDuration() -> Float {
        return Float(audioPlayer?.duration ?? 0.0)
    }
    
    public func getCurrentAudioTime() -> Float {
        return Float(audioPlayer?.currentTime ?? 0.0)
    }
    
    public func setAudioTime(playBackTime: Float) {
        audioPlayer?.currentTime = TimeInterval(playBackTime)
    }
    
    public func getDuration(for url: URL) -> Int {
        let asset = AVURLAsset(url: url)
        return Int(CMTimeGetSeconds(asset.duration))
    }
    
    //==================================================
    // MARK: - Playback Controls
    //==================================================
    
    public func play() {
        audioPlayer?.play()
        audioPlayer?.isMeteringEnabled = true
        audioState = .playing
    }
    
    public func play(withFileURL: URL) {
        setupAudioPlayer(fileURL: withFileURL)
        audioPlayer?.play()
        audioPlayer?.isMeteringEnabled = true
        audioState = .playing
    }
    
    public func skipFifteenSeconds() {
        audioPlayer?.currentTime += 15
    }
    
    public func rewindFifteenSeonds() {
        audioPlayer?.currentTime -= 15
    }
    
    public func pause() {
        audioPlayer?.pause()
        audioState = .paused
    }
    
    public func stop() {
        audioState = .stopped
        audioRecorder?.isMeteringEnabled = false
        audioPlayer?.isMeteringEnabled = false
        
        // This code is needed here so volume on playback is louder
        do {
            try audioRecordingSession.setCategory(.playback, mode: .default, options: .allowBluetooth)
        } catch {
            print("Failed to setCategory to .playback")
        }
        
        audioRecorder?.stop()
        audioPlayer?.stop()
    }
    
    //==================================================
    // MARK: - Record
    //==================================================
    
    public func record() {
        do {
            try audioRecordingSession.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
            try audioRecordingSession.setActive(true)
            
            audioRecordingSession.requestRecordPermission { (isGranted) in
                DispatchQueue.main.async {
                    self.areRecordingPermissionsGranted = isGranted
                }
            }
            
            audioRecorder?.isMeteringEnabled = true
        } catch {
            print("Failed to record")
        }
        audioState = .recording
        audioRecorder?.record()
    }
    
    public func handleMicrophonePermission() -> Bool {
        switch audioRecordingSession.recordPermission {
        case .undetermined:
            return false
        case .denied:
            return false
        case .granted:
            return true
        default:
            return false
        }
    }
}

//==================================================
// MARK: - AVAudioPlayer Delegate
//==================================================

extension AudioEngine: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioState = .stopped
    }
    
}

//==================================================
// MARK: - AVAudioRecorder Delegate
//==================================================

extension AudioEngine: AVAudioRecorderDelegate {
    
}
