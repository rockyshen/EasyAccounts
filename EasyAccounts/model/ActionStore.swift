//
//  ActionStore.swift
//  EasyAccounts
//  Action实体类，提供默认值
//  Created by 沈俊杰 on 2025/2/10.
//

import Foundation

struct Action: Identifiable, Codable {
    var id: Int
    var hname: String
    var exempt: Bool
    var handle: Int
}

class ActionStore: ObservableObject{
    @Published var actions: [Action] = []
    
    // action初始化完成后，一般不会经常更新
    init() {
        actions = [
            .init(id: 15, hname: "收入", exempt: false, handle: 0),
            .init(id: 16, hname: "支出", exempt: false, handle: 1),
            .init(id: 17, hname: "内部转账", exempt: false, handle: 2),
            .init(id: 18, hname: "借入", exempt: true, handle: 0),
            .init(id: 19, hname: "还钱", exempt: true, handle: 1),
            .init(id: 20, hname: "借出", exempt: true, handle: 1),
            .init(id: 21, hname: "收钱", exempt: true, handle: 0),
        ]
    }
    
    // 根据hName，返回actionId
    func getActionIdByhame(hname: String) -> Int? {
        for action in actions {
            if action.hname == hname {
                return action.id
            }
        }
        return nil
    }
    
    // 根据actionId，返回actionName
    func getActionNameById(actionId: Int) -> String? {
        for action in actions {
            if action.id == actionId {
                return action.hname
            }
        }
        return nil
    }
    
    // 根据actionId，返回handle
    func getHandleById(actionId: Int)->Int{
        
        return 0
    }
    
    // 根据actionId,返回exempt
    func getExemptById(actionId: Int)->Bool{
        
        return false
    }
}
