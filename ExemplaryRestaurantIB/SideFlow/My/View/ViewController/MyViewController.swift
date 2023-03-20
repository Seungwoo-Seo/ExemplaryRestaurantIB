//
//  SetupTableViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyViewController: UITableViewController {
    
    // MARK: IBOutlet
    @IBOutlet var changeLabel: UILabel!
    
    
    // MARK: ViewModel
    let vm = MyViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                    
        vm.viewWillAppear(changeLabel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        vm.removeStateDidChangeListener()
    }
    
    
    // MARK: override
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        vm.tableView(tableView, didSelectRowAt: indexPath) { [weak self] vc, pp in
            
            switch pp {
            case .push:
                self?.navigationController?.pushViewController(vc, animated: true)
            case .present:
                self?.present(vc, animated: true)
            }
        }

    }
    
    
    // MARK: @IBActions
    @IBAction func didTapHomeButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

private extension MyViewController {
    
    func setupUI() {
        self.navigationItem.title = "My"
    }

    func setupLayout() {
        
    }
        
}
