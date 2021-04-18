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
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    static let sharedInstance = AudioManager()
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    private var audioRecording: AudioRecording?
    private var audioRecordings: [AudioRecording] = []
    private var tagModelDataSource: [TagModel] = []
    private var allSelectedTags: [TagModel] = []
    private var filteredAudioRecordings: [AudioRecording] = []
    private var didNewRecording = false
    
    private init() {}
    
    //==================================================
    // MARK: - AudioRecording Creation
    //==================================================
    
    public func loadAudioRecordings(with tags: [TagModel]? = nil) -> [AudioRecording]? {
        guard let tags = tags else { return loadAllRecordings() }
        return filteredAudioRecordings(with: tags)!
    }
    
    public func createNewAudioRecording() -> AudioRecording? {
        var uniqueFileName = ""
        var audioRecordingFileNames = [String]()
        
        for recording in audioRecordings {
            audioRecordingFileNames.append(recording.fileName)
        }
        
        for i in 0..<Int.max {
            uniqueFileName = "talkaloud" + "_" + "\(i + 1)" + ".m4a"
            
            if !audioRecordingFileNames.contains(uniqueFileName) {
                break
            }
        }
        
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
    
    private func createDirectoryURL() {
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
    
    //==================================================
    // MARK: - AudioRecording Modification
    //==================================================
    
    public func removeAudioRecording(with selectedRecording: AudioRecording) {
        do {
            let fileManager = FileManager.default
            let url = selectedRecording.url
            
            try fileManager.removeItem(at: url)
            
            for i in 0..<audioRecordings.count {
                if selectedRecording == audioRecordings[i] {
                    audioRecordings.remove(at: i)
                    break
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        CoreDataManager.sharedInstance.deleteAudioRecording(with: selectedRecording)
    }
    
    public func renameFile(with selectedRecording: AudioRecording, newFileName: String) -> Error? {
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
        
        CoreDataManager.sharedInstance.updateAudioRecordingFileName(with: selectedRecording, newFileName: uniqueFileName)
        
        return nil
    }
    
    //==================================================
    // MARK: - Tag Methods
    //==================================================
    
    public func setTag(for selectedRecording: AudioRecording, tag: String) {
        CoreDataManager.sharedInstance.updateAudioRecordingTag(with: selectedRecording, with: tag)
    }
    
    public func removeTag(for selectedRecording: AudioRecording) {
        CoreDataManager.sharedInstance.removeAudioRecordingTag(for: selectedRecording)
    }
    
    public func getTags(for selectedRecording: AudioRecording) -> [String] {
        guard let tags = selectedRecording.tags else { return [] }
        return tags
    }
    
    public func getAllAudioRecordingTags() -> [TagModel]? {
        for audioRecording in audioRecordings {
            if let tags = audioRecording.tags {
                for tag in tags {
                    let tagModel = TagModel(tag: tag)
                    if !self.tagModelDataSource.contains(where: { $0.tag == tagModel.tag }) {
                        self.tagModelDataSource.append(tagModel)
                    }
                }
            }
        }
        
        return self.tagModelDataSource
    }
    
    public func updateTagModel(with selectedTag: TagModel) {
        for i in 0..<tagModelDataSource.count {
            if tagModelDataSource[i] == selectedTag {
                tagModelDataSource[i].isTagSelected = !selectedTag.isTagSelected
                break
            }
        }
    }
    
    public func addTag(tagModel: TagModel) {
        if !self.tagModelDataSource.contains(tagModel) {
            self.tagModelDataSource.append(tagModel)
        }
    }
    
    public func removeTagsFromTagModelDataSource(tags: [String]) {
        let allAudioRecordings = loadAllRecordings()!
        var multipleRecordingsWithSameTagCount = 0
        
        for audioRecording in allAudioRecordings {
            if let audioRecordingTags = audioRecording.tags {
                if audioRecordingTags.containsSameElements(as: tags) {
                    multipleRecordingsWithSameTagCount += 1
                }
            }
        }
        
        if multipleRecordingsWithSameTagCount == 1 {
           tagModelDataSource = tagModelDataSource.filter({ $0.isTagSelected == false })
        }
        
    }
    
    func getAllSelectedTagCount() -> Int {
        return tagModelDataSource.filter({ $0.isTagSelected == true }).map({ $0.tag }).count
    }
    
    public func unSelectAllTags() {
        for i in 0..<tagModelDataSource.count {
            if tagModelDataSource[i].isTagSelected == true {
                tagModelDataSource[i].isTagSelected = false
            }
        }
    }
    
    public func addSelectedTagsToDataSource() {
        for i in 0..<allSelectedTags.count {
            if !tagModelDataSource.contains(allSelectedTags[i]) {
                tagModelDataSource.append(allSelectedTags[i])
            }
        }
        
        allSelectedTags.removeAll()
    }
    
    //==================================================
    // MARK: - Get/Set AudioRecording
    //==================================================
    
    public func getRecordingForIndex(index: Int) -> AudioRecording {
        return audioRecordings[index]
    }
    
    public func setSelectedRecording(index: Int) {
        self.audioRecording = audioRecordings[index]
    }
    
    //==================================================
    // MARK: - Playback Methods
    //==================================================
    
    public func getPlayBackURL() -> URL? {
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
    
    public func getLatestRecording() -> URL? {
        if didNewRecording == true {
            guard let recentRecording = audioRecordings.last else { return nil }
            return recentRecording.url
        } else {
            return nil
        }
    }
    
    //==================================================
    // MARK: - AudioRecording Count
    //==================================================
    
    private func getAudioRecordingCount() -> Int {
        return audioRecordings.count
    }
    
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
    private func loadAllRecordings() -> [AudioRecording]? {
        guard let allRecordings = CoreDataManager.sharedInstance.loadAudioRecordings() else { return nil }
        audioRecordings = allRecordings
        return audioRecordings
    }
    
    private func filteredAudioRecordings(with tags: [TagModel]?) -> [AudioRecording]? {
        guard let tags = tags else { return audioRecordings }
        
        let selectedTags = tags.filter({ $0.isTagSelected == true }).map({ $0.tag })
        
        filteredAudioRecordings.removeAll()
        
        if selectedTags.count == 1 {
            for audioRecording in audioRecordings {
                if let audioRecordingTags = audioRecording.tags {
                    for tag in selectedTags {
                        if audioRecordingTags.contains(tag) {
                            filteredAudioRecordings.append(audioRecording)
                        }
                    }
                }
            }
        } else if selectedTags.count >= 2 {
            for audioRecording in audioRecordings {
                if let audioRecordingTags = audioRecording.tags {
                    if audioRecordingTags.containsSameElements(as: selectedTags) {
                        filteredAudioRecordings.append(audioRecording)
                    }
                }
            }
        } else {
            return audioRecordings
        }
        
        return filteredAudioRecordings
    }
    
}
