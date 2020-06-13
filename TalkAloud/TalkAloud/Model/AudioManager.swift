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
    
    // TODO: Make audioRecording and audioRecordings NSManangedObjects
    private var audioRecording: NSManagedObject?
    private var audioRecordings: [NSManagedObject] = []

    private var didNewRecording = false
    
    private init() {}
    
    func getNewRecordingURL() -> NSManagedObject? {
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
        
        let soundURL = directoryURL.appendingPathComponent(uniqueFileName)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "AudioRecording", in: managedContext)!
        
        audioRecording = NSManagedObject(entity: entityDescription, insertInto: managedContext)
        
        // let soundURL = audioRecording.url
        // Get the value
        //let url = audioRecording?.value(forKey: "url")
        
        // audioRecording.url = soundURL
        // assign the value
        audioRecording?.setValue(uniqueFileName, forKey: "fileName")
        audioRecording?.setValue(soundURL, forKey: "url") 
        
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
    
    // TODO: Fetch from CoreData here
    func loadAllFiles() -> [NSManagedObject]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AudioRecording")
        
        do {
            audioRecordings = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch, \(error), \(error.userInfo)")
        }
        
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
            // TODO: DEBUG THIS WITH VIRGIL WHEN THE PROJECT WORKS
            let currentAudioRecording = audioRecordings[index]
            currentAudioRecording.setValue(newDestinationURL, forKey: "url")
            audioRecordings[index] = currentAudioRecording
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
        return audioRecordings[index].value(forKey: "url") as! URL
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
