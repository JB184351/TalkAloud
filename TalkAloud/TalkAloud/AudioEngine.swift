//
//  AudioEngine.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 3/4/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import AVFoundation

class AudioEngine: NSObject {
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var recordingSession: AVAudioSession!
    private var fileName = "selftalkfile.m4a"
    public private(set) var audioState: AudioEngineState = .stopped
    private let audioRecordingSession = AVAudioSession.sharedInstance()
    
    func setupRecorder() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let audioFilename = documentsDirectory.appendingPathComponent(self.fileName)
        
        let settings = [AVFormatIDKey: Int(kAudioFormatAppleLossless), AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey : 320000, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String: Any]
        
        var error: NSError?
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioState = .recording
        } catch {
            audioRecorder = nil
        }
        
        if let err = error {
            print("AVAudioRecorder error: \(err.localizedDescription)")
        } else {
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        }
        audioState = .stopped
    }
    
    func play() {
        do {
            audioState = .playing
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL())
            audioPlayer.delegate = self
            audioPlayer.volume = 1.0
            audioPlayer.play()
        } catch {
            if let err = error as Error? {
                print("AVAudioPlayer error: \(err.localizedDescription)")
                audioPlayer = nil
            }
        }
    }
    
    func pause() {
        audioPlayer.pause()
        audioState = .paused
    }
    
    func resume() {
        
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
        player.stop()
        self.audioPlayer?.stop()
        self.audioState = .stopped
        self.audioPlayer = nil
    }
}

extension AudioEngine: AVAudioRecorderDelegate {
    
}
