//
//  AudioTabBarController.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 5/6/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class AudioTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioEngine.sharedInstance.delegate = self.selectedViewController as? AudioPlayerViewController
    }

}
