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
        
        guard let viewControllers = self.viewControllers else { return }
        for viewController in viewControllers {
            if viewController is AudioPlayerViewController {
                AudioEngine.sharedInstance.delegate = viewController as? AudioPlayerViewController
                break
            }
        }
    }

}
