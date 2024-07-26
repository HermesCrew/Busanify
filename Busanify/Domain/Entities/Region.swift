//
//  Region.swift
//  Busanify
//
//  Created by 장예진 on 7/26/24.
//


import Foundation


struct Region {
    let name: String
    let latitude: Double
    let longitude: Double
}

struct Regions {
    static let all: [Region] = [
        Region(name: "강서구", latitude: 35.20916389, longitude: 128.9829083),
        Region(name: "금정구", latitude: 35.24007778, longitude: 129.0943194),
        Region(name: "남구", latitude: 35.13340833, longitude: 129.0865),
        Region(name: "동구", latitude: 35.13589444, longitude: 129.059175),
        Region(name: "동래구", latitude: 35.20187222, longitude: 129.0858556),
        Region(name: "부산진구", latitude: 35.15995278, longitude: 129.0553194),
        Region(name: "북구", latitude: 35.19418056, longitude: 128.992475),
        Region(name: "사상구", latitude: 35.14946667, longitude: 128.9933333),
        Region(name: "사하구", latitude: 35.10142778, longitude: 128.9770417),
        Region(name: "서구", latitude: 35.09483611, longitude: 129.0263778),
        Region(name: "수영구", latitude: 35.14246667, longitude: 129.115375),
        Region(name: "연제구", latitude: 35.17318611, longitude: 129.082075),
        Region(name: "영도구", latitude: 35.08811667, longitude: 129.0701861),
        Region(name: "중구", latitude: 35.10321667, longitude: 129.0345083),
        Region(name: "해운대구", latitude: 35.16001944, longitude: 129.1658083),
        Region(name: "기장군", latitude: 35.24477541, longitude: 129.2222873)
    ]
}
