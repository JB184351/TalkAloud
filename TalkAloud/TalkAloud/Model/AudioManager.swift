//
//  AudioManager.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 4/13/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation

class AudioManager {
    
    static let sharedInstance = AudioManager()
    
    private var audioRecording: URL!
    private var audioRecordings: [URL] = []
    
    private init() {}
    
    func getNewRecordingURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy-HH-mm-ss"

        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let uniqueFileName = "talkaloud" + "_" + dateString + ".m4a"
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent(uniqueFileName)
        audioRecordings.append(soundURL)
        
        return soundURL
    }
    
    // Return single URL
    func getSelectedRecording(selectedRecording: Int) -> URL {
        return audioRecordings[selectedRecording]
    }
    
    // TO DO: Set URL Property Method
    
    
    // Change to make it work latest recording if playing from Playback View &
    // when a recording is selected from the tableView
    func getPlaybackURL() -> URL? {
        guard let recentRecording = audioRecordings.last else { return nil }
        return recentRecording
    }
    
    // Function will all the audioRecordings when app starts up.
    func loadAudioRecordings() {
        
    }
    
    // Get count of all audioRecordings
    func getAudioRecordingCount() -> Int {
        return audioRecordings.count
    }
    
}
