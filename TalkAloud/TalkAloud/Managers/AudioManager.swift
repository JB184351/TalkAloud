//
//  AudioManager.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class AudioManager {
    
    static let sharedInstance = AudioManager()
    
    private var audioRecording: AudioRecording?
    private var audioRecordings: [AudioRecording] = []
    private var filteredAudioRecordings: [AudioRecording] = []
    private var allUniqueTags: [String] = []

    private var didNewRecording = false
    
    private init() {}
    
    func createNewAudioRecording() -> AudioRecording? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm-ss"
        
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let uniqueFileName = "talkaloud" + "_" + dateString + ".m4a"
        
        didNewRecording = true
        
        createDirectoryURL()
        audioRecording = CoreDataManager.sharedInstance.createNewAudioRecording(uniqueFileName: uniqueFileName)
        
        if let audioRecording = audioRecording {
            audioRecordings.append(audioRecording)
        } else {
            return nil
        }
        
        return audioRecording
    }
    
    func createDirectoryURL() {
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
    }
    
    func loadAllRecordings() -> [AudioRecording]? {
        guard let allRecordings = CoreDataManager.sharedInstance.loadAudioRecordings() else { return nil }
        audioRecordings = allRecordings
        return audioRecordings
    }
    
    func removeFile(at index: Int) {
        
        do {
            let fileManager = FileManager.default
            let url = audioRecordings[index].url
            
            try fileManager.removeItem(at: url)
            // Change to use url attribute
            audioRecordings.remove(at: index)
        } catch {
            print(error.localizedDescription)
        }
        
        CoreDataManager.sharedInstance.deleteAudioRecording(at: index)
    }
    
    func renameFile(at index: Int, newFileName: String) -> Error? {
        let fileManager = FileManager.default
        
        let uniqueFileName = newFileName + ".m4a"
        let oldURLWithFileNameDeleted = getRecordingForIndex(index: index).url.deletingLastPathComponent()
        let newDestinationURL = oldURLWithFileNameDeleted.appendingPathComponent(uniqueFileName)
        
        do {
            try fileManager.moveItem(at: getRecordingForIndex(index: index).url, to: newDestinationURL)
        } catch {
            print(error.localizedDescription)
            return error
        }
        
        CoreDataManager.sharedInstance.updateAudioRecordingFileName(at: index, newFileName: uniqueFileName)
        
        return nil
    }
    
    func renameFile(with selectedRecording: AudioRecording, newFileName: String) -> Error? {
        let fileManager = FileManager.default
        
        let uniqueFileName = newFileName + ".m4a"
        let oldURLWithFileNameDeleted = selectedRecording.url.deletingLastPathComponent()
        let newDestinationURL = oldURLWithFileNameDeleted.appendingPathComponent(uniqueFileName)
        
        do {
            try fileManager.moveItem(at: selectedRecording.url, to: newDestinationURL)
        } catch {
            print(error.localizedDescription)
            return error
        }
        
        CoreDataManager.sharedInstance.updateAudioRecordingFileName(with: selectedRecording, newFileName: newFileName)
        
        return nil
    }
    
    func setTag(at index: Int, tag: String) {
        CoreDataManager.sharedInstance.updateAudioRecordingTag(at: index, tag: tag)
    }
    
    func removeTag(at index: Int) {
        CoreDataManager.sharedInstance.removeAudioRecordingTag(at: index)
    }
    
    func filteredAudioRecordings(with tags: [String]) -> [AudioRecording] {
        filteredAudioRecordings.removeAll()
        
        if tags.count == 1 {
            for audioRecording in audioRecordings {
                if let audioRecordingsTags = audioRecording.tags {
                    for tag in tags {
                        if audioRecordingsTags.contains(tag) {
                            filteredAudioRecordings.append(audioRecording)
                        }
                    }
                }
            }
        } else {
            for audioRecording in audioRecordings {
                if let audioRecordingTags = audioRecording.tags {
                    if audioRecordingTags.containsSameElements(as: tags) {
                        filteredAudioRecordings.append(audioRecording)
                    }
                }
            }
        }
        
        return filteredAudioRecordings
    }
    
    func filteredAudioRecordingsCount() -> Int {
        return filteredAudioRecordings.count
    }
    
    func setSelectedRecording(index: Int) {
        self.audioRecording = audioRecordings[index]
    }
    
    func getRecordingForIndex(index: Int) -> AudioRecording {
        return audioRecordings[index]
    }
    
    func getFilteredRecordingForIndex(index: Int) -> AudioRecording {
        return filteredAudioRecordings[index]
    }
    
    func getAllAudioRecordingTags() -> [String]? {
        var allTags = [String]()
        
        guard let audioRecordings = loadAllRecordings() else { return nil }
        
        for audioRecording in audioRecordings {
            if let tags = audioRecording.tags {
                for tag in tags {
                    allTags.append(tag)
                }
            }
        }
        allUniqueTags = allTags.unique
        
        return allUniqueTags.sorted()
    }
    
    func getPlayBackURL() -> URL? {
        if let audioRecording = audioRecording {
            let url = audioRecording.url
            
            do {
                let isReachable = try url.checkResourceIsReachable()
                print(isReachable)
            } catch let e {
                print("Couldn't load file \(e.localizedDescription)")
            }
            return url
            
        } else if didNewRecording == false {
            return nil
        } else {
            return nil
        }
    }
    
    func getLatestRecording() -> URL? {
        if didNewRecording == true {
            guard let recentRecording = audioRecordings.last else { return nil }
            return recentRecording.url
        } else {
            return nil
        }
    }
    
    func getAudioRecordingCount() -> Int {
        return audioRecordings.count
    }
}
