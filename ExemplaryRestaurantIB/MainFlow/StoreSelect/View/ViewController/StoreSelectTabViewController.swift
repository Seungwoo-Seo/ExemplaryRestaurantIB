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
        return bar
    }()
    
    // MARK: View Model
    let vm = StoreSelectViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
}

private extension StoreSelectTabViewController {
    
    func setupUI() {
        addBar(tabmanBar, dataSource: self, at: .top)
        
        self.tabmanBar.layout.transitionStyle = .snap
        self.dataSource = self
    }
    
}

// MARK: Tabman, Pageboy API
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

