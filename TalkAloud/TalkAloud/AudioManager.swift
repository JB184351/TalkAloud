//
//  AudioManager.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/11/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation

class AudioManager {

    
    // Gets a new URL to record to
    func getNewRecordingURL() -> URL {
        return
    }
    
    // Get the selected file we want to play
    func getFileTooPlayURL() -> URL {
        return URL
    }
    
    // Creates a unique filename every time for whenever audio is recorded
       func makeUniqueFileName() -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm-ss"
           
           let date = Date()
           let dateString = dateFormatter.string(from: date)
           let uniqueFileName = fileName + "_" + dateString + ".m4a"
           
           return uniqueFileName
       }
}
