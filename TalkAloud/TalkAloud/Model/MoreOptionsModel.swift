//
//  MoreOptionsModel.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 8/22/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import Foundation

struct MoreOptionsModel {
    
    //==================================================
    // MARK: - Public Properties
    //==================================================
    
    public var title: String?
    public var icon: String?
    public var action: () -> Void
    
}
