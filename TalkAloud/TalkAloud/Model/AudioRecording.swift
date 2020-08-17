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
    
    var tags: [String]? {
        return object.value(forKey: "tag") as? [String] ?? []
    }
    
    var url: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud", isDirectory: true)
        
        let newURL = directoryURL.appendingPathComponent(self.fileName)
        return newURL
    }
    
    var creationDate: Date {
        let fileManager = FileManager.default
        let urlPath = url.path
        let attributesDictionary = try? fileManager.attributesOfItem(atPath: urlPath)
        let creationDate = attributesDictionary?[.creationDate] as! Date
        
        return creationDate
    }
    
    init(object: NSManagedObject) {
        self.object = object
    }
    
    func setFileName(filename: String) {
        object.setValue(filename, forKey: "fileName")
    }
    
    func setTag(tag: String) {
        var tempTags = self.tags
        tempTags?.append(tag)
        object.setValue(tempTags, forKey: "tag")
    }
    
    func removeTags() {
        object.setValue(nil, forKey: "tag")
    }
}
