//
//  StandardViewModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/09/19.
//

import Foundation
import Alamofire
import SwiftyJSON

class StandardViewModel {
    
    // MARK: Singleton
    static let shared = StandardViewModel()
    
    
    // MARK: Model
    private var model = StandardModel()
    
    
    // MARK: Computed
    var storeList: [Store] {
        return self.model.storeList
    }
    
    // MARK: Init
    private init() {}
    
}

// MARK: fetch
extension StandardViewModel {

    func fetchData() {
        let group = DispatchGroup()
        var storeList: [Store] = []
        
        for (gooURL, goo) in model.gooUrlList {
            group.enter()
            // 1000까지 보내는 이유
            // ERROR-336 - 데이터요청은 한번에 최대 1000건을 넘을 수 없습니다.
            // 때문에 1에서 1000까지 request
            let url = "http://openAPI.\(gooURL):8088/657466504273656f393575694b4168/json/\(goo)ModelRestaurantDesignate/1/1000/"
            
            AF.request(url)
                .validate(statusCode: 200..<300)
                .response { [weak self] response in
                    guard let self = self,
                          let data = response.data else {return}
                    
                    do {
                        let json = try JSON(data: data)
                        let row = json["\(goo)ModelRestaurantDesignate"]["row"]
                        
                        for (_, subJson): (_, JSON) in row {
                            guard let gooCode = subJson["CGG_CODE"].string,
                                  let assignationNumber = subJson["ASGN_SNO"].string,
                                  let signUpDay = subJson["APPL_YMD"].string,
                                  let assignationSelectedDay = subJson["ASGN_YMD"].string,
                                  let name = subJson["UPSO_NM"].string,
                                  let roadAddress = subJson["SITE_ADDR_RD"].string,
                                  let address = subJson["SITE_ADDR"].string,
                                  let permissionNumber = subJson["PERM_NT_NO"].string,
                                  let businessType = subJson["SNT_UPTAE_NM"].string else { print("데이터 파싱 error"); continue }
                            
                            // 이건 없는게 많음
                            let mainMenu = subJson["MAIN_EDF"].string ?? "없음"
                            let phoneNumber = subJson["UPSO_SITE_TELNO"].string ?? "없음"
                            
                            let uid = self.fetchData_makeUid(permissionNumber,
                                                             assignationNumber,
                                                             signUpDay,
                                                             assignationSelectedDay)
                            

                            
                            let store = Store(gooCode: gooCode,
                                              assignationNumber: assignationNumber,
                                              signUpDay: signUpDay,
                                              assignationSelectedDay: assignationSelectedDay,
                                              name: name,
                                              roadAddress: roadAddress,
                                              address: address,
                                              permissionNumber: permissionNumber,
                                              businessType: businessType,
                                              mainMenu: mainMenu,
                                              phoneNumber: phoneNumber,
                                              uid: uid)
                            
                            // json 서버용 만들기
//                            print("\"\(store.uid!)\":", "{", "\"jjimCount\": 0,", "\"reviewCount\": 0,", "\"reviewAverage\": 0.0,", "\"reviewTotal\": 0", "},")
//                            if store.uid == "3000000-101-1974-0572201442016100420161205" {
//                                print(store.name)
//                            }
                            
                            storeList.append(store)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    group.leave()
                } // AF
            
        } // first for _ in
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else {return}
            
            self.model.storeList = storeList
       
            print(self.model.storeList.count)
       
            NotificationCenter.default.post(name: NSNotification.Name("fetchDataCompleted"), object: nil)
        }
        
    } // fetchData
    
    func fetchData_makeUid(_ strings: String...) -> String {
        var uid = ""
        for string in strings {
            uid += string.trimmingCharacters(in: .whitespaces)
        }
        return uid
    }
    
}

// LodingView
extension StandardViewModel {
    
    func startLoding(_ lodingView: LodingView, activityView: UIActivityIndicatorView) {
        lodingView.alpha = 1.0
        activityView.startAnimating()
    }
    
    func stopLoding(_ lodingView: LodingView, activityView: UIActivityIndicatorView) {
        lodingView.alpha = 0.0
        activityView.stopAnimating()
    }
    
}
