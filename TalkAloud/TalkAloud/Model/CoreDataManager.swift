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

class CoreDataManager: NSManagedObject {
    
    static let sharedInstance = CoreDataManager()
    
    
    func createNewAudioRecording(uniqueFileName: String) -> AudioRecording? {
        var audioRecordings = [AudioRecording]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "AudioRecordingObject", in: managedContext)!
        
        let coreDataObject = NSManagedObject(entity: entityDescription, insertInto: managedContext)
        
        let audioRecording = AudioRecording(object: coreDataObject)
        audioRecording.setFileName(filename: uniqueFileName)
        
        do {
            try managedContext.save()
            audioRecordings.append(audioRecording)
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
    
    func deleteAudioRecording(at index: Int) {

        var audioRecordings = [AudioRecording]()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AudioRecordingObject")

        do {
            let objects = try managedContext.fetch(deleteRequest)

            for object in objects as! [NSManagedObject] {
                
                if object == objects[index] as! NSManagedObject {
                    managedContext.delete(object)
                } else {
                    let audioRecording = AudioRecording(object: object)
                    audioRecordings.append(audioRecording)
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
