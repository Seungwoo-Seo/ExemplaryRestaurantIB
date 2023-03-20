//
//  StoreSelectContainerViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/17.
//

import UIKit

class StoreSelectContainerViewController: UIViewController {
    
    // MARK: @IBOutlet
    @IBOutlet var tabBar: UITabBar!
    
    // MARK: ViewModel
    let vm = StoreSelectViewModel()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: Override method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        vm.prepare(segue, sender: sender) { alert in
            guard let alert = alert else {return}
            self.present(alert, animated: true)
        }
    
    }
}

extension StoreSelectContainerViewController: UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        vm.tabBar(tabBar, didSelect: item) { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

private extension StoreSelectContainerViewController {
    
    func setupUI() {
        self.navigationItem.backButtonTitle = ""
        self.tabBar.delegate = self
    }
    
}


