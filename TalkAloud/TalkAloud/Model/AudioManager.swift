//
//  AudioManager.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation

class AudioManager {
    
    static let sharedInstance = AudioManager()
    
    private var audioRecording: URL?
    private var audioRecordings: [URL] = []
//    private var isNewURLGenerated: Bool = false {
//        didSet {
//            guard let lastRecording = audioRecordings.last else { return }
//            audioRecording = lastRecording
//        }
//    }
    
    private init() {}
    
    func getNewRecordingURL() -> URL {
       // isNewURLGenerated = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm-ss"

        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let uniqueFileName = "talkaloud" + "_" + dateString + ".m4a"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud", isDirectory: true)
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let soundURL = directoryURL.appendingPathComponent(uniqueFileName)
        audioRecordings.append(soundURL)
        return soundURL
    }
    
    func loadAllFiles() -> [URL] {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud")
        
        do {
            try audioRecordings = fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return audioRecordings
        } catch {
            print(error.localizedDescription)
        }
        return audioRecordings
    }
    
    func getShortenedURL(audioRecording: URL) -> String {
        let shortenedURL = audioRecording.lastPathComponent
        return shortenedURL
    }
    
    func setSelectedRecording(index: Int) {
        self.audioRecording = audioRecordings[index]
    }
    
    func getRecordingForIndex(index: Int) -> URL {
        return audioRecordings[index]
    }
    
    func getPlayBackURL() -> URL? {
        if let audioRecording = audioRecording {
            return audioRecording
        } else {
            return nil
        }
    }
    
//    func getLastRecording() -> URL? {
//        guard let lastRecording = audioRecordings.last else { return nil }
//        return lastRecording
//    }
    
    func isArrayEmpty() -> Bool {
        if audioRecordings.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func getAudioRecordingCount() -> Int {
        return audioRecordings.count
    }
    
}
