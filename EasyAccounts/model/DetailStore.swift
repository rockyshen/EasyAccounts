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

// addFlow时，请求体（与后端响应格式一致）
struct FlowAddRequestDto: Codable {
    var money: String       // 账单金额
    var fDate: String       // 账单日期（手动选择）
    var createDate: String  // 系统生成的日期
    var actionId: Int       // 收入 or 支出
    var accountId: Int      // 账户的id
    var accountToId: Int    // 转账情况下的目标账户id（非转账时为0）
    var typeId: Int         // 账单分类
    var isCollect: Bool     // 是否收藏（后端字段名是 isCollect）
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
    func loadData() {
        let url = URL(string: "\(APIConfig.baseURL)/flow/getFlowListMain/3/0/\(yearAndMonth)")!
        print("📅 加载流水 URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("❌ No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // 打印响应内容便于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("📅 流水响应: \(responseString)")
            }
            
            do {
                let baseDto = try JSONDecoder().decode(DetailResponse.self, from: data)
                DispatchQueue.main.async {
                    self.flowListDto = baseDto.data
                    print("✅ 流水加载成功，共 \(baseDto.data.flows.count) 条")
                }
            } catch {
                print("❌ JSON decode error: \(error)")
                // 解析失败时，设置空数据，避免显示旧数据
                DispatchQueue.main.async {
                    self.flowListDto = FlowListDto(
                        totalIn: "0",
                        totalOut: "0",
                        totalEarn: "0",
                        typeList: [],
                        flows: []
                    )
                }
            }
        }.resume()
    }
    
    // 增：添加一条流水记录
    func addFlow(flowAddRequestDto: FlowAddRequestDto){
        if let url = URL(string: "\(APIConfig.baseURL)/flow/addFlow") {
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
    
    // 删：删除一条流水记录
    // http://localhost:8085/flow/deleteFlow/{id}
    func deleteFlow(flowId: Int){
        print("═══════════════════════════════════════")
        print("🗑️ 开始删除流水...")
        print("🗑️ Flow ID: \(flowId)")
        
        guard let url = URL(string: "\(APIConfig.baseURL)/flow/deleteFlow/\(flowId)") else {
            print("❌ Invalid URL")
            return
        }
        
        print("🗑️ 请求 URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 打印响应状态码
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 响应状态码: \(httpResponse.statusCode)")
            }
            
            // 打印响应内容
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📥 响应内容: \(responseString)")
            }
            
            if let error = error {
                print("❌ 请求错误: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ 服务器错误")
                return
            }
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 在成功删除之后，更新本地数据
                self.flowListDto.flows.removeAll { $0.id == flowId }
                print("✅ 删除成功，已从本地列表移除")
                print("═══════════════════════════════════════")
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
        guard let url = URL(string: "\(APIConfig.baseURL)/flow/updateFlow/\(flowId)") else {
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
    func makeExcel(completion: @escaping (Bool, String) -> Void) {
        let url = URL(string: "\(APIConfig.baseURL)/flow/makeExcel/\(yearAndMonth)")!
        print("📊 生成报表 URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, "网络请求失败：\(error?.localizedDescription ?? "未知错误")")
                }
                return
            }
            
            // 打印响应内容便于调试
            if let responseString = String(data: data, encoding: .utf8) {
                print("📊 报表响应: \(responseString)")
            }
            
            // 尝试解析为通用响应格式
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let code = json["code"] as? Int {
                    let msg = json["msg"] as? String ?? ""
                    DispatchQueue.main.async {
                        if code == 0 {
                            completion(true, "✅ 报表生成成功，已发邮件")
                        } else {
                            completion(false, "生成失败：\(msg)")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "响应格式错误")
                    }
                }
            } catch {
                print("📊 报表解析错误: \(error)")
                DispatchQueue.main.async {
                    completion(false, "响应解析失败：\(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // 调用后端AI识别账单，自动追加流水的能力
    // http://localhost:8085/flow/analyzeFlowByAi
    func uploadImageAndGetTaskId(flowImg: UIImage, completion: @escaping (String) -> Void){
        DispatchQueue.global().async {
            // 压缩图像以确保其小于 1MB，因为后端限制1MB，否则拒收
            let maximumFileSize = 1048576 // 1MB
            let compressionQuality: CGFloat = 1.0
            var imageData: Data?
            
            // 尝试以不同的压缩比获取图片数据
            for quality in stride(from: compressionQuality, through: 0, by: -0.1) {
                if let compressedData = flowImg.jpegData(compressionQuality: quality) {
                    if compressedData.count < maximumFileSize {
                        imageData = compressedData
                        print("📷 图片压缩成功，质量: \(quality)，大小: \(compressedData.count) bytes")
                        break
                    }
                }
            }
            
            // 将 UIImage 转换为 JPEG 数据
            guard let jpegData = imageData else {
                print("❌ 图片压缩失败：无法将图片压缩到1MB以内")
                DispatchQueue.main.async {
                    completion("😭 图片压缩失败")
                }
                return
            }
            
            // 创建请求的 URL
            let urlString = "\(APIConfig.baseURL)/flow/analyzeFlowByAi"
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL: \(urlString)")
                DispatchQueue.main.async {
                    completion("😭 URL无效")
                }
                return
            }
            
            print("📤 AI识别请求 URL: \(url)")
            
            // 创建可变请求对象
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
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
            
            print("📤 请求体大小: \(body.count) bytes")
            
            // 创建 URLSession 数据任务
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // 处理网络错误
                if let error = error {
                    print("❌ 网络请求错误: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion("😭 网络错误: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ 无效的响应")
                    DispatchQueue.main.async {
                        completion("😭 无效响应")
                    }
                    return
                }
                
                print("📥 响应状态码: \(httpResponse.statusCode)")
                
                // 打印响应内容
                if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                    print("📥 响应内容: \(responseString)")
                }
                
                // 检查响应状态码
                if (200...299).contains(httpResponse.statusCode) {
                    print("✅ 图片上传成功!")
                    
                    // 如果服务器返回了 JSON 数据，可以在此处解析
                    if let responseData = data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                               let taskId = json["data"] as? String {
                                print("✅ 获取到任务ID: \(taskId)")
                                DispatchQueue.main.async {
                                    completion(taskId)
                                }
                            } else {
                                print("⚠️ 响应格式不符合预期，但上传成功")
                                DispatchQueue.main.async {
                                    completion("👍添加成功")
                                }
                            }
                        } catch {
                            print("❌ JSON解析失败: \(error)")
                            DispatchQueue.main.async {
                                completion("😭 解析响应失败")
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion("👍上传成功")
                        }
                    }
                } else {
                    // 非200响应，上传失败
                    print("❌ 服务器返回错误，状态码: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion("😭 上传失败，状态码: \(httpResponse.statusCode)")
                    }
                }
            }
            // 启动http请求任务
            task.resume()
            print("📤 请求已发送...")
        }
    }
        
    // 基于上一步获得的task_id，获得执行情况，code=0表示已经完成解析并更新入数据库；如果code=500表示还未完成
    // taskId有可能不传，证明没有AI分析任务，就是普通的刷新
    func getAnalysisResult(taskId: String?, completion: @escaping (Bool, String) -> Void) {
        // 如果没有taskId，说明没有AI任务，直接加载
        guard let taskId = taskId, !taskId.isEmpty else {
            print("🔄 无AI任务，直接加载数据")
            completion(true, "直接加载，无AI任务")
            return
        }
        
        DispatchQueue.global().async {
            guard let url = URL(string: "\(APIConfig.baseURL)/flow/getAnalyzeFlowByAiResult?taskId=\(taskId)") else {
                print("❌ Invalid URL")
                DispatchQueue.main.async {
                    completion(false, "😭 查询失败：无效URL")
                }
                return
            }
            
            print("🤖 查询AI分析结果...")
            print("📤 请求URL: \(url)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // 打印响应状态码
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 响应状态码: \(httpResponse.statusCode)")
                }
                
                if let error = error {
                    print("❌ 网络请求错误: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(false, "😭 网络请求失败: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let responseData = data else {
                    print("❌ 没有返回数据")
                    DispatchQueue.main.async {
                        completion(false, "😭 没有返回数据")
                    }
                    return
                }
                
                do {
                    // 打印原始响应内容
                    if let rawString = String(data: responseData, encoding: .utf8) {
                        print("═══════════════════════════════════════")
                        print("🤖 AI分析结果（原始响应）:")
                        print(rawString)
                        print("═══════════════════════════════════════")
                    }
                    
                    if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                        let code = json["code"] as? Int ?? -1
                        let msg = json["msg"] as? String ?? ""
                        
                        print("📊 响应解析:")
                        print("   - code: \(code)")
                        print("   - msg: \(msg)")
                        
                        // 打印 data 字段（AI识别出的流水数据）
                        if let dataField = json["data"] {
                            print("   - data: \(dataField)")
                        }
                        
                        if code == 0 {
                            print("✅ AI分析完成，数据已写入")
                            DispatchQueue.main.async {
                                completion(true, "解析完成")
                            }
                        } else if code == 500 && msg == "数据已写入，无需重复操作" {
                            print("✅ 数据已存在，无需重复操作")
                            DispatchQueue.main.async {
                                completion(true, "已存在，直接加载")
                            }
                        } else {
                            print("⏳ 解析未完成，code=\(code), msg=\(msg)")
                            DispatchQueue.main.async {
                                completion(false, "解析未完成，请稍后再试")
                            }
                        }
                    } else {
                        print("❌ JSON解析失败：无法转换为字典")
                        DispatchQueue.main.async {
                            completion(false, "😭 解析JSON失败")
                        }
                    }
                } catch {
                    print("❌ JSON解析异常: \(error)")
                    DispatchQueue.main.async {
                        completion(false, "😭 JSON解析异常")
                    }
                }
            }
            task.resume()
        }
    }
}
    
