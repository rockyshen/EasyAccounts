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
    var totalIn: String
    var totalOut: String
    var totalEarn: String?
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
    var aname: String      // 注意，Java中的实体类是aName，但是JSON返回时是：aname，以JSON为准，否则解析失败！
    var tname: String
    var hname: String
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
    @Published var flowListDto = FlowListDto(totalIn: "", totalOut: "", totalEarn: nil, typeList: nil, flows: []){
        didSet {
            // 属性flowListDto一有更新，就刷新界面
            // TODO 这里必须优化！否则就是不断给后端发请求！
            loadData()
        }
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        // TODO 此处需要通过变量拼接URL
        let url = URL(string: "http://localhost:8085/flow/getFlowListMain/3/0/2025-02")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(GetFlowListMainResponse.self, from: data) else {
                    print("Unable to decode JSON data")
                    return
            }
            
//            do {
//                let baseDto = try JSONDecoder().decode(GetFlowListMainResponse.self, from: data)
//                // 解码成功
//                self?.FlowListDto = baseDto.data
//                print(baseDto.data)
//            } catch {
//                print("Error decoding JSON data: \(error)")
//            }
            
            // TODO 不允许用副线程修改 Published 的属性，但是开了，数据获取不到，都是nil
            // 先这样，完成比完美更重要
            DispatchQueue.main.async {
                self.flowListDto = baseDto.data
            }
        }.resume()
    }
    
    // 增：添加一条流水记录
    func addFlow(flowAddRequestDto: FlowAddRequestDto){
//        print(flowAddRequestDto)
        if let url = URL(string: "http://localhost:8085/flow/addFlow") {
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
                } else if let error = error {
                    print("Error making POST request: \(error)")
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
        
    }
    
    // 删：删除一条流水记录
    func delete(){}
    
    // 改：修改一条流水记录
    func update(){}
}
