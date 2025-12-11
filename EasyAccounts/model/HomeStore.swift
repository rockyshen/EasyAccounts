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

// 月度数据结构
struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let income: String
    let expense: String
    let balance: String
}

// 用于解析月度流水 API 响应
struct MonthlyFlowResponse: Codable {
    let code: Int
    let data: MonthlyFlowData?
    let msg: String?
}

struct MonthlyFlowData: Codable {
    let totalIn: String
    let totalOut: String
    let totalEarn: String?
}

class HomeStore: ObservableObject {
    // 缓存 Key
    private static let homeDtoCacheKey = "HomeStore.homeDto"
    
    // Published注解，必须声明为实例对象（初始为空数据，从缓存加载）
    @Published var homeDto = HomeDto(
        accounts: [],
        curIncome: "0",
        curOutCome: "0",
        netAsset: "0",
        totalAsset: "0",
        yearBalance: "0",
        yearIncome: "0",
        yearOutCome: "0"
    )
    
    // 月度数据列表
    @Published var monthlyDataList: [MonthlyData] = []
    @Published var isLoadingMonthly = false
    
    init() {
        // 优先从缓存加载数据
        loadFromCache()
        // 然后从网络刷新
        loadData()
        // 默认加载当前年份的月度数据
        loadMonthlyData(year: Calendar.current.component(.year, from: Date()))
    }
    
    // 从缓存加载数据
    private func loadFromCache() {
        if let data = UserDefaults.standard.data(forKey: Self.homeDtoCacheKey),
           let cached = try? JSONDecoder().decode(HomeDto.self, from: data) {
            self.homeDto = cached
            print("📦 HomeStore: 从缓存加载数据成功")
        }
    }
    
    // 保存数据到缓存
    private func saveToCache() {
        if let data = try? JSONEncoder().encode(homeDto) {
            UserDefaults.standard.set(data, forKey: Self.homeDtoCacheKey)
            print("💾 HomeStore: 数据已保存到缓存")
        }
    }
    
    // 加载"总览页"数据
    func loadData() {
        let url = URL(string: "\(APIConfig.baseURL)/home/getHomeInfo")!
        
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
                // 保存到缓存
                self.saveToCache()
            }
        }.resume()
    }
    
    // 加载指定年份的月度数据
    func loadMonthlyData(year: Int) {
        DispatchQueue.main.async {
            self.isLoadingMonthly = true
            self.monthlyDataList = []
        }
        
        let group = DispatchGroup()
        var results: [(month: Int, data: MonthlyData)] = []
        let resultsLock = NSLock()
        
        // 获取当前年月，用于判断是否需要请求未来月份
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        for month in 1...12 {
            // 如果是当前年份，只请求到当前月份
            if year == currentYear && month > currentMonth {
                continue
            }
            // 如果是未来年份，跳过
            if year > currentYear {
                continue
            }
            
            group.enter()
            let yearMonth = String(format: "%d-%02d", year, month)
            let url = URL(string: "\(APIConfig.baseURL)/flow/getFlowListMain/3/0/\(yearMonth)")!
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { group.leave() }
                
                guard let data = data else {
                    print("📅 \(yearMonth) 请求失败: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(MonthlyFlowResponse.self, from: data)
                    if let flowData = response.data {
                        let monthData = MonthlyData(
                            month: "\(month)月",
                            income: flowData.totalIn,
                            expense: flowData.totalOut,
                            balance: flowData.totalEarn ?? "0.00"
                        )
                        resultsLock.lock()
                        results.append((month: month, data: monthData))
                        resultsLock.unlock()
                    }
                } catch {
                    print("📅 \(yearMonth) 解析失败: \(error)")
                }
            }.resume()
        }
        
        // 所有请求完成后，按月份排序并更新 UI
        group.notify(queue: .main) {
            self.monthlyDataList = results
                .sorted { $0.month < $1.month }
                .map { $0.data }
            self.isLoadingMonthly = false
            print("📊 已加载 \(year) 年 \(self.monthlyDataList.count) 个月的数据")
        }
    }
}
