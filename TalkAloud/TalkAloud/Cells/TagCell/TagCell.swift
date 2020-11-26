//
//  TagCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 11/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

protocol TagFilterDelegate: class {
    func didUpdateTagToFilter(by tags: [TagModel])
}

class TagCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    private var selectedTags = [String]()
    private var tagsDataSource = [TagModel]()
    weak var delegate: TagFilterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tagCollectionViewCell")
    }
    
    //==================================================
    // MARK: - Collection View Data Source
    //==================================================
    
    public func setup(with model: [TagModel]) {
        self.tagsDataSource = model
        self.collectionView.reloadData()
    }
    
    
}

//==================================================
// MARK: - Collection View Data Source
//==================================================

extension TagCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagModel = tagsDataSource[indexPath.row]
        
        let tagModelCell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        tagModelCell.setup(with: tagModel)
        return tagModelCell
    }
    
}

//==================================================
// MARK: - Collection View Data Source
//==================================================

extension TagCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedTag = tagsDataSource[indexPath.row]
        selectedTag.isTagSelected = !selectedTag.isTagSelected
        
        tagsDataSource[indexPath.row] = selectedTag
        
        delegate?.didUpdateTagToFilter(by: tagsDataSource)
        
        self.collectionView.reloadData()
    }
}
