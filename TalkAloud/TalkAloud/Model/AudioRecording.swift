//
//  AudioRecording.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 6/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation
import CoreData

struct AudioRecording: Equatable {
    
    //==================================================
    // MARK: - Private Properties
    //==================================================
    
    private var object: NSManagedObject
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    public var fileName: String {
        return object.value(forKey: "fileName") as! String
    }
    
    public var tags: [String]? {
        return object.value(forKey: "tag") as? [String] ?? []
    }
    
    public var url: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let directoryURL = documentDirectory.appendingPathComponent("TalkAloud", isDirectory: true)
        
        let newURL = directoryURL.appendingPathComponent(self.fileName)
        return newURL
    }
    
    public var creationDate: Date {
        let fileManager = FileManager.default
        let urlPath = url.path
        let attributesDictionary = try? fileManager.attributesOfItem(atPath: urlPath)
        let creationDate = attributesDictionary?[.creationDate] as! Date
        
        return creationDate
    }
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init(object: NSManagedObject) {
        self.object = object
    }
    
    //==================================================
    // MARK: - Public Methods
    //==================================================
    
    public func setFileName(filename: String) {
        object.setValue(filename, forKey: "fileName")
    }
    
    public func setTag(tag: String) {
        var tempTags = self.tags
        tempTags?.append(tag)
        object.setValue(tempTags, forKey: "tag")
    }
    
    public func removeTags() {
        object.setValue(nil, forKey: "tag")
    }
    
    //==================================================
    // MARK: - Private Methods
    //==================================================
    
    static private func == (lhs: AudioRecording, rhs: AudioRecording) -> Bool {
        return lhs.object == rhs.object && lhs.tags == rhs.tags && lhs.fileName == rhs.fileName
    }
    
}
