//
//  DetailStore.swift
//  EasyAccounts
//  流水页：发送/getFlowListMain/{chooseHandle}/{chooseOrder}/{date}，返回的响应数据实体类
//  handle=3     order=    date=今天
//  Created by 沈俊杰 on 2025/2/4.
//

import Foundation

// 用后端方法名作为类名，表示是这个类响应的response
struct GetFlowListMainResponse: Codable {
    let code: Int
    let data: FlowListDto
    let msg: String
}

struct FlowListDto: Codable {
    var totalIn: String        // 当月总收入
    var totalOut: String       // 当月总支出
    var totalEarn: String?     // 当月结余
    var typeList: [FlowTypeDto]?
    var flows: [FlowListSingleDto]
}

struct FlowListSingleDto: Codable,Identifiable {
    var id: Int
    var money: String
    var exempt: Bool
    var collect: Bool
    var handle: Int
    var note: String
    var toAName: String?
    var aname: String      // Account名 注意，Java中的实体类是aName，但是JSON返回时是：aname，以JSON为准，否则解析失败！
    var tname: String     // Type名
    var hname: String     // Action名
    var fdate: String
}

struct FlowTypeDto: Codable {
    var typeName: String
    var money: String
    var typeId: Int
    var parent: Bool
    var children: [FlowTypeDto]
}

// addFlow时，请求体
struct FlowAddRequestDto: Codable {
    var money: String      // 账单金额
    var fDate: String      // 账单日期（手动选择）
    var createDate: String  // 系统生成的日期
    var actionId: Int       // 收入 or 支出
    var accountId: Int      // 账户的id
    var accountToId: Int    // 转账情况下，去哪个的账单id
    var typeId: Int         // 账单分类
    var isCollect: Bool     // 是否收藏
    var note: String        // 备注
}

class DetailStore: ObservableObject {
    @Published var flowListDto = FlowListDto(
        totalIn: "300",
        totalOut: "150",
        totalEarn: "150",
        typeList: [
            FlowTypeDto(typeName: "购物", money: "30", typeId: 101, parent: false, children: []),
            FlowTypeDto(typeName: "交通", money: "30", typeId: 101, parent: false, children: []),
            FlowTypeDto(typeName: "娱乐", money: "30", typeId: 101, parent: false, children: []),
            FlowTypeDto(typeName: "工资", money: "30", typeId: 101, parent: false, children: [])
        ],
        flows: [
            FlowListSingleDto(id: 1,
                              money: "100",
                              exempt: false,
                              collect: true,
                              handle: 0,
                              note: "工资收入💰",
                              toAName: "Savings Account",
                              aname: "测试账户",
                              tname: "工资",
                              hname: "收入",
                              fdate: "2023-01-10"),
            FlowListSingleDto(id: 2,
                              money: "200",
                              exempt: true,
                              collect: false,
                              handle: 1,
                              note: "霸王茶姬奶茶🥤",
                              toAName: nil,
                              aname: "Swift Bank",
                              tname: "购物",
                              hname: "支出",
                              fdate: "2023-02-15")
        ]
    )
    
    var yearAndMonth: String{
        didSet { loadData() }
    }
    
    init() {
        // 获取当前日期
        let currentDate = Date()
        // 创建 DateFormatter 并设置格式为 "yyyy-MM"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        // 格式化当前日期
        self.yearAndMonth = dateFormatter.string(from: currentDate)
        
        loadData()
    }
    
    func updateYearAndMonth(selectDate: Date) {
        // 更新属性：yearAndMonth
        // Int转String
        print("Year updated to: \(selectDate)")
//        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let strYearAndMonth = dateFormatter.string(from: selectDate)

        print(strYearAndMonth)
        
        self.yearAndMonth = dateFormatter.string(from: selectDate)
    }
    
    func loadData() {
        // 此处需要通过变量拼接URL 2025-01
        let url = URL(string: "http://localhost:8085/flow/getFlowListMain/3/0/\(yearAndMonth)")!
//        let url = URL(string: "http://118.25.46.207:10670/flow/getFlowListMain/3/0/\(yearAndMonth)")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(GetFlowListMainResponse.self, from: data) else {
                    print("Unable to decode JSON data")
                    return
            }
                        
            // 被Published修饰的属性，必须在主线程上更新
            DispatchQueue.main.async {
                self.flowListDto = baseDto.data
            }
        }.resume()
    }
    
    // 增：添加一条流水记录
    func addFlow(flowAddRequestDto: FlowAddRequestDto){
        if let url = URL(string: "http://localhost:8085/flow/addFlow") {
//        if let url = URL(string: "http://118.25.46.207:10670/flow/addFlow") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // 将 flowAddRequestDto 转换为 JSON 数据
            do {
                let jsonData = try JSONEncoder().encode(flowAddRequestDto)
                request.httpBody = jsonData
            } catch {
                print("Error encoding flowAddRequestDto: \(error)")
                return
            }
            
            // 发起POST请求
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    // TODO 向Published对外发布的属性flowListDto的flows追加这次新增的flow对象，确保其他页面能第一时间更新
                    
                } else if let error = error {
                    print("Error making POST request: \(error)")
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
        
    }
    
    // TODO 删：删除一条流水记录
    func delete(){}
    
    // TODO 改：修改一条流水记录
    func update(){}
    
    // 生成报表按钮
    // http://localhost:8085/flow/makeExcel/2025-02
    func makeExcel() {
        let url = URL(string: "http://localhost:8085/flow/makeExcel/\(yearAndMonth)")!
        print(url)
        
    }
}
