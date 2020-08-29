//
//  CoreDataManager.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 6/25/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let sharedInstance = CoreDataManager()
    
    func createNewAudioRecording(uniqueFileName: String) -> AudioRecording? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "AudioRecordingObject", in: managedContext)!
        
        let coreDataObject = NSManagedObject(entity: entityDescription, insertInto: managedContext)
        
        let audioRecording = AudioRecording(object: coreDataObject)
        audioRecording.setFileName(filename: uniqueFileName)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        return audioRecording
    }
    
    func loadAudioRecordings() -> [AudioRecording]? {
        var audioRecordings = [AudioRecording]()
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AudioRecordingObject")
        
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
    
    func deleteAudioRecording(at index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")

        do {
            let objects = try managedContext.fetch(deleteRequest)
            managedContext.delete(objects[index] as! NSManagedObject)
        } catch {
            print(error.localizedDescription)
        }

        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAudioRecording(with selectedRecording: AudioRecording) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")
        
        do {
            let objects = try managedContext.fetch(deleteRequest)
            
            for object in objects {
                let audioRecording = AudioRecording(object: object as! NSManagedObject)
                if selectedRecording == audioRecording {
                    managedContext.delete(object as! NSManagedObject)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateAudioRecordingFileName(at index: Int, newFileName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let changeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")
        
        do {
            let objects = try managedContext.fetch(changeRequest)
            // TODO: Find a way to compare objects
            let currentAudioRecordingObject = objects[index]
            let audioRecording = AudioRecording(object: currentAudioRecordingObject as! NSManagedObject)
            audioRecording.setFileName(filename: newFileName)

        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateAudioRecordingFileName(with selectedRecording: AudioRecording, newFileName: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext
        let changeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")

        do {
            let objects = try managedContext.fetch(changeRequest)
            
            for i in 0..<objects.count {
                let recordingInObjects = AudioRecording(object: objects[i] as! NSManagedObject)
                if selectedRecording == recordingInObjects {
                    selectedRecording.setFileName(filename: newFileName)
                    break
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateAudioRecordingTag(at index: Int, tag: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let changeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")
        
        do {
            let objects = try managedContext.fetch(changeRequest)
            
            let currentAudioRecordingObject = objects[index]
            let audioRecording = AudioRecording(object: currentAudioRecordingObject as! NSManagedObject)
            audioRecording.setTag(tag: tag)

        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateAudioRecordingTag(with selectedRecording: AudioRecording, with tag: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let changeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")
        
        do {
            let objects = try managedContext.fetch(changeRequest)
            
            for object in objects {
                let audioRecording = AudioRecording(object: object as! NSManagedObject)
                if selectedRecording == audioRecording {
                    selectedRecording.setTag(tag: tag)
                    break
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeAudioRecordingTag(at index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")

        do {
            let objects = try managedContext.fetch(fetchRequest)
            
            let currentAudioRecordingObject = objects[index] as! NSManagedObject
            let audioRecording = AudioRecording(object: currentAudioRecordingObject)
            audioRecording.removeTags()
            
        } catch {
            print(error.localizedDescription)
        }

        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeAudioRecordingTag(for selectedRecording: AudioRecording) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext  = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            
            for object in objects {
                let audioRecording = AudioRecording(object: object as! NSManagedObject)
                if selectedRecording == audioRecording {
                    selectedRecording.removeTags()
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
