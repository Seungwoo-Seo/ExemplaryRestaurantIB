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
        
        vm.prepare(for: segue,
                   sender: sender,
                   vm: self.vm)
    }
    
}

private extension StoreSelectContainerViewController {
    
    func setupUI() {
        self.tabBar.delegate = self
    }
    
}

extension StoreSelectContainerViewController: UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let title =  item.title else {return}
        
        switch title {
        case "검색":
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {return}
            print("실행")
            
            navigationController?.pushViewController(vc, animated: true)
            
        case "찜":
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "JjimViewController") as? JjimViewController else {return}
        
            navigationController?.pushViewController(vc, animated: true)
            
        case "리뷰내역":
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else {return}
            
            navigationController?.pushViewController(vc, animated: true)
            
        case "My":
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyViewController") as? MyViewController else {return}
            
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            print(title)
        }
    }
    
}




