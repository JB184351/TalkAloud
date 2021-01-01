//
//  MoreOptionsPresentationManager.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 1/1/21.
//  Copyright © 2021 Justin Bengtson. All rights reserved.
//

import UIKit

class MoreOptionsPresentationManager: NSObject {

}

extension MoreOptionsPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = MoreOptionsPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
}
