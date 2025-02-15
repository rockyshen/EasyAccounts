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
    @Published var homeDto = HomeDto(
        accounts: [
            HomeAccountBean(accountAsset: "1000",
                            accountName: "测试账户",
                            exemptAsset: "200",
                            id: 1,
                            note: "Main savings account",
                            percent: "10%"),
            HomeAccountBean(accountAsset: "2500",
                            accountName: "Swift Bank",
                            exemptAsset: "300",
                            id: 2,
                            note: "Everyday transactions",
                            percent: "15%")
        ],
        curIncome: "12000",
        curOutCome: "8000",
        netAsset: "19000",
        totalAsset: "20000",
        yearBalance: "4000",
        yearIncome: "150000",
        yearOutCome: "100000")
    
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

