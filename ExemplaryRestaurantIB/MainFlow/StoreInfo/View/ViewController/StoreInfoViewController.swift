//
//  StoreInfoViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/10.
//

import UIKit
import SnapKit

final class StoreInfoViewController: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet var tableView: StoreTableView!
    
    // MARK: View
    lazy var reviewButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "리뷰 작성하기"
        button.style = .plain
        button.tintColor = .white
        button.target = self
        button.action = #selector(didTapReviewButton(_:))
        
        return button
    }()
    
    
    // MARK: ViewModel
    let vm = StoreInfoViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        
        vm.createModel_coordinate { [weak self] result in
            if result {
                self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            } else {
                let alert = UIAlertController(title: "지도실패", message: nil, preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(confirm)
                self?.present(alert, animated: true)
            }
        }
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.vm.createModel_handle()
        
        self.vm.createModel_FinalStoreReviewList { [weak self] review in
            if review {
                // 일단 이 스토어에 리뷰 있음
                print("확인해보자-1")
                self?.tableView.reloadData()
            } else {
                print("확인해보자-2")
                // 걍 이 스토어에는 리뷰 자체가 없음
                //             self?.storeRootView.tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.vm.deleteModel_handle()
    }
    
}

private extension StoreInfoViewController {
    
    func setupUI() {
        // tableView
        tableView.register(MapCell.self, forCellReuseIdentifier: "MapCell")
        tableView.register(StoreInfoCell.self, forCellReuseIdentifier: "StoreInfoCell")
        tableView.register(StoreReviewCell.self, forCellReuseIdentifier: "StoreReviewCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupLayout() {
        self.navigationItem.rightBarButtonItem = reviewButton
    }
}

// MARK: tableView extension
extension StoreInfoViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.numberOfSections(in: tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vm.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return vm.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return vm.tableView(tableView, heightForRowAt: indexPath)
    }
    
}

extension StoreInfoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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

// MARK: CellDelegate
extension StoreInfoViewController: StoreInfoCellDelegate {
    
    
    // MARK: StoreInfoCellDelegate
    func storeInfoCell(nameLabel: UILabel) {
//        nameLabel.text = self.vm.storeName
    }
    
    func storeInfoCell(evaluationStackView: SuperStoreEvaluationStackView) {
        
        guard let stackView = evaluationStackView.arrangedSubviews[0] as? UIStackView else {return}
        
        let starScore = 3
        
        for star in 0..<starScore {
            let imageView = stackView.arrangedSubviews[star] as? UIImageView ?? UIImageView()
            imageView.image = UIImage(systemName: "star.fill")
            imageView.tintColor = .yellow
        }
    }
    
    func storeInfoCell(buttonStackView: ButtonStackView) {
        buttonStackView.jjimButton.addTarget(self, action: #selector(didTapJjimButton(_:)), for: .touchUpInside)
    }
    
    @objc func didTapJjimButton(_ sender: UIButton) {
        if let _ = self.vm.userUID {
            if sender.isSelected {
                sender.isSelected = !sender.isSelected
                self.vm.deleteRef_userJjim()
            } else {
                sender.isSelected = !sender.isSelected
                self.vm.createRef_userJjim()
            }
        } else {
            let alert = UIAlertController(title: "로그인 후 사용할 수 있습니다.", message: nil, preferredStyle: .alert)
            let cancle = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(cancle)
            
            self.present(alert, animated: true)
        }
    }
    
    func storeInfoCell(infoStackView: SuperStoreInfoStackView) {
        
        for stackView in infoStackView.arrangedSubviews {
            guard let stackView = stackView as? UIStackView else {return}
            
            switch stackView {
            case stackView as? StoreInfoStackView0:
                guard let stackView0 = stackView as? StoreInfoStackView0 else {return}
//                stackView0.storeMainMenuLabel.text = self.vm.storeMainMenu
                
            case stackView as? StoreInfoStackView1:
                guard let stackView1 = stackView as? StoreInfoStackView1 else {return}
//                stackView1.storeSelectDayLabel.text = self.vm.storeSelectDay
                
            case stackView as? StoreInfoStackView2:
                guard let stackView2 = stackView as? StoreInfoStackView2 else {return}
//                stackView2.storeAddressLabel.text = self.vm.storeAddress
                
            case stackView as? StoreInfoStackView3:
                guard let stackView3 = stackView as? StoreInfoStackView3 else {return}
//                stackView3.storeRoadAddressLabel.text = self.vm.storeRoadAddress
                
            default:
                print("x")
            }
            
        }
    }
    
}


// MARK: for setupUI
private extension StoreInfoViewController {
        
    @objc func didTapReviewButton(_ sender: UIButton) {
        if let _ = self.vm.userUID {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewWriteViewController") as? ReviewWriteViewController else {return}
        
//            vc.vm.createModel_storeName(storeName: self.vm.storeName)
//            vc.vm.createModel_storeUID(storeUID: self.vm.storeUID)
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "로그인 후 사용할 수 있습니다.", message: nil, preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true)
        }
    }

    
}

