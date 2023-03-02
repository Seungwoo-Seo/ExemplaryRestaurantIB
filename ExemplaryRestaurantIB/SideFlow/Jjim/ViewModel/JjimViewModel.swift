//
//  JjimViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/26.
//


import Foundation
import FirebaseDatabase
import FirebaseAuth

class JjimViewModel {
    
    private let shared = StandardViewModel.shared
    private var model = JjimModel()
    
    private var ref: DatabaseReference {
        return self.model.ref
    }
    
    private var handle: AuthStateDidChangeListenerHandle? {
        return self.model.handle
    }
    
    var userUID: String? {
        return self.model.userUID
    }
    
    var storeList: [Store] {
        return self.model.storeList
    }
        
}

// MARK: model
extension JjimViewModel {
    
    // MARK: create
    func createModel_handle(completionHandler: @escaping (Bool) -> ()) {
        self.model.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self,
                  let user = user else {
                completionHandler(false)
                return
            }
            
            let userUID = user.uid
            self.createModel_userUID(userUID: userUID)
            completionHandler(true)
        }
    }
    
    func createModel_userUID(userUID: String) {
        self.model.userUID = userUID
    }
    
    func createModel_storeList(storeList: [Store]) {
        self.model.storeList = storeList
    }
    
    // MARK: delete
    func deleteModel_handle() {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    func deleteModel_storeList() {
        self.model.storeList = []
    }
    
}

// MARK: ref
extension JjimViewModel {
    
    // MARK: read
    func readRef_usersJjimList(completionHandler: @escaping () -> ()) {
        guard let userUID = self.userUID else {return}
        
        self.ref.child("\(userUID)JjimList").getData { [weak self] error, snapshot in
            if let error = error {
                print(error)
            }
            
//            guard let self = self,
//                  let value = snapshot?.value as? [String: Bool] else {
//                self?.deleteModel_storeList()
//                completionHandler()
//                return
//            }
//
//            let keys = Array(value.keys)
//            let storeList = self.shared.filteringModel_storeList_storeUID(keys: keys)
//
//            self.createModel_storeList(storeList: storeList)
//            completionHandler()
        }
    }
    
}


