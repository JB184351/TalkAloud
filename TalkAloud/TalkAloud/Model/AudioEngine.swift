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
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var recordingSession: AVAudioSession!
    private let audioRecordingSession = AVAudioSession.sharedInstance()
    static let sharedInstance = AudioEngine()
    public private(set) var audioState: AudioEngineState = .stopped {
        didSet {
            delegate?.didUpdateAudioState(with: audioState)
        }
    }
    
    private override init() {}
    
    // Intializing audioPlayer here to make clear when I'm initializing and playing
    func setupAudioPlayer(fileURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer.delegate = self
            audioPlayer.volume = 1.0
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
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
            }
        }
    }
    
    func play(withFileURL: URL) {
        setupAudioPlayer(fileURL: withFileURL)
        audioPlayer.play()
        audioState = .playing
    }
    
    func pause() {
        audioPlayer.pause()
        audioState = .stopped
    }
    
    func record() {
        do {
            try audioRecordingSession.setCategory(.playAndRecord, mode: .default)
            try audioRecordingSession.setActive(true)
        } catch {
            print("Failed to record")
        }
        audioState = .recording
        audioRecorder.record()
    }
    
    func stop() {
        audioState = .stopped
        audioRecorder.stop()
    }
}

extension AudioEngine: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioState = .stopped
    }
}

extension AudioEngine: AVAudioRecorderDelegate {
    
}
