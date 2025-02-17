//
//  DetailStore.swift
//  EasyAccounts
//  流水页：发送/getFlowListMain/{chooseHandle}/{chooseOrder}/{date}，返回的响应数据实体类
//  handle=3     order=    date=今天
//  Created by 沈俊杰 on 2025/2/4.
//

import Foundation
import SwiftUI

// 用后端方法名作为类名，表示是这个类响应的response
struct DetailResponse: Codable {
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
    var handle: Int         // 账户金额：增加=0、减少=1、不变=2
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

// 生成月度Excel的实体类
struct MonthExcelData {
    var currentMonth: String
    var monthTotalIn: String
    var monthTotalOut: String
    var monthTotalEarn: String
    var allAsset: String
    var flow: [Flow]
    var excelAccounts: [Account]

    // Optionally, you can add initializers or methods if needed
}

// MonthExcelData内部声明的Flow和Account
struct Account {
    var accountName: String
    var accountMoney: String
}

struct Flow {
    var flowDate: String
    var actionName: String
    var typeName: String
    var accountName: String
    var money: String
    var note: String
}


class DetailStore: ObservableObject {
    @Published var flowListDto = FlowListDto(
        totalIn: "300",
        totalOut: "150",
        totalEarn: "150",
        typeList: [
            FlowTypeDto(typeName: "购物", money: "30", typeId: 101, parent: false, children: []),
            FlowTypeDto(typeName: "交通", money: "30", typeId: 102, parent: false, children: []),
            FlowTypeDto(typeName: "娱乐", money: "30", typeId: 103, parent: false, children: []),
            FlowTypeDto(typeName: "工资", money: "30", typeId: 104, parent: false, children: [])
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
//        let strYearAndMonth = dateFormatter.string(from: selectDate)
        self.yearAndMonth = dateFormatter.string(from: selectDate)
    }
    
    // 加载当月流水信息
    // TODO 为什么失效了呢？
    func loadData() {
        // 此处需要通过变量拼接URL 2025-01
        let url = URL(string: "http://localhost:8085/flow/getFlowListMain/3/0/\(yearAndMonth)")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(DetailResponse.self, from: data) else {
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
    // http://118.25.46.207:10670/flow/addFlow
    func addFlow(flowAddRequestDto: FlowAddRequestDto){
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
    // http://localhost:8085/flow/deleteFlow/{id}
    func deleteFlow(flowId: Int){
        print("准备删除的flow的ID是")
        print(flowId)
        
        guard let url = URL(string: "http://localhost:8085/flow/deleteFlow/\(flowId)") else {
//        guard let url = URL(string: "http://118.25.46.207:10670/account/deleteAccount/\(account.id!)") else {
                print("Invalid URL")
                return
            }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 在成功新增之后，更新本地数据
                // 从属性：flows列表（一组FlowListSingleDto）中找到对应的id,并删除
                self.flowListDto.flows.removeAll { $0.id == flowId }
            }
        }
        task.resume()
    }
    
    // 改：更新一条流水记录
    // http://localhost:8085/flow/updateFlow/{id}
    func updateFlow(flowId: Int, flowAddRequestDto: FlowAddRequestDto){
        // 1、需要该flow的id，这个id不是FlowAddRequestDto的id，而是Flow最后写入mysql时的最终id
        // flows里面的每一个元素的id，就是数据库里flow的最终id
        // 2、需要FlowAddRequestDto实体类
        print(flowAddRequestDto)
        print(flowId)
        
        // URL for the API endpoint
        guard let url = URL(string: "http://localhost:8085/flow//updateFlow/\(flowId)") else {
            print("Invalid URL")
            return
        }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(flowAddRequestDto)
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }
            
            if let mimeType = response?.mimeType, mimeType == "application/json",
               let data = data {
                do {
                    // TODO 更新完flow，响应的data里是nil，所以这里会解析不到！
                    let jsonResponse = try JSONDecoder().decode(DetailResponse.self, from: data)
                    print("JSON: \(jsonResponse)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 和AccountStore下的addAccount情况类似！
                // 性能比较高的是更新本地属性，但是一条Flow牵扯到太多外部条件，
                // 例如FlowListSingleDto <==> FlowAddRequestDto的转换（内部涉及搭配aName转为accountName等复杂查询，
                // 平衡下来，还是重新加载一下数据比较快，完成比完美更重要
                self.loadData()
            }
        }
        task.resume()
    }
    
    // 生成报表按钮
    // http://localhost:8085/flow/makeExcel/2025-02
    func makeExcel() {
        let url = URL(string: "http://localhost:8085/flow/makeExcel/\(yearAndMonth)")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(DetailResponse.self, from: data) else {
                    print("Unable to decode JSON data")
                    return
            }
            
            DispatchQueue.main.async {
                // 导出成功，就答应一下code
                print(baseDto.code)
            }
        }.resume()
    }
    
    // 调用后端AI识别账单，自动追加流水的能力
    // http://localhost:8085/flow/analyzeFlowByAi
    func analyzeFlowByAi(flowImg: UIImage, completion: @escaping (String) -> Void){
        // 压缩图像以确保其小于 1MB，因为后端限制1MB，否则拒收
        let maximumFileSize = 1048576 // 1MB
        let compressionQuality: CGFloat = 1.0
        var imageData: Data?
        
        // 尝试以不同的压缩比获取图片数据
        for quality in stride(from: compressionQuality, through: 0, by: -0.1) {
            if let compressedData = flowImg.jpegData(compressionQuality: quality) {
                if compressedData.count < maximumFileSize {
                    imageData = compressedData
                    break
                }
            }
        }
        
        // 将 UIImage 转换为 JPEG 数据
        guard let jpegData = imageData else {
                print("Failed to compress image within the size limit.")
                return
            }
        
        // 创建请求的 URL
        guard let url = URL(string: "http://localhost:8085/flow/analyzeFlowByAi") else {
            print("Invalid URL")
            return
        }
        
        // 创建可变请求对象
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 生成 boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 构建 multipart/form-data 体
        var body = Data()
        let fileName = "image.jpg"
        let mimeType = "image/jpeg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(jpegData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // 创建 URLSession 数据任务
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 处理响应
            if let error = error {
                print("Error during request: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            // 检查响应状态码
            if (200...299).contains(httpResponse.statusCode) {
                print("Image uploaded successfully!")
                
                // 如果服务器返回了 JSON 数据，可以在此处解析
                if let responseData = data {
                    // 解析服务器返回的数据
                    do {
                        if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                            print("Response JSON: \(json)")
                            
                            if let message = json["msg"], message as! String == "Success" {
                                completion("添加成功")
                            } else {
                                completion("上传失败")
                            }
                        }

                    } catch {
                        print("Failed to parse JSON response: \(error)")
                    }
                }
            } else {
                print("Failed to upload image. HTTP Status Code: \(httpResponse.statusCode)")
            }
        }
        
        // 启动任务
        task.resume()
    }
    
}
