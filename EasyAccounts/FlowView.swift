//
//  FlowView.swift
//  EasyAccounts
//  单条流水的视图
//  Created by 沈俊杰 on 2025/2/4.
//

import SwiftUI

struct FlowView: View {
    var flow: FlowListSingleDto
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(flow.fdate)
                .font(.subheadline)
                .foregroundColor(.black)
            HStack{
                Text(flow.tname)
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text(flow.money)
                    .font(.subheadline)
                    .foregroundColor(flow.hname == "支出" ? .red : .green)
                Image(systemName: flow.hname == "支出" ? "minus.circle.fill" : "plus.circle.fill")
                    .foregroundColor(flow.hname == "支出" ? .red : .green)
            }
            
            HStack {
                Text(flow.note)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}

//#Preview {
//    let flow: Flow = Flow(date: "2024-08-25", category: "生活/吃饭", amount: "-¥33.00", type: "支出", method: "微信")
//    FlowView(flow: flow)
//}
//struct FlowView_Previews: PreviewProvider {
//    static var previews: some View {
//        FlowView(flow: .constant(Flow(date: "2024-08-25", category: "生活/吃饭", amount: "-¥33.00", type: "支出", method: "微信")))
//    }
//}
