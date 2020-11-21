//
//  TagCell.swift
//  TalkAloud
//
//  Created by Justin Bengtson on 11/17/20.
//  Copyright © 2020 Justin Bengtson. All rights reserved.
//

import UIKit

class TagCell: UITableViewCell {

    @IBOutlet var collectionView: UICollectionView!
    private var tagsDataSource = [TagModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionViewCell")
    }

    // Will actually need this most likely
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //==================================================
    // MARK: - Collection View Data Source
    //==================================================
    
    public func setup(with model: [TagModel]) {
        let uniqueTags = Set(model)
        let tags: [TagModel] = Array(uniqueTags)
        
        self.tagsDataSource = tags
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
        let tag = tagsDataSource[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! TagCollectionViewCell
        cell.setup(with: tag)
        return cell
    }
    
}

//==================================================
// MARK: - Collection View Data Source
//==================================================

extension TagCell: UICollectionViewDelegate {
    
}
