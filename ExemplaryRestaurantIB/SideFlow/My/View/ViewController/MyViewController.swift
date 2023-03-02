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
    
    // MARK: View
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        
        // 기타 옵션
        activityIndicator.color = .purple
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        
        // stopAnimating을 걸어주는 이유는, 최초에 해당 indicator가 선언되었을 때, 멈춘 상태로 있기 위해서
        activityIndicator.startAnimating()
        
        return activityIndicator
    }()
    
    // MARK: ViewModel
    let vm = MyViewModel()
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        self.vm.createModel_handle { [weak self] result in
            guard let self = self else {return}
            if result {
                self.vm.readRef_userName { userName in
                    self.changeLabel.text = "\(userName)님 안녕하세요."
                }
            } else {
                self.changeLabel.text = "로그인 해주세요."
                self.vm.deleteModel_userUID()
            }
            
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.vm.deleteModel_handle()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath)
        
        if self.vm.userUID != nil {
            switch cell {
            case is Cell0:
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "MyChangeViewController") as? MyChangeViewController else {return}
                self.navigationController?.pushViewController(vc, animated: true)
                
            case is Cell1:
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "JjimViewController") as? JjimViewController else {return}
                self.navigationController?.pushViewController(vc, animated: true)
                
            case is Cell2:
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else {return}
                self.navigationController?.pushViewController(vc, animated: true)
                
            default:
                let alert = UIAlertController(title: "준비중", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                self.present(alert, animated: true)
            }
        } else {
            switch cell {
            case is Cell0:
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {return}
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            
            case is Cell1:
                let alert = UIAlertController(title: "로그인 시 이용 가능합니다.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                self.present(alert, animated: true)
                
            case is Cell2:
                let alert = UIAlertController(title: "로그인 시 이용 가능합니다.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                present(alert, animated: true)
                
            default:
                let alert = UIAlertController(title: "준비중", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))
                self.present(alert, animated: true)
            }
        }
        
    }
    
    
    // MARK: @IBActions
    @IBAction func didTapHomeButton(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: Setup
extension MyViewController: Setup {
    
    func setupUI() {
        setupUI_navigation()
        setupUI_activityIndicator()
    }
    
    func setupLayout() {
        
    }
    
    func setupGesture() {
        
    }
    
}

// MARK: for setupUI
private extension MyViewController {
    
    func setupUI_navigation() {
        self.navigationItem.title = "My"
    }
    
    func setupUI_activityIndicator() {
        self.view.addSubview(activityIndicator)
    }
}


