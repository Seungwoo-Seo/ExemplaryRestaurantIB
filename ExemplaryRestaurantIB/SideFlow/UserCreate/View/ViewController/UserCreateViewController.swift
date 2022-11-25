//
//  UserCreateViewController.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/23.
//

import UIKit

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
    
    @IBOutlet weak var birthDayLabel: UILabel!
    @IBOutlet weak var birthDayTextField: UITextField!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderMaleButton: RadioButton!
    @IBOutlet weak var genderFemaleButton: RadioButton!
    
    @IBOutlet weak var cellphoneLabel: UILabel!
    @IBOutlet weak var cellphoneTextField: UITextField!

    @IBOutlet weak var userCreateButton: UIButton!
    
    // MARK: View
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        return datePicker
    }()

    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        return toolBar
    }()
    
    lazy var doneButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(didTapDoneButton))
        return barButton
    }()
    
    lazy var cancleButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(didTapCancleButton))
        return barButton
    }()
    
    lazy var flexibleSpace: UIBarButtonItem = {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return flexibleSpace
    }()

    
    // MARK: ViewModel
    let vm = UserCreateViewModel()
    
    
    // MARK: Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setupGesture()
    }
    
    
    // MARK: @IBActions
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapEmailOverlapCheckButton(_ sender: UIButton) {
        if self.emailTextField.text?.isEmpty != true {
            guard let email = self.emailTextField.text else {return}
            
            self.vm.readRef_emailOverlapCheck(email: email) { [weak self] result in
                let alert = UIAlertController(title: "사용가능", message: nil, preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .cancel)
                alert.addAction(confirm)
                
                if result {
                    self?.present(alert, animated: true)
                } else {
                    alert.title = "이미 있는 사용자"
                    self?.present(alert, animated: true)
                }
            }
        } else {
            let alert = UIAlertController(title: "아이디(이메일)", message: nil, preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(confirm)
            self.present(alert, animated: true)
        }
        
    }
    
    @IBAction func didTapUserCreateButton(_ sender: UIButton) {
        guard let email = self.emailTextField.text,
              let password = self.passwordAgainTextField.text,
              let passwordAgain = self.passwordAgainTextField.text,
              let name = self.nameTextField.text,
              let birthDay = self.birthDayTextField.text,
              let gender = self.genderMaleButton.isSelected ? self.genderMaleButton.titleLabel?.text : self.genderFemaleButton.titleLabel?.text,
              let cellphone = self.cellphoneTextField.text else {return}
        
        self.vm.createModel(email: email,
                            password: password,
                            passwordAgain: passwordAgain,
                            name: name,
                            birthDay: birthDay,
                            gender: gender,
                            cellphone: cellphone)
    
        self.vm.auth_createUser() {
            self.dismiss(animated: true)
        }
    }
    
}

extension UserCreateViewController: Setup {
    
    func setupUI() {
        setupUI_emailOverlapCheckButton()
        
        setupUI_datePicker()
        setupUI_toolBar()
        setupUI_doneButton()
        setupUI_cancleButton()
        
        setupUI_birthDayTextField()
        setupUI_genderButton()
    }
    
    func setupLayout() {
        
    }
    
    func setupGesture() {
        
    }

}

// MARK: for setupUI
private extension UserCreateViewController {
    
    func setupUI_emailOverlapCheckButton() {
        self.emailOverlapCheckButton.layer.borderWidth = 1.0
        self.emailOverlapCheckButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func setupUI_datePicker() {
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.datePickerMode = .date
        self.datePicker.locale = Locale(identifier: "ko_KR")
        self.datePicker.timeZone = .current
        self.datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")
        self.birthDayTextField.text = formatter.string(from: sender.date)
    }
    
    func setupUI_toolBar() {
        self.toolBar.barStyle = .default
        self.toolBar.isTranslucent = true
        self.toolBar.tintColor = UIColor.systemBackground
        self.toolBar.sizeToFit()
        
        self.toolBar.setItems([cancleButton, flexibleSpace, doneButton], animated: false)
        self.toolBar.isUserInteractionEnabled = true
    }
    
    func setupUI_doneButton() {
        self.doneButton.tintColor = UIColor.label
    }
    
    @objc func didTapDoneButton() {
//        let row = self.datePicker.selectedRow(inComponent: 0)
//        self.datePicker.selectRow(row, inComponent: 0, animated: false)
//        self.birthDayTextField.text

        self.birthDayTextField.resignFirstResponder()
    }
    
    func setupUI_cancleButton() {
        self.cancleButton.tintColor = UIColor.label
    }
    
    @objc func didTapCancleButton() {
        self.birthDayTextField.resignFirstResponder()
    }
    
    func setupUI_birthDayTextField() {
        self.birthDayTextField.inputView = datePicker
        self.birthDayTextField.inputAccessoryView = toolBar
    }
    
    func setupUI_genderButton() {
        genderMaleButton.isSelected = true
        genderFemaleButton.isSelected = false
        
        genderMaleButton.alternateButton = [genderFemaleButton]
        genderFemaleButton.alternateButton = [genderMaleButton]
    }
}
