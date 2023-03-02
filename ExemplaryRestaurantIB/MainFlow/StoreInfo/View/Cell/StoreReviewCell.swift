//
//  StoreReviewCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/10.
//

import UIKit
import SnapKit

class StoreReviewCell: UITableViewCell {

    // MARK: View
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "profile")
        
        return imageView
    }()

    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "탈무드"
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        
        return label
    }()
    
    lazy var starScoreStackView: StarScoreStackView = {
        let stackView = StarScoreStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 0.0
        
        return stackView
    }()
    
    lazy var userReviewImageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ReviewImageCell.self, forCellWithReuseIdentifier: "ReviewImageCell")
        
        return collectionView
    }()
    
    lazy var userReviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "asdfasdfasdfasdfasdfasdfasdasdf"
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.numberOfLines = 0
        
        return label
    }()
    
    
    // MARK: ViewModel
    let vm = StoreInfoViewModel()
    
    
    // MARK: init
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
        print("요기요")
        print(self.vm.reviewImageList.count)
        return self.vm.reviewImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewImageCell", for: indexPath) as? ReviewImageCell else {return UICollectionViewCell()}
        
        self.vm.configure_ReviewImageCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
}

private extension StoreReviewCell {
        
    func setupLayout() {
        [
            profileImageView,
            userNameLabel,
            starScoreStackView,
            userReviewImageCollectionView,
            userReviewLabel
        ].forEach { contentView.addSubview($0) }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.equalTo(starScoreStackView.snp.trailing)
        }
        
        starScoreStackView.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom)
            make.leading.equalTo(userNameLabel.snp.leading)
        }
        
        userReviewImageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.leading.equalTo(profileImageView.snp.leading)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        userReviewLabel.snp.makeConstraints { make in
            make.top.equalTo(userReviewImageCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(userReviewImageCollectionView.snp.leading)
            make.trailing.equalTo(userReviewImageCollectionView.snp.trailing)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
}

