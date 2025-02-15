//
//  FlowList.swift
//  EasyAccounts
//  流水列表的视图
//  Created by 沈俊杰 on 2025/2/4.
//

import SwiftUI

struct FlowList: View {
    var flows: [FlowListSingleDto]
    
    var body: some View {
        List {
            ForEach(flows) {flow in
                FlowView(flow: flow)
                    .swipeActions(edge: .trailing){
                        Button("删除",role: .destructive){
                            // TODO 实现删除这一条Flow的逻辑
                        }
                    }
                    .swipeActions(edge: .leading){
                        Button("编辑"){
                            // TODO 实现编辑修改这一条Flow的逻辑
                        }.tint(.blue)
                    }
            }
        }.listStyle(PlainListStyle())
    }
}


//#Preview {
//    FlowList(flowStore: FlowStore())
//}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FlowList(flows: [
            FlowListSingleDto(id: 1, money: "100", exempt: false, collect: true, handle: 1, note: "Test note", toAName: "To A Name", aname: "A Name", tname: "T Name", hname: "收入", fdate: "2022-05-01"),
            FlowListSingleDto(id: 2, money: "200", exempt: true, collect: false, handle: 2, note: "Test note 2", toAName: nil, aname: "A Name 2", tname: "T Name 2", hname: "支出", fdate: "2022-05-02")
        ])
        .previewLayout(.sizeThatFits)
    }
}
