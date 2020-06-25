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

    private var didNewRecording = false
    
    private init() {}
    
    func getNewRecordingURL() -> AudioRecording? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm-ss"

        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let uniqueFileName = "talkaloud" + "_" + dateString + ".m4a"
        
        didNewRecording = true
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "AudioRecordingObject", in: managedContext)!
    
        audioRecording = AudioRecording(object: NSManagedObject(entity: entityDescription, insertInto: managedContext))
        audioRecording?.setFileName(filename: uniqueFileName)
        
        if let audioRecording = audioRecording {
            do {
                try managedContext.save()
                audioRecordings.append(audioRecording)
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            } 
        }
        
        return audioRecording
    }
    
    func loadAllFiles() -> [AudioRecording]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AudioRecordingObject")
        audioRecordings.removeAll()
        
        do {
            let audioRecordingObjects = try managedContext.fetch(fetchRequest)
            
            for object in audioRecordingObjects {
                let audioRecording = AudioRecording(object: object)
                audioRecordings.append(audioRecording)
            }

        } catch let error as NSError {
            print("Could not fetch, \(error), \(error.userInfo)")
        }
        
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
    }
    
    func renameFile(at index: Int, newFileName: String) -> Error? {
        let fileManager = FileManager.default
        
//        let uniqueFileName = newFileName + ".m4a"
//        let oldURLWithFileNameDeleted = getRecordingForIndex(index: index).deletingLastPathComponent()
//        let newDestinationURL = oldURLWithFileNameDeleted.appendingPathComponent(uniqueFileName)
        
//        do {
//            try fileManager.moveItem(at: getRecordingForIndex(index: index), to: newDestinationURL)
//            // TODO: DEBUG THIS WITH VIRGIL WHEN THE PROJECT WORKS
//            let currentAudioRecording = audioRecordings[index]
//            currentAudioRecording.setValue(newDestinationURL, forKey: "url")
//            audioRecordings[index] = currentAudioRecording
//        } catch {
//            print(error.localizedDescription)
//            return error
//        }
        
        return nil
    }
    
    func setSelectedRecording(index: Int) {
        self.audioRecording = audioRecordings[index]
    }
    
    func getRecordingForIndex(index: Int) -> AudioRecording {
        return audioRecordings[index]
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
