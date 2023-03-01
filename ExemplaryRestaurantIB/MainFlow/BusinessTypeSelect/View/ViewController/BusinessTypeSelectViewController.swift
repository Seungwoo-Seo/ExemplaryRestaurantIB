//
//  BusinessTypeSelectViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/23.
//

import UIKit
import SnapKit

class BusinessTypeSelectViewController: UIViewController {
    
    @IBOutlet weak var headerView: BusinessTypeSelectHeaderView!
    @IBOutlet weak var collectionView: UICollectionView!

    lazy var hazyView: HazyView = {
        let view = HazyView(frame: .zero)
        view.backgroundColor = .gray
        view.alpha = 0.0
        view.delegate = self
        
        return view
    }()
    
    lazy var gooSelectView: GooSelectView = {
        let view = GooSelectView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.0
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        view.clipsToBounds = true
        view.delegate = self
        
        return view
    }()
    
    
    // MARK: ViewModel
    let vm = BusinessTypeSelectViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupNotification()
    }
    
    // MARK: actions
    @IBAction func didTapMyButton(_ sender: UIBarButtonItem) {
        vm.didTapMyButton(sender) {
            self.navigationController?.pushViewController($0, animated: true)
        }
    }
    
    @IBAction func didTapGooSelectButton(_ sender: UIButton) {
        vm.didTapGooSelectButton(sender, vc: self)
    }
    
    @objc func didTapNavigationBar(_ sender: UINavigationBar) {
        vm.didTapNavigationBar(sender, vc: self)
    }
    
}

// MARK: searchBar
extension BusinessTypeSelectViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        vm.searchBarTextDidBeginEditing(searchBar) {
            self.navigationController?.pushViewController($0, animated: true)
        }
    }
    
}

// MARK: gooSelectView
extension BusinessTypeSelectViewController: BottomSheetDelegate {
    
    func didTapHazyView(_ tapGesture: UITapGestureRecognizer) {
        vm.didTapHazyView(tapGesture, vc: self)
    }
    
    func didTapCancelButton(_ button: UIButton) {
        vm.didTapCancelButton(button, vc: self)
    }
    
    func didTapTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.didTapTableView(tableView, didSelectRowAt: indexPath, vc: self)
    }
    
}

// MARK: collectionView
extension BusinessTypeSelectViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return vm.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return vm.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        vm.collectionView(collectionView, didSelectItemAt: indexPath) {
            self.navigationController?.pushViewController($0, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return vm.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        vm.collectionView(collectionView, didHighlightItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        
        vm.collectionView(collectionView, didUnhighlightItemAt: indexPath)
    }
    
}

private extension BusinessTypeSelectViewController {
    
    func setupUI() {
        self.navigationItem.backButtonTitle = "홈"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        let navigationBarTap = UITapGestureRecognizer(target: self, action: #selector(didTapNavigationBar(_:)))
        navigationController?.navigationBar.addGestureRecognizer(navigationBarTap)
        
        // headerView.searchBar
        headerView.searchBar.searchBarStyle = .minimal
        headerView.searchBar.searchTextField.backgroundColor = .white
        
        // collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupLayout() {
        [
            hazyView,
            gooSelectView
        ].forEach { view.addSubview($0) }
        
        hazyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        gooSelectView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupNotification() {
        vm.setupNotification(collectionView)
    }
        
}
