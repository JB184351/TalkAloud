//
//  AudioRecording.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 6/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import CoreData

struct AudioRecording {
    private var object: NSManagedObject
    
    var fileName: String {
        return object.value(forKey: "fileName") as! String
    }
    
    var tags: String {
        return object.value(forKey: "tags") as! String
    }
    
    var url: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud", isDirectory: true)
        
        // Keeping this here for new app install
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let newURL = directoryURL.appendingPathComponent(self.fileName)
        return newURL
    }
    
    init(object: NSManagedObject) {
        self.object = object
    }
    
    func setFileName(filename: String) {
        object.setValue(filename, forKey: "fileName")
    }
}
