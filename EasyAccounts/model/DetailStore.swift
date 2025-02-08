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

class DetailStore: ObservableObject {
    @Published var flowListDto = FlowListDto(totalIn: "", totalOut: "", totalEarn: nil, typeList: nil, flows: [])
    
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
}
