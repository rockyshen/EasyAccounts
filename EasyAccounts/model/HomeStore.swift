//
//  HomeDto.swift
//  EasyAccounts
//  总览页：发送getHomeDto()，返回的响应数据实体类
//  Created by 沈俊杰 on 2025/2/5.
//

import Foundation

struct HomeResponse: Codable {
    let code: Int
    let data: HomeDto
    let msg: String?
}

struct HomeDto: Codable {
    let accounts: [HomeAccountBean]
    let curIncome: String?
    let curOutCome: String?
    let netAsset: String
    let totalAsset: String
    var yearBalance: String
    let yearIncome: String
    let yearOutCome: String
}

struct HomeAccountBean: Codable {
    let accountAsset: String
    let accountName: String
    let exemptAsset: String
    let id: Int
    let note: String
    let percent: String
}

class HomeStore: ObservableObject {
    // Published注解，必须声明为实例对象
    @Published var homeDto = HomeDto(accounts: [], curIncome: nil, curOutCome: nil, netAsset: "", totalAsset: "", yearBalance: "", yearIncome: "", yearOutCome: "")
    
    init() {
        loadData()
    }
    
    // 加载“总览页”数据
    func loadData() {
        let url = URL(string: "http://localhost:8085/home/getHomeInfo")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(HomeResponse.self, from: data) else {
                    print("Unable to decode JSON data")
                    return
            }
            
            DispatchQueue.main.async {
                self.homeDto = baseDto.data
            }
        }.resume()
    }
}

