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

class AudioEngine: NSObject {
    weak var delegate: AudioEngineStateChangeDelegate?
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var recordingSession: AVAudioSession!
    private var fileName = "selftalkfile.m4a"
    public private(set) var audioState: AudioEngineState = .stopped
    private let audioRecordingSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        setupAudioPlayer()
        setupRecorder()
    }
    
    // Intializing audioPlayer here to make clear when I'm initializing and playing
    func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL())
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
    func setupRecorder() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let audioFilename = documentsDirectory.appendingPathComponent(self.fileName)
        
        let settings = [AVFormatIDKey: Int(kAudioFormatAppleLossless), AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey : 320000, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String: Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
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
    
    func play() {
        audioState = .playing
        audioPlayer.play()
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
    
    func getFileURL() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documenetDirectory = urls[0] as URL
        let soundURL = documenetDirectory.appendingPathComponent(self.fileName)
        return soundURL
    }
}

extension AudioEngine: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioState = .stopped
        delegate?.didUpdateAudioState(with: audioState)
    }
}

extension AudioEngine: AVAudioRecorderDelegate {
    
}
