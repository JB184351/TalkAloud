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
    
    private var audioRecording: AudioRecording?
    private var audioRecordings = [AudioRecording]()
    
    func saveToCoreDataObject() -> AudioRecording? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "AudioRecordingObject", in: managedContext)!
        
        let coreDataObject = NSManagedObject(entity: entityDescription, insertInto: managedContext)
        
        audioRecording = AudioRecording(object: coreDataObject)
        
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
    
    func loadFromCoreData() -> [AudioRecording]? {
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
}
