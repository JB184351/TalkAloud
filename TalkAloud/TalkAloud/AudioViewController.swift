//
//  ViewController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 3/2/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    // Audio Engine class with these properties
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var fileName = "selftalkfile.m4a"
    
    @IBOutlet var playAudioButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Move to Audio Engine class
    func setupRecorder() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let audioFilename = documentsDirectory.appendingPathComponent(fileName)
        
        let settings = [AVFormatIDKey: Int(kAudioFormatAppleLossless), AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
        AVEncoderBitRateKey : 320000, AVNumberOfChannelsKey: 2, AVSampleRateKey: 44100.0] as [String: Any]
        
        var error: NSError?
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        } catch {
            audioRecorder = nil
        }
        
        if let err = error {
            print("AVAudioRecorder error: \(err.localizedDescription)")
        } else {
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        }
    }
    // Put in Audio Engine Class
    func preparePlayer() {
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
    // Put in Audio Engine Class
    func getFileURL() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent(fileName)
        return soundURL
    }
    
    @IBAction func playAndStopButtonAction(_ sender: UIButton) {
        // Use enum to determine state of audio of being playable
        if sender.titleLabel?.text == "Play" {
            recordAudioButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            // Call Audio Engine .player that will call these methods
            preparePlayer()
            audioPlayer.play()
        } else {
            // Call Audio Engine .stop that will call these methods
            audioPlayer.stop()
            sender.setTitle("Play", for: .normal)
        }
    }
    
    @IBAction func recordAudioButtonAction(_ sender: UIButton) {
        // Audio Engine Class should manage audio recording session
        let recordingSession = AVAudioSession.sharedInstance()
        // Use enum to determine state of audio of being recordable
        if sender.titleLabel?.text == "Record" {
            setupRecorder()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                audioRecorder.record()
            } catch {
                print("Failed to record")
            }
            sender.setTitle("Stop", for: .normal)
            
        } else {
            audioRecorder.stop()
            sender.setTitle("Record", for: .normal)
        }
    }
    
    
}

