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

    // 업태명 배열
    var businessTypeList: [String] = []
    // 해당 업태명과 매칭해 줄 이미지 이름들
    let businessTypeImageList = [
        "한식": "bibimbap",
        "경양식": "tonkatsu",
        "기타": "guitar",
        "중국식": "mando",
        "일식": "sushi",
        "뷔페식": "buffet",
        "식육(숯불구이)": "meat",
        "외국음식전문점(인도,태국등)": "salnoodle",
        "호프/통닭": "beer",
        "분식": "tteokbokki",
        "복어취급": "pufferfish",
        "탕류(보신용)": "seolleongtang",
        "회집": "fish",
        "패스트푸드": "hamburger",
        "통닭(치킨)": "chicken",
        "정종/대포집/소주방": "soju",
        "냉면집": "naengmyeon",
        "공공기관": "public",
        "까페": "cafe",
        "김밥(도시락)": "kimbap",
        "산업체": "industry",
        "패밀리레스트랑": "restaurant"
    ]
    // 현재 행정구 명과 코드
    var nowGooType: (gooName: String, gooCode: String?) = ("서울전체", nil)
    // 해당 행정구명과 매칭해 줄 행정구 별 코드
    let gooTypeList: [(gooName: String, gooCode: String?)] = [
        ("서울전체", nil),
        ("강남구", "3220000"),
        ("강동구", "3240000"),
        ("강북구", "3080000"),
        ("강서구", "3150000"),
        ("관악구", "3200000"),
        ("광진구", "3040000"),
        ("구로구", "3160000"),
        ("금천구", "3170000"),
        ("노원구", "3100000"),
        ("도봉구", "3090000"),
        ("동대문구", "3050000"),
        ("동작구", "3190000"),
        ("마포구", "3130000"),
        ("서대문구", "3120000"),
        ("서초구", "3210000"),
        ("성동구", "3030000"),
        ("성북구", "3070000"),
        ("송파구", "3230000"),
        ("양천구", "3140000"),
        ("영등포구", "3180000"),
        ("용산구", "3020000"),
        ("은평구", "3110000"),
        ("종로구", "3000000"),
        ("중구", "3010000"),
        ("중랑구", "3060000")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupNotification()
    }

    deinit {
        removeNotification()
    }

    @objc func fetchDataCompleted() {
        self.createModel_businessTypeList()
        collectionView.reloadData()
    }
    
    // MARK: actions
    @IBAction func didTapMyButton(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyViewController") as? MyViewController else {return}
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapGooSelectButton(_ sender: UIButton) {
        gooSelectView.nowGooType = self.nowGooType
        gooSelectView.gooTypeList = gooTypeList
        gooSelectView.tableView.reloadData()

        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = false }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }

        gooSelectView.snp.remakeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.6)
            make.leading.trailing.bottom.equalToSuperview()
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self = self else {return}
            self.hazyView.alpha = 0.5
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func didTapNavigationBar(_ sender: UINavigationBar) {
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }

        gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self = self else {return}
            self.hazyView.alpha = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: searchBar
extension BusinessTypeSelectViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {return}

        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: gooSelectView
extension BusinessTypeSelectViewController: BottomSheetDelegate {
    
    func didTapHazyView(_ tapGesture: UITapGestureRecognizer) {
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }

        gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self = self else {return}
            self.hazyView.alpha = 0.0
        }
    }
    
    func didTapCancelButton(_ button: UIButton) {
        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }

        gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) { [weak self] in
            guard let self = self else {return}
            self.hazyView.alpha = 0.0
        }
    }
    
    func didTapTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nowGooType = gooTypeList[indexPath.row]
        updateModel_nowGooType(nowGooType: nowGooType)

        navigationItem.leftBarButtonItems?.forEach { $0.isEnabled = true }
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }

        gooSelectView.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.leading.trailing.bottom.equalToSuperview()
        }

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            guard let self = self else {return}
            self.hazyView.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                tableView.reloadData()
                self.collectionView.reloadData()
                self.headerView.gooSelectButton.setTitle(nowGooType.gooName, for: .normal)
            }
        }
    }
    
}

// MARK: collectionView
extension BusinessTypeSelectViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return businessTypeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessTypeCell", for: indexPath) as? BusinessTypeCell else {return UICollectionViewCell()}

        let businessType = businessTypeList[indexPath.item]
        let imageName = businessTypeImageList[businessType] ?? ""

        cell.businessTypeImageView.image = UIImage(named: imageName)
        cell.businessTypeLabel.text = businessType

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "StoreSelectContainerViewController") as? StoreSelectContainerViewController else {return}

        let businessTypeList = businessTypeList
        let currentBusinessType = businessTypeList[indexPath.item]
        let nowGooType = nowGooType

//        createModel(businessTypeList: businessTypeList,
//                    currentBusinessType: currentBusinessType,
//                    nowGooType: nowGooType)

        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 10
        let inset: CGFloat = 10
        let width: CGFloat = (collectionView.frame.width - inset*2 - itemSpacing*2) / 3
        let height: CGFloat = width

        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BusinessTypeCell else {return}

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveLinear], animations: { cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) })
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BusinessTypeCell else {return}

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 3, options: [.curveLinear], animations: { cell.transform = CGAffineTransform(scaleX: 1, y: 1) })
    }
    
}

private extension BusinessTypeSelectViewController {
    // MARK: create
    func createModel_businessTypeList() {
        guard !NetworkManager.shared.storeList.isEmpty else {return}

        let businessTypeList = NetworkManager.shared.storeList.map { store in
            return store.businessType
        }

        var set = Set<String>()

        for businessType in businessTypeList {
            guard let businessType = businessType else {return}

            set.insert(businessType)
        }

        self.businessTypeList = Array(set)
    }

    // MARK: update
    func updateModel_businessTypeList(storeList: [Store]) {
        let businessTypeList = storeList.map { store in
            return store.businessType
        }

        var set = Set<String>()

        for businessType in businessTypeList {
            guard let businessType = businessType else {return}

            set.insert(businessType)
        }

        self.businessTypeList = Array(set)
    }

    func updateModel_nowGooType(nowGooType: (gooName: String, gooCode: String?)) {
        // 여기서 스토어도 바꿔줘야함
        // 예를 들어서
        guard let gooCode = nowGooType.gooCode else {
            createModel_businessTypeList()
            self.nowGooType = nowGooType
            return
        }

        // 지금 선택한게 은평구야
        // ("은평구", 3030490349)
        let storeList = NetworkManager.shared.storeList.filter { store in
            store.gooCode == gooCode
        }

        updateModel_businessTypeList(storeList: storeList)
        self.nowGooType = nowGooType
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchDataCompleted),
            name: NSNotification.Name("fetchDataCompleted"),
            object: nil
        )
    }

    func removeNotification() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("fetchDataCompleted"),
            object: nil
        )
    }

}
