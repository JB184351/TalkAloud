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
    var object: NSManagedObject
    var fileName: String
    var tags: String
}
