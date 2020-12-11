//
//  TagCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 11/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol TagFilterDelegate: class {
    func didUpdateTagToFilter(with tag: TagModel)
}

class TagCell: UITableViewCell {

    //==================================================
    // MARK: - Properties
    //==================================================
    
    @IBOutlet var collectionView: UICollectionView!
    weak var delegate: TagFilterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
    }
    
    //==================================================
    // MARK: - Collection View Data Source
    //==================================================
    
    public func updateTagCells() {
        self.collectionView.reloadData()
    }
    
}

//==================================================
// MARK: - Collection View Data Source
//==================================================

extension TagCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let tagsDataSource =  AudioManager.sharedInstance.getAllAudioRecordingTags() else { return 0 }
        return tagsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tagsDataSource = AudioManager.sharedInstance.getAllAudioRecordingTags() else { return UICollectionViewCell() }
        
        let tagModel = tagsDataSource[indexPath.row]
        let tagModelCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        tagModelCell.setup(with: tagModel)
        return tagModelCell
    }
    
}

//==================================================
// MARK: - Collection View Data Source
//==================================================

extension TagCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tagsDataSource = AudioManager.sharedInstance.getAllAudioRecordingTags() else { return }
        let selectedTag = tagsDataSource[indexPath.row]
        delegate?.didUpdateTagToFilter(with: selectedTag)
    }
}
