# 모음 - 서울 모범음식점 찾기

<p align="center">
  <img src="https://your-banner-image-url.png" alt="ExemplaryRestaurantIB Logo" width="800">
</p>

<p align="center">
  모음은 서울시에서 지정한 일반음식점 및 집단급식소 중 위생관리 및 고객 서비스 수준이 우수한 업소를 찾아볼 수 있는 서비스입니다.
</p>

<p align="center">
  <img src="https://your-screenshot-url-1.png" alt="Main Screen 1" width="300">
  <img src="https://your-screenshot-url-2.png" alt="Main Screen 2" width="300">
  <img src="https://your-screenshot-url-3.png" alt="Main Screen 3" width="300">
</p>

## 목차
- [🚀 주요 기능](#-주요-기능) 
- [💻 개발 환경 및 기술 스택](#-개발-환경-및-기술-스택)
- [🚧 기술적 도전](#-기술적-도전)
- [🛠 트러블 슈팅](#-트러블-슈팅)
- [📝 회고](#-회고)
- [🖼 아이콘 출처 및 저작권 정보](#-아이콘-출처-및-저작권-정보)

## 🚀 주요 기능

- **모범음식점 검색**: 서울시 모범음식점 검색 기능
- **지도 보기**: kakao지도로 모범음식점의 위치 탐색 기능
- **찜**
- **찜 내역**: 내가 찜한 모범음식점 모아보기 기능
- **리뷰 남기기**: 별점, 사진, 텍스트로 리뷰 남기기 기능
- **리뷰 내역**: 내가 남긴 리뷰 내역 모아보기 기능
- **이메일 회원가입**
- **회원정보 수정**: 이름, 비밀번호 수정 기능
- **회원탈퇴**
- **계정찾기**


## 💻 개발 환경 및 기술 스택

- **언어**: Swift
- **개발 환경**: Xcode, Firebase
- **의존성 관리**: CocoaPods, SPM
- **디자인 패턴**: MVC
- **라이브러리 및 프레임워크**: UIKit, PromiseKit, Cosmos, SnapKit, SwiftyJSON, Kingfisher, Tabman <!-- [사용한 주요 라이브러리 및 프레임워크 목록] -->

## 🚧 기술적 도전

<!-- 프로젝트를 진행하면서 겪은 기술적인 도전과 어떻게 해결했는지에 대한 설명을 추가한다. -->

## 🛠 트러블 슈팅

<!-- 프로젝트 중 발생한 문제와 그 해결 방법에 대한 내용을 기록한다. -->
### 1. 네트워크 응답 데이터 UI 바인딩 이슈
- **문제 상황**</br>
응답 받은 데이터가 분명히 존재하는데 해당 데이터가 UI에 반영되지 않는 문제가 발생했습니다.

- **해결 방법**</br>
UI가 화면에 보여지고 데이터를 받게 되어서 UI에 반영되지 않았다는 걸 알게 되었고 비동기, 동기에 대한 개념을 학습했습니다.</br>
UI가 화면에 보여지는 시점보다 나중에 데이터를 받아도 UI에 바인딩 할 수 있게 Notification을 적용했습니다.</br>
또, 여러 API에 응답값을 동시에 사용해야 하기 때문에 DispatchGroup을 사용해서 비동기 작업들을 동기적으로 처리했습니다.
```swift
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
```
## 📝 회고

<!-- 프로젝트를 마무리하면서 느낀 소회, 개선점, 다음에 시도해보고 싶은 것 등을 정리한다. -->
프로젝트를 마무리하면서 몇 가지 느낀 점과 개선할 사항들을 회고로 정리하겠습니다.

👍 성취한 점
1. **생애 첫 프로젝트 도전 성공**</br>
swift 문법 책 하나만 읽고 오롯히 혼자서 구현해낸 첫 프로젝트입니다. 하나부터 열까지 모든 걸 혼자서 학습하고 구현했기 때문에 생각보다 많은 시간이 걸렸지만 결국 왔고, 봤고, 해냈습니다. 뭐든지 시작이 중요한만큼 첫 발을 디뎠고 이번 시행착오를 토대로 이후엔 보다 발전할 수 있겠다라는 자신감을 얻었습니다.

2. **여러 문법과 개념 대한 이해**</br>
그동안 전혀 와닿지 않던 문법과 개념들을 이해하게 되었습니다. @escaping closure, 비동기-동기, 데이터 파싱 등 아예 감조차 잡지 못했던 개념 혹은 문법들을 직접 프로젝트를 구현해 보니 깨닫게 되었습니다.

3. **다양한 라이브러리 및 프레임워크 활용**</br>
프로젝트를 효율적으로 개발하기 위해 다양한 라이브러리와 프레임워크를 활용해봤습니다. 이를 통해 개발 속도를 높이고 안정성을 확보했습니다. 특히, SnapKit, Kingfisher 등의 라이브러리를 통해 개발 생산성을 향상시켰습니다.

🤔 개선할 점
1. **Massive View Controller**</br>
ViewController의 코드 라인이 많아질수록 점점 유지 보수하기도 힘들고 수정도 용이하지 않았습니다. 좀 더 발전된 디자인 패턴의 필요성을 느꼈습니다.

2. **지역구 별 음식점 종류 선택화면에 잘못된 기획**</br>
모음의 메인화면인 지역구 별 음식점 종류 선택화면은 기획적으론 괜찮지만 각 지역구에 해당하는 API들이 전부 다르기 때문에 해당 화면을 구현하기 위해선 너무 많은 데이터를 필요로 했습니다. 개발적 관점으로 봤을 땐 지역구 별 음식점 종류를 선택하는게 아니라 지역구를 선택하는 방향으로 진행했다면 불필요한 API 호출을 줄일 수 있었을 것 같습니다.

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
