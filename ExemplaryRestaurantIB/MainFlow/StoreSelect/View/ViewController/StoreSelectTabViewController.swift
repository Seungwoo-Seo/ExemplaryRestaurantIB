//
//  StoreSelectTabViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/08/19.
//

import UIKit
import Tabman
import Pageboy
import SnapKit

class StoreSelectTabViewController: TabmanViewController {
   
    // MARK: View
    lazy var tabmanBar: TMBarView<TMHorizontalBarLayout, TMLabelBarButton, TMLineBarIndicator> = {
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        
        return bar
    }()
    
    lazy var lodingView: LodingView = {
        let view = LodingView(frame: .zero)
        view.alpha = 0.0
        view.backgroundColor = .white
        
        return view
    }()
    
    
    // MARK: View Model
    let vm = StoreSelectViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
    }
    
}

// MARK: Tabman, Pageboy
extension StoreSelectTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        
        return vm.numberOfViewControllers(in: pageboyViewController)
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        return vm.viewController(for: pageboyViewController, at: index)
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        
        return vm.defaultPage(for: pageboyViewController)
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return vm.barItem(for: bar, at: index)
    }
        
}

private extension StoreSelectTabViewController {
    
    func setupUI() {
        self.dataSource = self
        addBar(tabmanBar, dataSource: self, at: .top)
    }
    
    func setupLayout() {
        [lodingView].forEach { view.addSubview($0) }
        
        lodingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
