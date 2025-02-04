//
//  FlowStore.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/4.
//

import Foundation

struct Flow: Identifiable, Codable {
    let id: UUID = UUID()
    let date: String
    let category: String
    let amount: String
    let type: String
    let method: String
}

@Observable
class FlowStore{
    var flows: [Flow] = []
    
    init() {
        flows = [
            .init(date: "2024-08-25", category: "生活/吃饭", amount: "-¥33.00", type: "支出", method: "微信"),
            .init(date: "2024-08-25", category: "工资/绩效", amount: "+¥3003.00", type: "收入", method: "支付宝")
        ]
        
    }
}
