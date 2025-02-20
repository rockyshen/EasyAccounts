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
    @Published var accountResponseDtoList = [AccountResponseDto(id: 0, name: "测试账户", money: "100", exemptMoney: "0", card: "0000-1111-2222-3333", note: "📝备注：测试账户")]
    
    init(){
        loadAccounts()
    }
    
    // 向后端请求获取所有账户信息列表
    func loadAccounts() {
//        let url = URL(string: "http://localhost:8085/account/getAccount")!
        let url = URL(string: "http://118.25.46.207:10670/account/getAccount")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(AccountResponse.self, from: data) else {
                    print("Unable to decode JSON data")
                    return
            }
            
            // 只有更新了store属性，其他视图才会自动刷新
            DispatchQueue.main.async {
                self.accountResponseDtoList = baseDto.data!
            }
        }.resume()
    }
    
    // 更新账户
    func updateAccount(account: AccountResponseDto){
        // 构建 URL，将 account.id 插入到 URL 路径中
//        guard let url = URL(string: "http://localhost:8085/account/updateAccount/\(account.id!)") else {
        guard let url = URL(string: "http://118.25.46.207:10670/account/updateAccount/\(account.id!)") else {
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
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 在成功更新的情况下，更新本地数据
                // 测试：已经更新进去了！
                if let index = self.accountResponseDtoList.firstIndex(where: { $0.id == account.id }) {
                    self.accountResponseDtoList[index] = account
                }
            }
        }
        task.resume()
    }
    
    // 增加一个新账户
    func addAccount(account: AccountResponseDto){
        let url = URL(string: "http://localhost:8085/account/addAccount")!
//        let url = URL(string: "http://118.25.46.207:10670/account/addAccount")!
            
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
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 在成功新增之后，通过网络再请求一次loadAccounts()，本地更新不行，因为没有id
                // addAccount向后端传递的时候，id还没有生成，是nil（且后端响应也没有响应受影响的id或实体类，这是不对的，我去修改后端响应）
                self.loadAccounts()
            }
        }
        task.resume()
    }
    
    // 删除一个账户
    func deleteAccount(account: AccountResponseDto) {
//        guard let url = URL(string: "http://localhost:8085/account/deleteAccount/\(account.id!)") else {
        guard let url = URL(string: "http://118.25.46.207:10670/account/deleteAccount/\(account.id!)") else {
                print("Invalid URL")
                return
            }
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        do {
            // TODO 其实删除account不用把account这个实体类封装进来，只要一个accountId就可以了
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
                    let jsonResponse = try JSONDecoder().decode(TypeResponse.self, from: data)
                    print("JSON: \(jsonResponse)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 在成功新增之后，更新本地数据
                self.accountResponseDtoList.removeAll { $0.id == account.id }
                
                // TODO 同步更新总览页的账户信息
            }
        }
        task.resume()
    }
    
    // 根据Account的名字，返回accountId
    func getAccountIdByName(accountName: String) -> Int? {
        // TODO 补充代码，基于accountName获取该accountName的accountId
        for account in accountResponseDtoList {
            if account.name == accountName {
                return account.id
            }
        }
        return nil
    }
    
    // 根据Account的ID，返回accountName
    func getAccountNameById(accountId: Int)-> String? {
        for account in accountResponseDtoList {
            if account.id == accountId {
                return account.name
            }
        }
        return nil
    }
    
    
}
