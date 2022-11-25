//
//  BusinessTypeSeletModel.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/24.
//

import Foundation

struct BusinessTypeSeletModel {
    
    // 업태명 배열
    var businessTypeList: [String] = []
    
    // 해당 업태명과 매칭해 줄 이미지 이름들
    let businessTypeImageList = [
        "한식": "bibimbap",
        "경양식": "tonkatsu",
        "기타": "guitar",
        "중국식": "mando",
        "일식": "sushi",
        "뷔페식": "buffet",
        "식육(숯불구이)": "meat",
        "외국음식전문점(인도,태국등)": "salnoodle",
        "호프/통닭": "beer",
        "분식": "tteokbokki",
        "복어취급": "pufferfish",
        "탕류(보신용)": "seolleongtang",
        "회집": "fish",
        "패스트푸드": "hamburger",
        "통닭(치킨)": "chicken",
        "정종/대포집/소주방": "soju",
        "냉면집": "naengmyeon",
        "공공기관": "public",
        "까페": "cafe",
        "김밥(도시락)": "kimbap",
        "산업체": "industry"
    ]
    
    // 현재 행정구 명과 코드
    var nowGooType: (gooName: String, gooCode: String?) =
    ("서울전체", nil)
    
    // 해당 행정구명과 매칭해 줄 행정구 별 코드
    let gooTypeList: [(gooName: String, gooCode: String?)] = [
        ("서울전체", nil),
        ("강남구", "3220000"),
        ("강동구", "3240000"),
        ("강북구", "3080000"),
        ("강서구", "3150000"),
        ("관악구", "3200000"),
        ("광진구", "3040000"),
        ("구로구", "3160000"),
        ("금천구", "3170000"),
        ("노원구", "3100000"),
        ("도봉구", "3090000"),
        ("동대문구", "3050000"),
        ("동작구", "3190000"),
        ("마포구", "3130000"),
        ("서대문구", "3120000"),
        ("서초구", "3210000"),
        ("성동구", "3030000"),
        ("성북구", "3070000"),
        ("송파구", "3230000"),
        ("양천구", "3140000"),
        ("영등포구", "3180000"),
        ("용산구", "3020000"),
        ("은평구", "3110000"),
        ("종로구", "3000000"),
        ("중구", "3010000"),
        ("중랑구", "3060000")
    ]
    
}
