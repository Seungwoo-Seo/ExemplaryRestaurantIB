//
//  Store.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/08/09.
//

import Foundation

struct Store: Decodable {
    // 시군구코드
    let gooCode: String?
    // 지정번호
    let assignationNumber: String?
    // 신청일자
    let signUpDay: String?
    // 지정일자
    let assignationSelectedDay: String?
    // 업소명
    let name: String?
    // 소재지도로명
    let roadAddress: String?
    // 소재지지번
    let address: String?
    // 허가(신고)번호
    let permissionNumber: String?
    // 업태명
    let businessType: String?
    // 주된음식
    let mainMenu: String?
    // 소재지전화번호
    let phoneNumber: String?
    // 고유 id
    let uid: String?
    
}





