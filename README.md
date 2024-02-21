# 모음 - 서울 모범음식점 찾기

> 서울시에서 지정한 일반음식점 및 집단급식소 중 위생관리 및 고객 서비스 수준이 우수한 업소를 조회할 수 있는 서비스

<p align="center">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/f7674e21-7dab-4d82-b0f3-17434679f683" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/e50718e4-8afc-4c1d-bbce-ef2a8aca5024" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/90ae0dcd-99ab-462b-b0a1-b3653c8827cc" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/a7fb2876-dc56-4ce7-a9cc-1c5dd1e99f89" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/0db88594-bb32-46ec-8346-3ce1b01da748" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/184e3b7d-8b74-4228-b2f3-767c618a9e7d" width="130">
</p>

## 📱 서비스

- 최소 버전 : iOS 15.0
- 개발 인원 : 1인
- 개발 기간 : 2023.03.03 ~ 2023.05.07 (2개월)


## 🚀 서비스 기능

- 이메일 회원인증 기능 제공
- 모범음식점 지정 현황 API 기반 서울시 지역구 별 모범음식점 정보 제공
- 검색/지도/찜/리뷰(별점, 사진, 텍스트) 기능 제공


## 🛠 사용 기술

- Swift
- Foundation, UIKit, PhotosUI, CoreLocation
- MVC, Singleton, Delegate Pattern
- SwiftyJSON, PromiseKit, SnapKit, Cosmos, Kingfisher, Tabman, Lottie
- Storyboard, CodeBaseUI, AutoLayout, URLSession, PHPicker, ImagePicker, CLGeocoder
- Firebase Auth, Firebase RealtimeDatabase, Firebase Storage


## 💻 핵심 설명

- Firebase Auth, Firebase RealtimeDatabase를 활용해 OAuth 2.0 기반 `이메일 회원 인증` 구현
- URLSession을 사용해 `REST API` 통신 구현
- DispatchGroup, SwiftyJSON, Notification을 활용해 `25개 API 응답 값 핸들링`
- Firebase RealtimeDatabase, Firebase Storage를 활용해 찜, 리뷰 CRUD를 구현
- 지역구를 선택하기 위한 `BottomSheet` 구현, Delegate Pattern을 통해 `ViewController와의 통신` 구현
- Kakao Maps SDK, CLGeocoder를 사용하여 `지도` 및 `마커` 구현
- ImagePicker를 사용해 카메라 구현, 촬영한 사진을 앨범에 저장하기 위해서 `권한 인증` 구현
- PHPicker를 사용해 `미리 저장된 이미지 load` 구현


## 🚨 트러블 슈팅

<!-- 프로젝트 중 발생한 문제와 그 해결 방법에 대한 내용을 기록한다. -->
### 1. 모범음식점 지정 현황 API에 요청 후 응답 받은 데이터를 파싱까지 성공했지만 UI에 적용되지 않았던 이슈
- **문제 원인**</br>
동시성에 대한 개념 미인지로 인해 파싱한 데이터를 View가 사용하는 배열에 추가만 하고 UI 업데이트 로직을 구현하지 않은 상황이 원인

- **해결 방법**</br>
동시성에 대해 학습, DispatchGroup을 사용해 응답값이 모였을 때 Notification으로 UI 업데이트 메서드 호출해서 해결
~~~swift
func fetchData() {
    let group = DispatchGroup()
    var storeList: [Store] = []
    
    for (gooURL, goo) in gooUrlList {
        let url = URL(string: "http://openAPI.\(gooURL):8088/\(APIKey.key)/json/\(goo)ModelRestaurantDesignate/1/1000/")!
        
        group.enter()
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌", error.localizedDescription)
                group.leave()
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200...299).contains(statusCode) else {
                print("❌", "response Error")
                group.leave()
                return
            }
            
            guard let data = data else {
                print("❌", "data Error")
                group.leave()
                return
            }
            
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
                          let businessType = subJson["SNT_UPTAE_NM"].string else {
                        print("데이터 파싱 error")
                        continue
                    }
                    
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
                    
                    
                    storeList.append(store)
                }
            } catch {
                print("❌", "파싱 에러")
            }
            group.leave()
        }
        .resume()
    }
    
    group.notify(queue: .main) { [weak self] in
        guard let self = self else {return}
        self.storeList = storeList
        
        print(self.storeList.count)
        
        NotificationCenter.default.post(name: NSNotification.Name("fetchDataCompleted"), object: nil)
    }
}
~~~


### 2. UITableViewCell에 Kakao MapView를 넣었을 때 스크롤이 제대로 동작하지 않았던 이슈
- **문제 원인**</br>
UITableView와 MapView 모두 스크롤뷰의 하위 클래스, 스크롤이 중첩되어 어떤 스크롤뷰를 스크롤해야 하는지 모호한 상황이 원인

- **해결 방법**</br>
Custom TableView를 만들고 `touchesShouldCancel(in:)` 메서드를 오버라이딩하여 MapView일 땐 스크롤하지 않는 방법으로 해결
~~~swift
class StoreInfoTableView: UITableView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.tag == 20090806 {
            return false
        } else if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }

}
~~~

## 📝 회고
<!-- 프로젝트를 마무리하면서 느낀 소회, 개선점, 다음에 시도해보고 싶은 것 등을 정리한다. -->
- 동시성에 대해서 학습
- 콜백 지옥을 경험
- ViewController가 커질수록 관리하기 힘들었고, 필요한 메서드를 찾고 유지보수 하기 힘들다는 것을 경험
