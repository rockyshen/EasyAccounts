//
//  AccountStore.swift
//  EasyAccounts
//  Account实体类，提供默认值
//  Created by 沈俊杰 on 2025/2/10.
//

import Foundation

struct AccountResponse: Codable {
    let code: Int
    let data: [AccountResponseDto]?
    let msg: String?
}

struct AccountResponseDto: Identifiable, Codable {
    var id: Int?              // 当新增一个账户时，id可能为空，由数据库自增
    var name: String
    var money: String
    var exemptMoney: String
    var card: String
    var createTime: String?
    var note: String
}



class AccountStore: ObservableObject {
    @Published var accountResponseDtoList = [AccountResponseDto(id: 0, name: "", money: "", exemptMoney: "", card: "", note: "")]
    
    init(){
        loadAccounts()
        
    }
    
    // 向后端请求获取所有账户信息列表
    func loadAccounts() {
        let url = URL(string: "http://localhost:8085/account/getAccount")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(AccountResponse.self, from: data) else {
                    print("Unable to decode JSON data")
                    return
            }
            
            DispatchQueue.main.async {
                self.accountResponseDtoList = baseDto.data!
            }
        }.resume()
    }
    
    // 更新账户
    // 注意是PUT请求，不是 POST请求 http://localhost:8085/account/updateAccount/{id}
    func updateAccount(account: AccountResponseDto){
        // 构建 URL，将 account.id 插入到 URL 路径中
        guard let url = URL(string: "http://localhost:8085/account/updateAccount/\(account.id!)") else {
            print("Invalid URL")
            return
        }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(account)
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
                    let jsonResponse = try JSONDecoder().decode(AccountResponse.self, from: data)
                    print("JSON: \(jsonResponse)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
        task.resume()
    }
    
    // 增加一个新账户
    // http://localhost:8085/account//addAccount
    func addAccount(account: AccountResponseDto){
        let url = URL(string: "http://localhost:8085/account/addAccount")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        do {
            let jsonData = try JSONEncoder().encode(account)
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
                    let jsonResponse = try JSONDecoder().decode(AccountResponseDto.self, from: data)
                    print("JSON: \(jsonResponse)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
        task.resume()
        
    }
    
}
