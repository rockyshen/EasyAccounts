//
//  ScreenView.swift
//  EasyAccounts
//  筛选页
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct ScreenView: View {
    @State private var is备注筛选Toggled = false
    @State private var selectedTimePeriod = "当月"
    @State private var selectedDateRange = "当月"
    
    // TODO 是不是应该有父级视图传递，不能重复实例化store
    @StateObject var detailStore = DetailStore()
    @StateObject var accountStore = AccountStore()
    @StateObject var actionStore = ActionStore()
    @StateObject var typeStore = TypeStore()
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("备注筛选")
                    .foregroundColor(.blue)
                Spacer()
                Text("筛选")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    // Add functionality for more button
                }) {
                    Text("更多条件")
                        .foregroundColor(.blue)
                }
            }
            .padding()
//                .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Search bar
            HStack {
                TextField("请输入备注关键词", text: .constant(""))
                    .padding(.vertical,10)
                    .padding(.horizontal,5)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                Text("搜索")
                Spacer()
            }
            .padding()
            
            // Time period selection
            VStack(alignment: .leading) {
                HStack {
                    Text("快速切换").foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // 设置左右边距
                .overlay(
                    HStack {
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 右侧横线
                    }
                )
//                .padding(.vertical, 10) // 设置上下边距
            }
            .padding(.horizontal,10)
            
            HStack {
                ForEach(["当月", "上月", "全年", "上年"], id: \.self) { range in
                    Button(action: {
                        self.selectedDateRange = range
                    }) {
                        HStack {
                            Image(systemName: range == self.selectedDateRange ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                            Text(range)
                                .foregroundColor(.black)
                        }
                        .frame(width: 80, height: 40)
                        .cornerRadius(20)
                    }
                }
            }
            
            // Current period income and expenditure
            VStack(alignment: .leading) {
                HStack {
                    Text("当期收支情况").foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // 设置左右边距
                .overlay(
                    HStack {
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 右侧横线
                    }
                )
                .padding(10) // 设置上下边距
                
                HStack {
                    Text("当期总收入")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Text("¥300.00")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button(action: {
                        // Add functionality for view details button
                    }) {
                        Text("查看分类明细")
                            .foregroundColor(.blue)
                            .padding(.horizontal,10)
                    }
                }.padding(.horizontal,10)
                
                HStack {
                    Text("本年结余：¥267.00")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .padding(.horizontal,10)
            }
//            .padding()
            
            // Current bill overview
            VStack(alignment: .leading) {
                HStack {
                    Text("当期账单概览").foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10) // 设置左右边距
                .overlay(
                    HStack {
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.blue) // 右侧横线
                    }
                )
//                .padding(.vertical, 10) // 设置上下边距
                
                FlowList(flows: detailStore.flowListDto.flows, detailStore: detailStore,
                    accountStore: accountStore,
                    actionStore: actionStore,
                    typeStore: typeStore
                )
            }
            .padding(10)
        }
    }
}



#Preview {
    ScreenView()
}
