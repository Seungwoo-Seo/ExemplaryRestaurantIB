//
//  ReviewCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/21.
//

import UIKit

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var storeNameButton: UIButton!
    @IBOutlet weak var reviewStarScoreStackView: UIStackView!
    @IBOutlet weak var reviewDeleteButton: UIButton!
    
    @IBOutlet var imageCollectionView: UICollectionView!
    
    
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    var images: [UIImage] = []
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.isPagingEnabled = true
    }
    
    
    func setupImageCollectionView(images: [UIImage]?) {
        guard let images = images else {
            
//            imageCollectionView.reloadData()
            return
        }
        
        self.images = images
        
//        imageCollectionView.reloadData()
    }
    
}

extension ReviewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let images = self.images.count
        return images
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {return UICollectionViewCell()}
        
        let image = images[indexPath.item]
        
        cell.imageView.image = image

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
   
}
