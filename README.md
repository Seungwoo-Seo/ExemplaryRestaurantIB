# 모음 - 서울 모범음식점 찾기

> 모범음식점 지정 현황 API를 기반으로 서울시에서 지정한 일반음식점 및 집단급식소 중 위생관리 및 고객 서비스 수준이 우수한 업소를 찾아볼 수 있는 서비스입니다.

<p align="center">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/f7674e21-7dab-4d82-b0f3-17434679f683" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/e50718e4-8afc-4c1d-bbce-ef2a8aca5024" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/90ae0dcd-99ab-462b-b0a1-b3653c8827cc" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/a7fb2876-dc56-4ce7-a9cc-1c5dd1e99f89" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/0db88594-bb32-46ec-8346-3ce1b01da748" width="130">
  <img src="https://github.com/Seungwoo-Seo/ExemplaryRestaurantIB/assets/72753868/184e3b7d-8b74-4228-b2f3-767c618a9e7d" width="130">
</p>

## 목차

- [🚀 주요 기능](#-주요-기능)
- [🛠 구현 기술](#-구현-기술)
- [💻 기술 스택](#-기술-스택)
- [📱 서비스](#-서비스)
- [🚧 기술적 도전](#-기술적-도전)
- [🚨 트러블 슈팅](#-트러블-슈팅)
- [📝 회고](#-회고)
- [🖼 아이콘 출처 및 저작권 정보](#-아이콘-출처-및-저작권-정보)

## 🚀 주요 기능

- 모범음식점 목록 및 상세 정보 조회
- Kakao Map 기반으로 모범음식점 위치 탐색
- 찜 목록 및 리뷰 목록
- 회원인증

## 🛠 구현 기술

- `Bottom Sheet` 구현
- `FirebaseRealtimeDatabase`를 활용해 `찜 CRUD`와 `리뷰 CRUD` 구현
- `DispatchGroup`과 `PromiseKit`을 활용해 25개의 API 동기적 구현

## 💻 기술 스택

- `Swift`
- `MVC`, `Singleton`
- `UIKit`, `PhotosUI`,
- `URLSession`, `Storyboard`, `CodeBase UI`, `AutoLayout`
- `SnapKit`, `PromiseKit`, `Cosmos`, `SwiftyJSON`, `Kingfisher`, `Tabman`
- `Firebase`

## 📱 서비스

- 최소 버전 : iOS 15.0
- 개발 인원 : 1인
- 개발 기간 : 2022년 8월 ~ 2023년 2월 (6개월)

<!--
![Swift](https://img.shields.io/badge/Swift-FA7343?style=flat&logo=swift&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-007ACC?style=flat&logo=xcode&logoColor=white)
![MVC](https://img.shields.io/badge/MVC-EC463F?style=flat)
![Storyboard](https://img.shields.io/badge/Storyboard-orange?style=flat&logo=swift&logoColor=white) 
![CodeBaseUI](https://img.shields.io/badge/CodeBase%20UI-green?style=flat&logo=swift&logoColor=white)
![URLSession](https://img.shields.io/badge/URLSession-yellow?style=flat&logo=swift&logoColor=white)
![Firebase Realtime Database](https://img.shields.io/badge/Firebase%20Realtime%20Database-red?style=flat&logo=firebase&logoColor=white)
![Firebase Storage](https://img.shields.io/badge/Firebase%20Storage-brightgreen?style=flat&logo=firebase&logoColor=white)
![Firebase Authentication](https://img.shields.io/badge/Firebase%20Authentication-blue?style=flat&logo=firebase&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-orange?style=flat&logo=swift&logoColor=white)
![PhotosUI](https://img.shields.io/badge/PhotosUI-lightgrey?style=flat&logo=swift&logoColor=white)
![PromiseKit](https://img.shields.io/badge/PromiseKit-brightgreen?style=flat&logo=swift&logoColor=white)
![Cosmos](https://img.shields.io/badge/Cosmos-yellow?style=flat&logo=swift&logoColor=white) 
![SnapKit](https://img.shields.io/badge/SnapKit-007ACC?style=flat&logo=swift&logoColor=white)
![SwiftyJSON](https://img.shields.io/badge/SwiftyJSON-brightgreen?style=flat&logo=swift&logoColor=white)
![Kingfisher](https://img.shields.io/badge/Kingfisher-1A1A1A?style=flat&logo=swift&logoColor=white)
![Tabman](https://img.shields.io/badge/Tabman-blue?style=flat&logo=swift&logoColor=white)
![CocoaPods](https://img.shields.io/badge/CocoaPods-blue?style=flat&logo=swift&logoColor=white)
![SPM (Swift Package Manager)](https://img.shields.io/badge/SPM-yellow?style=flat&logo=swift&logoColor=white)
-->

## 🚧 기술적 도전

<!-- 프로젝트를 진행하면서 겪은 기술적인 도전과 어떻게 해결했는지에 대한 설명을 추가한다. -->
### 1. 콜백 지옥 개선
- **도전 상황**</br>
여러 API를 차례대로 사용해서 각 요청에 대한 응닶 값을 기반으로 순서대로 로직을 처리했을 때 콜백 지옥이 되는 현상을 개선하고 싶었습니다.

- **도전 결과**</br>
`PromiseKit`을 도입하여 비동기 작업을 동기적으로 처리할 수 있게 되었고 콜백 지옥을 개선할 수 있었습니다.
~~~swift
    func fetchStoreInfo(completionHandler: @escaping (UIAlertController?) -> ()) {
        navigationController?.isNavigationBarHidden = true
        lodingView.startLoding()

        let alert = Alert.confirmAlert(title: "가게 정보를 불러올 수 없습니다.") {
            navigationController?.popViewController(animated: true)
        }

        guard let storeUID = store?.uid else {completionHandler(alert); return}

        firstly {
            when(fulfilled: self.addStateDidChangeListener(),           // 로그인 유무
                            self.readFIR_StoreList(storeUID))           // 가게 정보

        }.then { userUID, _ in
            self.readFIR_UserJjimList(userUID, storeUID)

        }.then { isJjim in
            self.isJjimCheck(isJjim)

        }.done { _ in
            DispatchQueue.main.async {
                navigationController?.isNavigationBarHidden = false
                self.tableView.reloadData()
                self.lodingView.stopLoding()
                completionHandler(nil)
            }

        }.catch { error in
            guard let error = error as? StoreInfoReadError else {return}

            switch error {
            case .decodeError, .storeListReadErrror:
                completionHandler(alert)

            default:
                completionHandler(alert)
            }
        }
    }
~~~

## 🚨 트러블 슈팅

<!-- 프로젝트 중 발생한 문제와 그 해결 방법에 대한 내용을 기록한다. -->
### 1. 네트워크 응답 데이터 UI 바인딩 이슈
- **문제 상황**</br>
응답 받은 데이터가 분명히 존재하는데 해당 데이터가 UI에 반영되지 않는 문제가 발생했습니다.

- **해결 방법**</br>
UI가 화면에 보여지고 데이터를 받게 되어서 UI에 반영되지 않았다는 걸 알게 되었고 비동기, 동기에 대한 개념을 학습했습니다.</br>
UI가 화면에 보여지는 시점보다 나중에 데이터를 받아도 UI에 바인딩 할 수 있게 `Notification`을 적용했습니다.</br>
또, 여러 API에 응답값을 동시에 사용해야 하기 때문에 `DispatchGroup`을 사용해서 비동기 작업들을 동기적으로 처리했습니다.
~~~swift
func fetchData() {
    let group = DispatchGroup()
    var storeList: [Store] = []
    
    for (gooURL, goo) in gooUrlList {
        // 1000까지 보내는 이유
        // ERROR-336 - 데이터요청은 한번에 최대 1000건을 넘을 수 없습니다.
        // 때문에 1에서 1000까지 request
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

### 2. ScrollView가 중첩일 때 유저 이벤트의 모호성 이슈
- **문제 상황**</br>
tableViewCell에 지도를 넣고 싶었지만 지도도 결국 ScrollView를 기반으로 구현됬기 때문에 ScrollView가 중첩되어서 유저 이벤트가 제대로 동작하지 않았습니다.

- **해결 방법**</br>
UITableView를 상속받는 사용자 정의 TableView를 만들고 `touchesShouldCancel` 메서드를 오버라이딩하여 해결했습니다.
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

### 3. CollectionViewCell에 비동기적으로 이미지를 로드하고 적용하는 동안 이미지 캐싱을 사용하지 않았을 때 이슈
- **문제 상황**</br>
이미지 로딩이 느린 경우에 이미지가 보여지지 않거나 제대로 보여지지 않았습니다. 또, 컬렉션 뷰 셀이 재사용되는 특성상, 스크롤 시 이미지가 올바른 행에 표시되지 않았습니다.

- **해결 방법**</br>
`Kingfisher` 라이브러리를 도입하여 매우 간단하게 비동기 이미지 다운로드, 캐시 관리, 비동기적 이미지 셋팅을 해결했습니다.
~~~swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserReviewImageCell", for: indexPath) as? UserReviewImageCell,
          let reviewImageURL = userReview.reviewImageURL else {return UICollectionViewCell()}
        
    let imageUrlList = reviewImageURL.compactMap { URL(string: $0) }
    let imageUrl = imageUrlList[indexPath.item]
        
    cell.reviewImageView.kf.setImage(with: imageUrl)
        
    return cell
}
~~~

## 📝 회고
<!-- 프로젝트를 마무리하면서 느낀 소회, 개선점, 다음에 시도해보고 싶은 것 등을 정리한다. -->
👍 성취한 점
1. API 응답 데이터를 UI에 반영하는 로직을 구현하다 보니 `@escaping closure`와, `비동기-동기`에 대한 개념을 자연스럽게 학습할 수 있었습니다.
2. custom view를 직접 만들어서 viewController와 통신을 구현하다 보니 `Delegate Pattern`에 대해서 자연스럽게 학습할 수 있었습니다.
3. [🚨 트러블 슈팅 #3](#3-collectionviewcell에-비동기적으로-이미지를-로드하고-적용하는-동안-이미지-캐싱을-사용하지-않았을-때-이슈)을 통해 `Kingfisher` 라이브러리의 장점을 경험했습니다.
4. `Storyboard`로 구현하기 어려웠던 view를 `CodeBase UI`로 구현하면서 `SnapKit` 라이브러리의 장점을 경험했습니다.

🤔 개선할 점
1. `모음`의 메인화면인 `지역구 별 음식점 종류 선택 화면`은 각 지역구에 해당하는 API들이 전부 다르기 때문에 해당 화면을 구현하기 위해선 너무 많은 데이터를 필요로 했습니다. 지역구 별 음식점 종류를 선택하는 게 아니라 지역구를 선택하는 방향으로 진행했다면 불필요한 API 호출을 줄일 수 있었을 것 같습니다.
2. 하나의 ViewController에서 너무 많은 로직을 작성하다보니 필요한 메서드를 찾기도 힘들었고 여러 Flow를 관리하기도 힘들었습니다. `코드 분리`에 대한 필요성을 경험했으니 `MVP`, `MVVM` 패턴을 학습하고 적용해보겠습니다.

## 🖼 아이콘 출처 및 저작권 정보

이 프로젝트에서 사용된 아이콘들은 아래와 같은 출처에서 제공되었습니다. 각 아이콘의 저작권은 해당 제작자에게 있습니다. 아이콘을 사용하려면 각 아이콘의 출처로 이동하여 저작권 관련 정보를 확인하세요.

- [Food icons](https://www.flaticon.com/free-icons/food) by justicon - Flaticon
- [찐 생선 아이콘](https://www.flaticon.com/kr/free-icons/-) by surang - Flaticon
- [버거 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [맥주 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [Buns icons](https://www.flaticon.com/free-icons/buns) by ultimatearm - Flaticon
- [Sushi icons](https://www.flaticon.com/free-icons/sushi) by tulpahn - Flaticon
- [치킨 아이콘](https://www.flaticon.com/kr/free-icons/) by photo3idea_studio - Flaticon
- [설렁탕 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [소주 아이콘](https://www.flaticon.com/kr/free-icons/) by iconixar - Flaticon
- [떡볶이 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [복어 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [냉면 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [일본 음식 아이콘](https://www.flaticon.com/kr/free-icons/-) by tulpahn - Flaticon
- [김밥 아이콘](https://www.flaticon.com/kr/free-icons/) by Nhor Phai - Flaticon
- [뷔페 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [카페 아이콘](https://www.flaticon.com/kr/free-icons/) by Smashicons - Flaticon
- [고기 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [국수 아이콘](https://www.flaticon.com/kr/free-icons/) by mangsaabguru - Flaticon
- [기타 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [공장 아이콘](https://www.flaticon.com/kr/free-icons/) by Eucalyp - Flaticon
- [공공의 아이콘](https://www.flaticon.com/kr/free-icons/) by Freepik - Flaticon
- [Restaurant icons](https://www.flaticon.com/free-icons/restaurant) by Eucalyp - Flaticon
