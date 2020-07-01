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

// Class is responsible for Recording and Playing an AudioRecording
class AudioEngine: NSObject {
    weak var delegate: AudioEngineStateChangeDelegate?
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession?
    private let audioRecordingSession = AVAudioSession.sharedInstance()
    static let sharedInstance = AudioEngine()
    public private(set) var audioState: AudioEngineState = .paused {
        didSet {
            delegate?.didUpdateAudioState(with: audioState)
        }
    }
    
    private override init() {}
    
    // Intializing audioPlayer here to make clear when I'm initializing and playing
    func setupAudioPlayer(fileURL: URL) {
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
    func setupRecorder(fileURL: URL) {
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
    
    func getPeakPower(audioState: AudioEngineState) -> Float {
        switch audioState {
        case .playing:
            return audioPlayer?.peakPower(forChannel: 0) ?? -160.00
        case .recording:
            return audioRecorder?.peakPower(forChannel: 0) ?? -160.0
        case .paused:
            return 0
        case .stopped:
            return 0
        }
    }
    
    func updateMeters(audioState: AudioEngineState) {
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
    
    func getCurrentAudioDuration() -> Float {
        return Float(audioPlayer?.duration ?? 0.0)
    }
    
    func getCurrentAudioTime() -> Float {
        return Float(audioPlayer?.currentTime ?? 0.0)
    }
    
    func setAudioTime(playBackTime: Float) {
        audioPlayer?.currentTime = TimeInterval(playBackTime)
    }
    
    func play() {
        audioPlayer?.play()
        audioPlayer?.isMeteringEnabled = true
        audioState = .playing
    }
    
    func play(withFileURL: URL) {
        setupAudioPlayer(fileURL: withFileURL)
        audioPlayer?.play()
        audioPlayer?.isMeteringEnabled = true
        audioState = .playing
    }
    
    func skipFifteenSeconds() {
        audioPlayer?.currentTime += 15
    }
    
    func rewindFifteenSeonds() {
        audioPlayer?.currentTime -= 15
    }
    
    func pause() {
        audioPlayer?.pause()
        audioState = .paused
    }
    
    func record() {
        do {
            try audioRecordingSession.setCategory(.playAndRecord, mode: .default)
            try audioRecordingSession.setActive(true)
            audioRecorder?.isMeteringEnabled = true
        } catch {
            print("Failed to record")
        }
        audioState = .recording
        audioRecorder?.record()
    }
    
    func stop() {
        audioState = .stopped
        audioRecorder?.isMeteringEnabled = false
        audioPlayer?.isMeteringEnabled = false
        audioRecorder?.stop()
        audioPlayer?.stop()
    }
}

extension AudioEngine: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioState = .stopped
    }
}

extension AudioEngine: AVAudioRecorderDelegate {
    
}
