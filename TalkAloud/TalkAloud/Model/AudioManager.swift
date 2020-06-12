//
//  AudioManager.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import CoreData

class AudioManager {
    
    static let sharedInstance = AudioManager()
    
    // TODO: Make audioRecording and audioRecordings NSManangedObjects
    private var audioRecording: URL?
    private var audioRecordings: [URL] = []
    private var didNewRecording = false
    
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
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud", isDirectory: true)
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        didNewRecording = true
        // TODO: Change to use fileName and url attributes from AudioRecording Entity
        let soundURL = directoryURL.appendingPathComponent(uniqueFileName)
        audioRecordings.append(soundURL)
        return soundURL
    }
    
    // TODO: Fetch from CoreData here
    func loadAllFiles() -> [URL] {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud")
        
        do {
            // TODO: Change to use url attribute
            try audioRecordings = fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return audioRecordings
        } catch {
            print(error.localizedDescription)
        }
        // change to use the array of audiorecording attribute url
        return audioRecordings
    }
    
    func removeFile(at index: Int) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: getRecordingForIndex(index: index))
            // Change to use url attribute
            audioRecordings.remove(at: index)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func renameFile(at index: Int, newFileName: String) -> Error? {
        let fileManager = FileManager.default
        
        let uniqueFileName = newFileName + ".m4a"
        let oldURLWithFileNameDeleted = getRecordingForIndex(index: index).deletingLastPathComponent()
        let newDestinationURL = oldURLWithFileNameDeleted.appendingPathComponent(uniqueFileName)
        
        do {
            try fileManager.moveItem(at: getRecordingForIndex(index: index), to: newDestinationURL)
            // TODO: Change to use url attribute
            audioRecordings[index] = newDestinationURL
        } catch {
            print(error.localizedDescription)
            return error
        }
        
        return nil
    }
    
    // TODO: Change to use filename attribute
    func getShortenedURL(audioRecording: URL) -> String {
        let shortenedURL = audioRecording.lastPathComponent
        return shortenedURL
    }
    
    // TODO: Change to use url attirbute
    func setSelectedRecording(index: Int) {
        self.audioRecording = audioRecordings[index]
    }
    
    // TODO: Change to use url attirbute
    func getRecordingForIndex(index: Int) -> URL {
        return audioRecordings[index]
    }
    
    // TODO: Change to use url attribute
    func getPlayBackURL() -> URL? {
        if let audioRecording = audioRecording {
            return audioRecording
        } else if didNewRecording == false {
            return nil
        } else {
            return nil
        }
    }
    
    // TODO: Change to use url attribute
    func getLatestRecording() -> URL? {
        if didNewRecording == true {
            guard let recentRecording = audioRecordings.last else { return nil }
            return recentRecording
        } else {
            return nil
        }
    }
    
    func getAudioRecordingCount() -> Int {
        // TODO: Change to use url attribute
        return audioRecordings.count
    }
}
