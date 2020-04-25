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
    
    private var audioRecording: URL!
    private var audioRecordings: [URL] = []
    
    private init() {}
    
    func getNewRecordingURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm-ss"

        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let uniqueFileName = "talkaloud" + "_" + dateString + ".m4a"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud")
        
        if !fileManager.fileExists(atPath: directoryURL.absoluteString) {
            do {
                try fileManager.createDirectory(atPath: directoryURL.absoluteString, withIntermediateDirectories: true, attributes: nil)
                let soundURL = directoryURL.appendingPathComponent(uniqueFileName)
                audioRecordings.append(soundURL)
                return soundURL
            } catch {
                print(error.localizedDescription)
            }
        } else {
            let soundURL = directoryURL.appendingPathComponent(uniqueFileName)
            audioRecordings.append(soundURL)
            return soundURL
        }
        
        
        let soundURL = directoryURL.appendingPathComponent(uniqueFileName, isDirectory: false)
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
    
//    func getShortenedURLs(audioRecordings: [URL]) -> [URL] {
//        var stringURLs = [String]()
//        let startIndex = "talkaloud_"
//        let endIndex = "a"
//
//        for recording in 0..<audioRecordings.count {
//            let stringedURL = audioRecordings[recording].absoluteString
//            stringURLs.append(stringedURL)
//        }
//
//
//    }
    
    // TO DO: Set URL Property Method
    func setSelectedRecording(index: Int) {
        self.audioRecording = audioRecordings[index]
    }
    
    func getRecordingForIndex(index: Int) -> URL {
        return audioRecordings[index]
    }
    
    func getPlayBackURL() -> URL {
        if let audioRecording = audioRecording {
            return audioRecording
        } else {
            let recentRecording = audioRecordings.last!
            return recentRecording
        }
    }
    
    func isArrayEmpty() -> Bool {
        if audioRecordings.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    // TO DO: Make Method to Load URLs from the Directory Here
    
    // Get count of all audioRecordings
    func getAudioRecordingCount() -> Int {
        return audioRecordings.count
    }
    
}
