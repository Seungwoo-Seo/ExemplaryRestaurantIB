//
//  StoreReviewCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/10.
//

import UIKit
import Cosmos
import SnapKit

class StoreReviewCell: UITableViewCell {

    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        
        return label
    }()
    
    lazy var cosmosView: CosmosView = {
        let cosmosView = CosmosView()
        cosmosView.settings.updateOnTouch = false
        cosmosView.settings.filledColor = .yellow
        cosmosView.settings.filledBorderColor = .black
        cosmosView.settings.emptyBorderColor = .black
        cosmosView.settings.totalStars = 5

        return cosmosView
    }()
    
    lazy var storeReviewImageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StoreReviewImageCell.self, forCellWithReuseIdentifier: "StoreReviewImageCell")
        
        return collectionView
    }()
    
    lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.pageIndicatorTintColor = .gray
        control.currentPageIndicatorTintColor = .white
        control.hidesForSinglePage = true
        
        return control
    }()
    
    lazy var storeReviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.numberOfLines = 0
        
        return label
    }()

    
    // MARK: ViewModel
    let vm = StoreReviewViewModel()
    
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        vm.prepareForReuse(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension StoreReviewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return vm.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return vm.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return vm.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        vm.scrollViewWillEndDragging(scrollView,
                                     withVelocity: velocity,
                                     targetContentOffset: targetContentOffset,
                                     pageControl: pageControl)
    }
    
}

private extension StoreReviewCell {
        
    func setupLayout() {
        [
            userNameLabel,
            cosmosView,
            storeReviewImageCollectionView,
            pageControl,
            storeReviewLabel
        ].forEach { contentView.addSubview($0) }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.greaterThanOrEqualToSuperview()
        }
        
        cosmosView.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom)
            make.leading.equalTo(userNameLabel.snp.leading)
            make.trailing.greaterThanOrEqualToSuperview()
        }
        
        storeReviewImageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(cosmosView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(0)
        }
        
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.equalTo(storeReviewImageCollectionView)
            make.bottom.equalTo(storeReviewImageCollectionView.snp.bottom)
        }

        storeReviewLabel.snp.makeConstraints { make in
            make.top.equalTo(storeReviewImageCollectionView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
}
