//
//  MyViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/04.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import PromiseKit

class MyViewModel {
 
    private var model = MyModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
        
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
        
}

// MARK: model
extension MyViewModel {
    
    func viewWillAppear(_ changeLabel: UILabel) {
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print("일로온다잉")
//        }
//        
        firstly {
            self.addStateDidChangeListener()
        }.then { userUID in
            self.readFIR_UserList(userUID)
        }.done { userName in
            if let userName = userName {
                changeLabel.text = "\(userName)님 반갑습니다."
            } else {
                changeLabel.text = "로그인을 해주세요."
            }
        }.catch { error in
            
        }
    }
    
    private func addStateDidChangeListener() -> Promise<String?> {
        return Promise { seal in
            self.model.handle = Auth.auth().addStateDidChangeListener { _, user in
                guard let user = user else {
                    self.model.userUID = nil
                    seal.fulfill(nil)
                    return
                }
                
                let userUID = user.uid
                self.model.userUID = userUID
                
                seal.fulfill(userUID)
            }
        }
    }
    
    private func readFIR_UserList(_ userUID: String?) -> Promise<String?> {
        return Promise { seal in
            guard let userUID = userUID else {seal.fulfill(nil); return}
            
            self.ref.child("UserList").child(userUID).getData { error, snapshot in
                if let _ = error {
                    
                } else {
                    guard let value = snapshot?.value as? [String: Any] else {return}
                    
                    let userName = value["userName"] as! String
                    self.model.userName = userName
                    
                    seal.fulfill(userName)
                }
            }
        }
    }

    func removeStateDidChangeListener() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
}

// MARK: MyViewController.tableView
extension MyViewModel {
    
    enum PushOrPresent {
        case push
        case present
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, completionHandler: (UIViewController, PushOrPresent) -> ()) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if let _ = self.model.userUID {
            switch cell {
            case is Cell0:
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyChangeViewController") as? MyChangeViewController else {return}
                completionHandler(vc, .push)
                
            case is Cell1:
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "JjimViewController") as? JjimViewController else {return}
                completionHandler(vc, .push)
                
            case is Cell2:
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserReviewViewController") as? UserReviewViewController else {return}
                completionHandler(vc, .push)
                
            default:
                let alert = Alert.confirmAlert(title: "준비중")
                completionHandler(alert, .present)
            }
        } else {
            switch cell {
            case is Cell0:
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {return}
                vc.modalPresentationStyle = .fullScreen
                completionHandler(vc, .present)
            
            case is Cell1:
                let alert = Alert.confirmAlert(title: "로그인 시 이용 가능합니다.")
                completionHandler(alert, .present)
                
            case is Cell2:
                let alert = Alert.confirmAlert(title: "로그인 시 이용 가능합니다.")
                completionHandler(alert, .present)
                
            default:
                let alert = Alert.confirmAlert(title: "준비중")
                completionHandler(alert, .present)
                
            }
        }
    }
    
}

// MARK: ref
extension MyViewModel {
    
    // MARK: delete
    func deleteRef_user() {
        guard let userUID = self.model.userUID else {return}
        
        self.ref.child("UserList").child(userUID).removeValue()
    }
    
}
