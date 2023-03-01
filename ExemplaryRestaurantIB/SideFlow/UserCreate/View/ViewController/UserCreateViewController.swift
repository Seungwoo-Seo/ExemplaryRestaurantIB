//
//  UserCreateViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/23.
//

import UIKit
import SnapKit
import Lottie

// 회원가입 화면
class UserCreateViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailOverlapCheckButton: UIButton!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordAgainLabel: UILabel!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var userCreateButton: UIButton!
    
    // MARK: View
    lazy var emailCheckAnimationView: AnimationView = {
        let animationView = AnimationView(name: "checkmark")
        animationView.animationSpeed = 1.0
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFit
        
        return animationView
    }()
    
    lazy var passwordCheckAnimationView: AnimationView = {
        let animationView = AnimationView(name: "checkmark")
        animationView.animationSpeed = 1.0
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFit
        
        return animationView
    }()
        
    
    // MARK: ViewModel
    let vm = UserCreateViewModel()
    
    
    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        vm.touchesBegan(touches, with: event, vc: self)
    }
    
    
    // MARK: @IBActions
    @IBAction func didTapBackButton(_ sender: UIButton) {
        
        vm.didTapBackButton(sender) {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapEmailOverlapCheckButton(_ sender: UIButton) {
        
        vm.didTapEmailOverlapCheckButton(sender, animationView: emailCheckAnimationView) { alert in
            self.present(alert, animated: true)
        }
    }
        
    @IBAction func didTapUserCreateButton(_ sender: UIButton) {
        
        vm.didTapUserCreateButton(sender, nameTextField: nameTextField, vc: self) { alert in
            self.present(alert, animated: true)
        }
    }
    
}

extension UserCreateViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        vm.textField(textField, shouldChangeCharactersIn: range, replacementString: string, overlapButton: emailOverlapCheckButton, animationView: passwordCheckAnimationView)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        vm.textFieldDidEndEditing(textField) { alert in
            self.present(alert, animated: true)
        }
    }
    
    
}

private extension UserCreateViewController {
    
    func setupUI() {
        emailTextField.tag = 0
        passwordTextField.tag = 1
        passwordAgainTextField.tag = 2
        nameTextField.tag = 3
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.placeholder = "비밀번호는 8-20자 이내 영어, 숫자, 특수문자 포함"
        passwordAgainTextField.delegate = self
        passwordAgainTextField.placeholder = "비밀번호는 8-20자 이내 영어, 숫자, 특수문자 포함"
        nameTextField.delegate = self
        nameTextField.placeholder = "한글만 가능"
        
        emailOverlapCheckButton.isEnabled = false
    }
    
    func setupLayout() {
        [emailCheckAnimationView, passwordCheckAnimationView].forEach { view.addSubview($0) }
        
        emailCheckAnimationView.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.top)
            make.leading.equalTo(emailLabel.snp.trailing).offset(10)
            make.height.equalTo(emailLabel)
            make.width.equalTo(emailCheckAnimationView.snp.height)
        }
        
        passwordCheckAnimationView.snp.makeConstraints { make in
            make.top.equalTo(passwordAgainLabel.snp.top)
            make.leading.equalTo(passwordAgainLabel.snp.trailing).offset(10)
            make.height.equalTo(passwordAgainLabel)
            make.width.equalTo(passwordAgainLabel.snp.height)
        }
        
    }
    
}
