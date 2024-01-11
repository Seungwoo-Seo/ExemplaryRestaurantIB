//
//  MyChangeViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2023/01/03.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SnapKit
import PromiseKit

class MyChangeViewModel {
    
    private var model = MyChangeModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
        
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
    
    private var storage: Storage {
        return self.model.storage
    }
}

// MARK: Life Cycle
extension MyChangeViewModel {
        
    func viewWillAppear(_ vc: MyChangeViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        firstly {
            self.addStateDidChangeListener()
        }
        .then { [unowned self] userUID in
            self.getUserInfo(userUID)
        }
        .done { [weak self] (userName, userEmail) in
            self?.model.userName = userName
            self?.model.userEmail = userEmail
            
            DispatchQueue.main.async { [weak vc] in
                vc?.tableView.reloadData()
            }
        }
        .catch { error in
            guard let error = error as? MyChangeError else {return}
            
            var alert = Alert.confirmAlert(title: nil) { [weak vc] in
                vc?.navigationController?.popViewController(animated: true)
            }
            
            switch error {
            case .notLogin:
                alert = Alert.confirmAlert(title: "로그인을 해주세요.") { [weak vc] in
                    vc?.navigationController?.popViewController(animated: true)
                }
                completionHandler(alert)
                
            case .cantUserInfoGet:
                alert = Alert.confirmAlert(title: "유저 정보를 가져오지 못했습니다.") { [weak vc] in
                    vc?.navigationController?.popViewController(animated: true)
                }
                completionHandler(alert)
                
            default:
                completionHandler(alert)
            }
        }
    }
    
    func viewWillDisappear() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
        
}

// didTapSaveButton
extension MyChangeViewModel {
    
    // MARK: didTapSaveButton
    func didTapSaveButton(_ sender: UIButton, vc: MyChangeViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        // textField 들의 edting을 꺼버려
        NotificationCenter.default.post(name: NSNotification.Name("didTapSaveButton"), object: nil)
        
        firstly {
            self.addStateDidChangeListener()
        }.then { userUID in
            when(fulfilled: self.updateUserName(userUID),
                            self.updatePassword())
        }.done { _, _ in
            let alert = Alert.confirmAlert(title: "변경되었습니다.")
            completionHandler(alert)
            
        }.catch { error in
            guard let error = error as? MyChangeError else {return}
            
            var alert = Alert.confirmAlert(title: nil) { [weak vc] in
                vc?.navigationController?.popViewController(animated: true)
            }
            
            switch error {
            case .cantUserNameUpdate:
                alert = Alert.confirmAlert(title: "이름을 변경할 수 없습니다.")
                completionHandler(alert)
                
            case .userNameRegex:
                alert = Alert.confirmAlert(title: "이름은 최소 2자 이상 한글만 사용 가능합니다.")
                completionHandler(alert)
                
            case .passwordRegex:
                alert = Alert.confirmAlert(title: "비밀번호는 8-20자 이내 영어, 숫자, 특수문자 조합으로 이뤄져야합니다.")
                completionHandler(alert)
                
            case .nowPasswordWrong:
                alert = Alert.confirmAlert(title: "현재 비밀번호가 일치하지 않습니다.")
                completionHandler(alert)
                
            case .passwordUpdate:
                alert = Alert.confirmAlert(title: "비밀번호를 변경할 수 없습니다.")
                completionHandler(alert)
            
            default:
                completionHandler(alert)
                
            }
        }
    }
    
}

// MyChangeTableView
extension MyChangeViewModel {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, delegate: MyChangeViewController) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyChangeCell0", for: indexPath) as? MyChangeCell0 else {return UITableViewCell()}
            
            if cell.delegate == nil {
                cell.delegate = delegate
            }
            
            cell.userNameTextField.text = self.model.userName
            cell.userNameTextField.tag = 0
            
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyChangeCell1", for: indexPath) as? MyChangeCell1 else {return UITableViewCell()}
            
            if cell.delegate == nil {
                cell.delegate = delegate
            }
            
            cell.email.text = self.model.userEmail
            cell.nowPasswordTextField.tag = 1
            cell.newPasswordTextField.tag = 2
            
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyChangeCell2", for: indexPath) as? MyChangeCell2 else {return UITableViewCell()}
            
            if cell.delegate == nil {
                cell.delegate = delegate
            }
    
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .systemGray6
        
        switch section {
        case 0:
            return footerView
        case 1:
            return footerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        case 1:
            return 10
        default:
            return 0
        }
    }
    
}

// MARK: MyChangeCellDelegate
extension MyChangeViewModel {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.model.userName = textField.text
            
        } else if textField.tag == 1 {
            self.model.nowPassword = textField.text
            
        } else if textField.tag == 2 {
            self.model.newPassword = textField.text
        }
    }
    
    func didTapProfileImageButton(_ sender: UIButton) {
        print("X")
    }
    
    func didTapChangeButton(_ sender: UIButton, nowPasswordTextField: UITextField, newPasswordTextField: UITextField) {
        if sender.isSelected {
            self.model.nowPassword = nil
            self.model.newPassword = nil
            self.model.isPassword = false
            
            sender.isSelected = false
            nowPasswordTextField.text = nil
            newPasswordTextField.text = nil
            nowPasswordTextField.isEnabled = false
            newPasswordTextField.isEnabled = false
            
        } else {
            self.model.isPassword = true
            
            sender.isSelected = true
            nowPasswordTextField.isEnabled = true
            newPasswordTextField.isEnabled = true
        }
    }
    
    func didTapLogoutButton(_ sender: UIButton, completionHandler: (UIAlertController?) -> ()) {
        do {
            try Auth.auth().signOut()
            completionHandler(nil)
            
        } catch {
            let alert = Alert.confirmAlert(title: "현재 로그아웃 할 수 없습니다.")
            completionHandler(alert)
        }
    }
        
    func didTapUserDeleteButton(_ sender: UIButton, vc: MyChangeViewController, completionHandler: @escaping (UIAlertController) -> ()) {
        self.userDeletePasswordCheck(vc)
            .then { [unowned self] userUID in
                self.deleteUserEverything(userUID)
            }
            .then { [unowned self] _ in
                self.deleteUser()
            }
            .done { _ in
                let alert = Alert.confirmAlert(title: "탈퇴되었습니다.") { [weak vc] in
                    vc?.navigationController?.popViewController(animated: true)
                }
                completionHandler(alert)
            }
            .catch { error in
                guard let error = error as? MyChangeError else {return}
                
                var alert = Alert.confirmAlert(title: "현재 회원탈퇴를 할 수 없습니다.")
                
                switch error {
                case .cantUserInfoGet:
                    alert = Alert.confirmAlert(title: "유저 정보를 가져오지 못했습니다.")
                    completionHandler(alert)
                    
                case .passwordEmpty:
                    alert = Alert.confirmAlert(title: "비밀번호를 작성하세요.")
                    completionHandler(alert)
                    
                case .passwordRegex:
                    alert = Alert.confirmAlert(title: "비밀번호는 8-20자 이내 영어, 숫자, 특수문자 조합으로 이뤄져야합니다.")
                    completionHandler(alert)
                    
                case .nowPasswordWrong:
                    alert = Alert.confirmAlert(title: "비밀번호가 일치하지 않습니다.")
                    completionHandler(alert)
                    
                default:
                    completionHandler(alert)
                }
            }
    }
    
}

// MARK: MyChangeTableView
extension MyChangeViewModel {
    
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, tableView: MyChangeTableView) {
        tableView.endEditing(true)
    }
    
}

// MARK: addObserver
extension MyChangeViewModel {
    
    func addObserver(_ textFields: UITextField...) {
        for textField in textFields {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("didTapSaveButton"), object: nil, queue: nil) { [weak textField] _ in
                textField?.endEditing(true)
            }
        }
    }
    
}

// MARK: firebase
private extension MyChangeViewModel {
    
    enum MyChangeError: Error {
        case notLogin               // 로그인 안함
        case cantUserInfoGet        // 유저 정보 가져오기 실패
        case cantUserNameUpdate     // 유저 이름 업데이트 실패
        case userNameRegex          // 유저 이름 정규식 통과 실패
        case passwordRegex          // 비밀번호 정규식 통과 실패
        case nowPasswordWrong       // 현재 비밀번호와 입력한 현재 비밀번호가 다름
        case passwordUpdate         // 비밀번호 업데이트 실패
        case passwordEmpty          // 비밀번호 공백
        case cantUserInfoDelete     // 유저 정보 삭제 실패
        case cantUserDelete         // 유저 삭제 실패
        case cantLogout             // 로그아웃 실패
        case cantUserJjimGet        // 유저 찜 가져오기 실패
        case transaction            // 트랜잭션 실패
        case cantUserJjimDelete     // 유저 찜 목록 삭제 실패
        case cantUserReviewListGet  // 유저 리뷰 목록 가져오기 실패
        case reviewDecoding         // 리뷰 디코딩 실패
        case cantStoreReviewDelete  // StoreReview 삭제 실패
        case cantReviewImageDelete  // image 삭제 실패
        case cantUserReviewDelete   // 유저 리뷰 전체 삭제 실패
    }
    
    // 로그인 유무
    private func addStateDidChangeListener() -> Promise<String> {
        return Promise { seal in
            self.model.handle = Auth.auth().addStateDidChangeListener { _, user in
                guard let user = user else {seal.reject(MyChangeError.notLogin); return}
                
                let userUID = user.uid
                
                seal.fulfill(userUID)
            }
        }
    }
    
    // 유저 정보 가져오기
    private func getUserInfo(_ userUID: String) -> Promise<(userName: String, userEmail: String)> {
        return Promise { seal in
            self.ref.child("UserList").child(userUID).getData { error, snapshot in
                guard error == nil else {seal.reject(MyChangeError.cantUserInfoGet); return}
                
                let value = snapshot?.value as! [String: Any]   // 무조건 있어야지 없으면 차라리 런타임 에러
                
                let userName = value["userName"] as! String
                let userEmail = value["userEmail"] as! String
                
                seal.fulfill((userName: userName, userEmail: userEmail))
            }
        }
    }
    

    // MARK: 저장 버튼 눌렀을 때
    // 이름 업데이트
    private func updateUserName(_ userUID: String) -> Promise<Void> {
        return Promise { seal in
            let userName = self.model.userName!
            
            let pattern = "^[가-힣]{2,}$"
            let regex = try NSRegularExpression(pattern: pattern)
            if let _ = regex.firstMatch(in: userName, range: NSRange(location: 0, length: userName.count)) {
                // 성공
                let updateValue = ["userName": userName]
                
                self.ref.child("UserList").child(userUID).updateChildValues(updateValue) { error, _ in
                    guard error == nil else {seal.reject(MyChangeError.cantUserNameUpdate); return}
                    
                    seal.fulfill(Void())
                }
            } else {
                // 실패
                seal.reject(MyChangeError.userNameRegex)
            }
        }
    }
    
    // 비밀번호 업데이트
    private func updatePassword() -> Promise<Void?> {
        return Promise { seal in
            guard self.model.isPassword,
                  let email = self.model.userEmail,
                  let nowPassword = self.model.nowPassword,
                  let newPassword = self.model.newPassword else {seal.fulfill(nil); return}
            
            let pattern = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
            let regex = try NSRegularExpression(pattern: pattern)
            
            [nowPassword, newPassword].forEach {
                guard let _ = regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) else {seal.reject(MyChangeError.passwordRegex); return}
            }
            
            let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: nowPassword)

            Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
                guard error == nil else {seal.reject(MyChangeError.nowPasswordWrong); return}
                
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                    guard error == nil else {seal.reject(MyChangeError.passwordUpdate); return}

                    seal.fulfill(Void())
                }
            }
        }
    }
    
    
    // MARK: 회원탈퇴 눌렀을 때
    // 비밀번호 체크
    private func userDeletePasswordCheck(_ vc: MyChangeViewController) -> Promise<String> {
        return Promise { seal in
            let alert = UIAlertController(title: "정말로 탈퇴하시겠습니까?", message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "취소", style: .cancel)
            let confirm = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                guard let nowPassword = alert.textFields?[0].text else {seal.reject(MyChangeError.passwordEmpty); return}
                
                let pattern = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
                let regex = try! NSRegularExpression(pattern: pattern)
                
                guard let _ = regex.firstMatch(in: nowPassword, range: NSRange(location: 0, length: nowPassword.count)) else {seal.reject(MyChangeError.passwordRegex); return}
                
                let email: String! = self?.model.userEmail
                let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: nowPassword)
                
                Auth.auth().currentUser?.reauthenticate(with: credential) { userData, error in
                    guard error == nil else {seal.reject(MyChangeError.nowPasswordWrong); return}
                    
                    let userUID: String! = userData?.user.uid
                    
                    seal.fulfill(userUID)
                }
            }
            
            [cancel, confirm].forEach { alert.addAction($0) }
            
            alert.addTextField { textField in
                textField.placeholder = "비밀번호를 입력하시오."
                textField.isSecureTextEntry = true
            }
            
            vc.present(alert, animated: true)
        }
    }
    
    // 삭제하는 유저와 연관된 모든걸 삭제하는 메서드
    private func deleteUserEverything(_ userUID: String) -> Promise<Void> {
        return Promise { seal in
            let group = DispatchGroup()
            
            DispatchQueue.global().async() {
                group.enter()
                firstly {
                    self.getUserJjimList(userUID)
                }
                .then { storeUrlList in
                    self.updateStoreListJjimInfo(storeUrlList)
                }
                .then { userJjimList in
                    self.deleteUserJjimList(userJjimList, userUID: userUID)
                }
                .done { _ in
                    group.leave()
                }
                .catch { error in
                    seal.reject(error)
                }
            }
            
            DispatchQueue.global().async() {
                group.enter()
                firstly {
                    self.getUserReviewList(userUID)
                }
                .then { reviewList in
                    self.updateStoreListReviewInfo(reviewList)
                }
                .then { reviewList in
                    when(fulfilled: self.deleteStoreReviewList(reviewList),
                         self.deleteReviewImages(reviewList),
                         self.deleteUserReviewList(reviewList, userUID: userUID))
                }
                .done { _, _, _ in
                    group.leave()
                }
                .catch { error in
                    seal.reject(error)
                }
            }
            
            group.notify(queue: .main) {
                self.deleteUserInfo(userUID)
                    .done { _ in
                        seal.fulfill(Void())
                    }
                    .catch { error in
                        seal.reject(error)
                    }
            }
        }
    }
    
    // 유저 찜 목록 가져오기
    private func getUserJjimList(_ userUID: String) -> Promise<[String]?> {
        return Promise { seal in
            self.ref.child("UserJjimList").child(userUID).getData { error, snapshot in
                guard error == nil else {seal.reject(MyChangeError.cantUserInfoGet); return}
                
                guard let value = snapshot?.value as? [String: Any] else {seal.fulfill(nil); return}
                
                let storeUidList = value.map { $0.key }
                
                seal.fulfill(storeUidList)
            }
        }
    }
    
    // 유저 리뷰 목록 가져오기
    private func getUserReviewList(_ userUID: String) -> Promise<[ReviewDelete]?> {
        return Promise { seal in
            self.ref.child("UserReviewList").child(userUID).getData { error, snapshot in
                guard error == nil else {seal.reject(MyChangeError.cantUserReviewListGet); return}
                
                guard let value = snapshot?.value as? [String: Any] else {seal.fulfill(nil); return}
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let reviewDic = try JSONDecoder().decode([String: ReviewDelete].self, from: jsonData)
                    let reviewList = reviewDic
                        .map { $0.value }
                    
                    seal.fulfill(reviewList)
                    
                } catch {
                    seal.reject(MyChangeError.reviewDecoding)
                }
            }
        }
    }
    
    // 찜 했던 가게들 찜 카운트 내리기
    private func updateStoreListJjimInfo(_ storeUidList: [String]?) -> Promise<String?> {
        return Promise { seal in
            guard let storeUidList = storeUidList else {seal.fulfill(nil); return}
            
            let group = DispatchGroup()
            
            storeUidList.forEach {
                group.enter()
                self.ref.child("StoreList").child($0).runTransactionBlock({ currentData in
                    if var post = currentData.value as? [String: AnyObject] {
                        var jjimCount = post["jjimCount"] as! Int
                        
                        jjimCount -= 1
                        
                        post["jjimCount"] = jjimCount as AnyObject
                        
                        currentData.value = post
                        
                        return TransactionResult.success(withValue: currentData)
                    }
                    
                    return TransactionResult.success(withValue: currentData)
                }) { error, _, _ in
                    guard error == nil else {seal.reject(MyChangeError.transaction); return}
                    group.leave()
                }
            }
        
            group.notify(queue: .main) {
                seal.fulfill("UserJjimList")
            }
        }
    }
    
    // 리뷰를 작성했던 가게들 정보 업데이트
    private func updateStoreListReviewInfo(_ reviewList: [ReviewDelete]?) -> Promise<[ReviewDelete]?> {
        return Promise { seal in
            guard let reviewList = reviewList else {seal.fulfill(nil); return}
            
            let group = DispatchGroup()
            
            reviewList.forEach { review in
                group.enter()
                self.ref.child("StoreList").child(review.storeUID).runTransactionBlock({ currentData in
                    if var post = currentData.value as? [String: AnyObject] {
                        var reviewCount = post["reviewCount"] as! Int
                        var reviewTotal = post["reviewTotal"] as! Int
                        var reviewAverage = post["reviewAverage"] as! Double
                        
                        reviewCount -= 1
                        reviewTotal -= review.starScore
                        
                        if reviewCount == 0 {
                            reviewAverage = 0.0
                        } else {
                            reviewAverage = Double(String(format: "%.1f", Double(reviewTotal) / Double(reviewCount)))!
                        }

                        post["reviewCount"] = reviewCount as AnyObject
                        post["reviewTotal"] = reviewTotal as AnyObject
                        post["reviewAverage"] = reviewAverage as AnyObject
                        
                        currentData.value = post
                        
                        return TransactionResult.success(withValue: currentData)
                    }
                    return TransactionResult.success(withValue: currentData)
                }) { error, _, _ in
                    guard error == nil else {seal.reject(MyChangeError.transaction); return}
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(reviewList)
            }
        }
    }
    
    // 찜 데이터 전체 삭제
    private func deleteUserJjimList(_ userJjimList: String?, userUID: String) -> Promise<Void?> {
        return Promise { seal in
            guard let userJjimList = userJjimList else {seal.fulfill(nil); return}
            
            self.ref.child(userJjimList).child(userUID).removeValue { error, _ in
                guard error == nil else {seal.reject(MyChangeError.cantUserJjimDelete); return}
                seal.fulfill(Void())
            }
        }
    }
        
    // 가게 리뷰 목록에서 탈퇴하는 유저가 작성한 리뷰들 삭제
    private func deleteStoreReviewList(_ reviewList: [ReviewDelete]?) -> Promise<Void?> {
        return Promise { seal in
            guard let reviewList = reviewList else {seal.fulfill(nil); return}
            
            let group = DispatchGroup()
            
            reviewList.forEach { review in
                group.enter()
                
                self.ref.child("StoreReviewList").child(review.storeUID).child(review.identifier).removeValue { error, _ in
                    guard error == nil else {seal.reject(MyChangeError.cantStoreReviewDelete); return}
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(Void())
            }
        }
    }
    
    // 리뷰 이미지 삭제
    private func deleteReviewImages(_ reviewList: [ReviewDelete]?) -> Promise<Void?> {
        return Promise { seal in
            guard let reviewList = reviewList else {seal.fulfill(nil); return}
            
            let group = DispatchGroup()
            
            reviewList.forEach { review in
                guard let reviewImageURL = review.reviewImageURL else {return}
                
                reviewImageURL.forEach { imageUrl in
                    group.enter()
                    
                    self.storage.reference(forURL: imageUrl).delete { error in
                        guard error == nil else {seal.reject(MyChangeError.cantReviewImageDelete); return}
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                seal.fulfill(Void())
            }
        }
    }
    
    // 유저 리뷰 전체 삭제
    private func deleteUserReviewList(_ reviewList: [ReviewDelete]?, userUID: String) -> Promise<Void?> {
        return Promise { seal in
            guard let _ = reviewList else {seal.fulfill(nil); return}
            
            self.ref.child("UserReviewList").child(userUID).removeValue { error, _ in
                guard error == nil else {seal.reject(MyChangeError.cantUserReviewDelete); return}
                seal.fulfill(Void())
            }
        }
    }
    
    // 유저 정보 삭제
    private func deleteUserInfo(_ userUID: String) -> Promise<Void> {
        return Promise { seal in
            self.ref.child("UserList").child(userUID).removeValue { error, _ in
                guard error == nil else {seal.reject(MyChangeError.cantUserInfoDelete); return}
                seal.fulfill(Void())
            }
        }
    }
    
    // 유저 삭제
    private func deleteUser() -> Promise<Void> {
        return Promise { seal in
            Auth.auth().currentUser?.delete { error in
                guard error == nil else {seal.reject(MyChangeError.cantUserDelete); return}
                    
                do {
                    try Auth.auth().signOut()
                    seal.fulfill(Void())
                } catch {
                    seal.reject(MyChangeError.cantLogout)
                }
            }
        }
    }
    
}
