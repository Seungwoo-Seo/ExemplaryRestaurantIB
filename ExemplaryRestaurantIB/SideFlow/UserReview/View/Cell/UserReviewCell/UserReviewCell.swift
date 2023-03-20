//
//  UserReviewCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/10/21.
//

import UIKit
import Cosmos
import SnapKit

class UserReviewCell: UITableViewCell {
    
    // MARK: View
    lazy var storeNameButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 17.0, weight: .bold)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(didTapStoreNameButton(_:)), for: .touchUpInside)
        
        return button
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
    
    lazy var userReviewDeleteButton: UIButton = {
        let button = UIButton()
        let config = UIButton.Configuration.gray()
        let handler: UIButton.ConfigurationUpdateHandler = { button in
            button.configuration?.title = "삭제"
            button.configuration?.baseForegroundColor = .black
        }
        button.configuration = config
        button.configurationUpdateHandler = handler
        button.addTarget(self, action: #selector(didTapUserReviewDeleteButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var userReviewImageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserReviewImageCell.self, forCellWithReuseIdentifier: "UserReviewImageCell")
        
        return collectionView
    }()
    
    lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.pageIndicatorTintColor = .gray
        control.currentPageIndicatorTintColor = .white
        control.hidesForSinglePage = true
        
        return control
    }()
    
    lazy var userReviewTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17.0, weight: .regular)
        label.numberOfLines = 0
        
        return label
    }()
    
    
    // MARK: ViewModel
    let vm = UserReviewViewModel()
    
    
    // MARK: delegate
    weak var delegate: UserReviewCellDelegate?
    
    
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
    
    
    @objc func didTapStoreNameButton(_ sender: UIButton) {
        delegate?.didTapStoreNameButton(sender, cell: self)
    }
    
    @objc func didTapUserReviewDeleteButton(_ sender: UIButton) {
        delegate?.didTapUserReviewDeleteButton(sender, cell: self)
    }
              
}

// MARK: imageCollectionViewExtension
extension UserReviewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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

private extension UserReviewCell {
    
    func setupLayout() {
        [
            storeNameButton,
            cosmosView,
            userReviewDeleteButton,
            userReviewImageCollectionView,
            pageControl,
            userReviewTextLabel
        ].forEach { contentView.addSubview($0) }
        
        storeNameButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualTo(userReviewDeleteButton.snp.leading)
        }
        
        cosmosView.snp.makeConstraints { make in
            make.top.equalTo(storeNameButton.snp.bottom)
            make.leading.equalTo(storeNameButton.snp.leading)
            make.trailing.lessThanOrEqualTo(userReviewDeleteButton.snp.leading)
        }
        
        userReviewDeleteButton.snp.makeConstraints { make in
            make.top.equalTo(storeNameButton.snp.bottom)
            make.trailing.equalToSuperview().inset(20)
        }
        
        userReviewImageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(userReviewDeleteButton.snp.bottom).offset(5)
            make.leading.equalTo(cosmosView.snp.leading)
            make.trailing.equalTo(userReviewDeleteButton.snp.trailing)
            make.height.equalTo(0)
        }
        
        pageControl.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(userReviewImageCollectionView)
        }
        
        userReviewTextLabel.snp.makeConstraints { make in
            make.top.equalTo(userReviewImageCollectionView.snp.bottom)
            make.leading.trailing.equalTo(userReviewImageCollectionView)
            make.bottom.equalToSuperview().inset(10)
        }
        
    }
    
}
