//
//  TagCollectionViewTableViewCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 1/16/21.
//  Copyright © 2021 Justin Bengtson. All rights reserved.
//

import UIKit

protocol TagFilterDelegate: class {
    func didUpdateTagToFilter(with tag: TagModel)
}

class TagCollectionViewTableViewCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    weak var delegate: TagFilterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "NewTagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "newCollectionViewCell")
    }
    
    public func updateTagCells() {
        self.collectionView.reloadData()
    }
    
}

extension TagCollectionViewTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tagsDataSource =  AudioManager.sharedInstance.getAllAudioRecordingTags() else { return 0 }
        return tagsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tagsDataSource = AudioManager.sharedInstance.getAllAudioRecordingTags() else { return UICollectionViewCell() }
        
        let tagModel = tagsDataSource[indexPath.row]
        let tagModelCell = collectionView.dequeueReusableCell(withReuseIdentifier: "newCollectionViewCell", for: indexPath) as! NewTagCollectionViewCell
        tagModelCell.setup(with: tagModel)
        return tagModelCell
    }
    
    
}

extension TagCollectionViewTableViewCell: UICollectionViewDelegate {
    
}
