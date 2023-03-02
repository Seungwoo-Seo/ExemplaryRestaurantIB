//
//  BusinessTypeSelectViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/23.
//

import UIKit
import SnapKit

class BusinessTypeSelectViewController: UIViewController {
    
    // headerView
    @IBOutlet weak var headerView: BusinessTypeSelectHeaderView!
    
    // collectionView
    @IBOutlet weak var collectionView: UICollectionView!
    
    // hazyView
    lazy var hazyView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        return view
    }()
    
    // button sheet
    lazy var gooSelectView: GooSelectView = {
        let view = GooSelectView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.0
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
        view.clipsToBounds = true
        
        return view
    }()
    
    
    
    // MARK: ViewModel
    let vm = BusinessTypeSelectViewModel()
    
    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupGesture()
        setupObserver()
    }
    
    // MARK: @IBActions
    // gooSelectButton
    @IBAction func didTapGooSelectButton(_ sender: UIButton) {
        showBottomSheet()
    }
    
    // businessTypeSortButton
    @IBAction func didTapBusinessTypeSortButton(_ sender: UIButton) {
        
    }
}

private extension BusinessTypeSelectViewController {
    
    private func setupUI() {
        // navigationBar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        self.navigationController?.navigationBar.tintColor = .white
  
        
        // headerView.searchBar
        headerView.searchBar.searchBarStyle = .minimal
        if let textfield = headerView.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.placeholder = "모범음식점을 검색하세요."
            textfield.backgroundColor = UIColor.white
        }
        
        
        // collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // hazyView
        hazyView.alpha = 0.0
        
        // gooSelectView.tableView
        gooSelectView.tableView.dataSource = self
        gooSelectView.tableView.delegate = self
        
        // gooSelectView.cancleButton
        gooSelectView.cancleButton.addTarget(self, action: #selector(didTapCancleButton(_:)), for: .touchUpInside)
        
    }
    
    private func setupLayout() {
        [
            hazyView,
            gooSelectView
        ].forEach { view.addSubview($0) }
        
        // hazyView
        hazyView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view)
        }
        
        // bottomSheet
        gooSelectView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(view.bounds.height)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    private func setupGesture() {
       setupGesture_hazyView()
    }
    
    // 이 부분 -> vm에 있는게 맞는건가
    private func setupObserver() {
        vm.addObserver(self.collectionView)
    }
    
}

// MARK: headerView.searchBar
extension BusinessTypeSelectViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {return}
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: self.collectionView
extension BusinessTypeSelectViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return vm.configure_collectionView(collectionView,
                                           numberOfItemsInSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return vm.configure_collectionView(collectionView,
                                           cellForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        vm.configure_collectionView(collectionView,
                                    didSelectItemAt: indexPath) { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return vm.configure_collectionView(collectionView,
                                           layout: collectionViewLayout,
                                           sizeForItemAt: indexPath)
    }
    
}

// MARK: hazyView, bottomSheet ----> 이 extension 이 view 영역에 있는게 맞는건가..확신이 안듬
extension BusinessTypeSelectViewController {
    
    func setupGesture_hazyView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapHazyView(_:)))
        hazyView.addGestureRecognizer(tap)
        hazyView.isUserInteractionEnabled = true
    }
    
    func showBottomSheet() {
        gooSelectView.snp.updateConstraints { make in
            make.top.equalTo(view.bounds.height * 2/5)
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.hazyView.alpha = 0.5
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideBottomSheet() {
        gooSelectView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(view.bounds.height)
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            self?.hazyView.alpha = 0.0
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            if self?.presentingViewController != nil {
                self?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @objc func didTapHazyView(_ tapGesture: UITapGestureRecognizer) {
        hideBottomSheet()
    }
    
    @objc func didTapCancleButton(_ button: UIButton) {
        hideBottomSheet()
    }
    
}

// MARK: gooSelectView.tableView
extension BusinessTypeSelectViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.configure_tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return vm.configure_tableView(tableView,
                                      cellForRowAt: indexPath,
                                      headerView: headerView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.configure_tableView(tableView,
                               didSelectRowAt: indexPath,
                               hideView: hideBottomSheet) { [weak self] gooName in
            self?.headerView.gooSelectButton.setTitle(gooName, for: .normal)
            self?.collectionView.reloadData()
        }
    }
    
}


