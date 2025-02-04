//
//  FlowList.swift
//  EasyAccounts
//  流水列表的视图
//  Created by 沈俊杰 on 2025/2/4.
//

import SwiftUI

struct FlowList: View {
    @Bindable var flowStore: FlowStore
    
    var body: some View {
        List {
            ForEach($flowStore.flows) {flow in
                FlowView(flow: flow)
            }
        }.listStyle(PlainListStyle())
    }
}

#Preview {
    FlowList(flowStore: FlowStore())
}
