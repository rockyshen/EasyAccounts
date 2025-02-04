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
    
//    struct Transaction {
//        let id = UUID()
//        let date: String
//        let category: String
//        let amount: String
//        let type: String
//    }
//    
//    let transactions = [
//        Transaction(date: "2024-08-25", category: "生活/吃饭", amount: "-¥33.00", type: "支出"),
//        Transaction(date: "2024-08-25", category: "工资/绩效", amount: "+¥3003.00", type: "收入")
//    ]
    
    @State private var flowStore = FlowStore()
    
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
                .padding(.vertical, 10) // 设置上下边距
            }
            .padding(.horizontal,10)
            
            HStack {
                ForEach(["当月", "上月", "全年", "上年"], id: \.self) { range in
                    Button(action: {
                        self.selectedDateRange = range
                    }) {
                        HStack {
                            Image(systemName: range == self.selectedDateRange ? "checkmark.circle.fill" : "circle")
                                .font(.title)
                            Text(range)
                                .foregroundColor(.black)
                        }
                        .frame(width: 80, height: 40)
                        .cornerRadius(20)
                    }
                }
            }
            .padding()
            
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
                .padding(.vertical, 10) // 设置上下边距
                
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
                    }
                }
                HStack {
                    Text("本年结余：¥267.00")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
            .padding()
            
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
                .padding(.vertical, 10) // 设置上下边距
                
                FlowList(flowStore: flowStore)
//                    ForEach(transactions, id: \.id) { transaction in
//                        HStack {
//                            Text(transaction.date)
//                                .font(.subheadline)
//                                .foregroundColor(.black)
//                            Text(transaction.category)
//                                .font(.subheadline)
//                                .foregroundColor(.black)
//                            Spacer()
//                            Text(transaction.amount)
//                                .font(.subheadline)
//                                .foregroundColor(transaction.type == "支出" ? .red : .green)
//                            Image(systemName: transaction.type == "支出" ? "minus.circle.fill" : "plus.circle.fill")
//                                .foregroundColor(transaction.type == "支出" ? .red : .green)
//                        }
//                        Divider()
//                            .background(Color.gray.opacity(0.5)) // 设置分割线颜色
//                        .padding()
////                        .background(Color.white)
////                        .cornerRadius(8)
////                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//                    }
            }
            .padding()
        }
    }
}



#Preview {
    ScreenView()
}
