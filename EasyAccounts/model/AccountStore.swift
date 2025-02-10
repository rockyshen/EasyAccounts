//
//  AccountStore.swift
//  EasyAccounts
//  Account实体类，提供默认值
//  Created by 沈俊杰 on 2025/2/10.
//

import Foundation

struct AccountResponse: Codable {
    let code: Int
    let data: [AccountResponseDto]
    let msg: String?
}

struct AccountResponseDto: Identifiable, Codable {
    var id: Int
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
    //
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
                self.accountResponseDtoList = baseDto.data
            }
        }.resume()
    }
    
    
}
