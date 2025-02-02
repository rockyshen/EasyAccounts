//
//  ScreenView.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct ScreenView: View {
    @State private var is备注筛选Toggled = false
    @State private var selectedTimePeriod = "当月"
    
    struct Transaction {
        let id = UUID()
        let date: String
        let category: String
        let amount: String
        let type: String
    }
    
    let transactions = [
        Transaction(date: "2024-08-25", category: "生活/吃饭", amount: "-¥33.00", type: "支出"),
        Transaction(date: "2024-08-25", category: "工资/绩效", amount: "+¥3003.00", type: "收入")
    ]
    
    var body: some View {
            VStack {
                // Header
                HStack {
                    Text("筛选")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        // Add functionality for more button
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Search bar
                HStack {
                    TextField("请输入备注关键词", text: .constant(""))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    Spacer()
                }
                .padding()
                
                // Toggle for note filtering
                HStack {
                    Toggle("备注筛选", isOn: $is备注筛选Toggled)
                    Spacer()
                    Button(action: {
                        // Add functionality for more conditions button
                    }) {
                        Text("更多条件")
                    }
                }
                .padding()
                
                // Time period selection
                Text("快速切换")
                    .font(.footnote)
                    .foregroundColor(.gray)
                HStack {
                    Button(action: {
                        self.selectedTimePeriod = "当月"
                    }) {
                        Text("当月")
                            .font(selectedTimePeriod == "当月" ? .subheadline : .footnote)
                            .foregroundColor(selectedTimePeriod == "当月" ? .blue : .black)
                    }
                    Button(action: {
                        self.selectedTimePeriod = "上月"
                    }) {
                        Text("上月")
                            .font(selectedTimePeriod == "上月" ? .subheadline : .footnote)
                            .foregroundColor(selectedTimePeriod == "上月" ? .blue : .black)
                    }
                    Button(action: {
                        self.selectedTimePeriod = "全年"
                    }) {
                        Text("全年")
                            .font(selectedTimePeriod == "全年" ? .subheadline : .footnote)
                            .foregroundColor(selectedTimePeriod == "全年" ? .blue : .black)
                    }
                    Button(action: {
                        self.selectedTimePeriod = "上年"
                    }) {
                        Text("上年")
                            .font(selectedTimePeriod == "上年" ? .subheadline : .footnote)
                            .foregroundColor(selectedTimePeriod == "上年" ? .blue : .black)
                    }
                    Button(action: {
                        self.selectedTimePeriod = "自定义"
                    }) {
                        Text("自定义")
                            .font(selectedTimePeriod == "自定义" ? .subheadline : .footnote)
                            .foregroundColor(selectedTimePeriod == "自定义" ? .blue : .black)
                    }
                }
                .padding()
                
                // Current period income and expenditure
                VStack(alignment: .leading) {
                    Text("当期收支情况")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    HStack {
                        Text("当期总收入")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥300.00")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    HStack {
                        Text("本年结余：¥267.00")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Button(action: {
                            // Add functionality for view details button
                        }) {
                            Text("查看分类明细")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                
                // Current bill overview
                VStack(alignment: .leading) {
                    Text("当期账单概览")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    ForEach(transactions, id: \.id) { transaction in
                        HStack {
                            Text(transaction.date)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text(transaction.category)
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Spacer()
                            Text(transaction.amount)
                                .font(.subheadline)
                                .foregroundColor(transaction.type == "支出" ? .red : .green)
                            Image(systemName: transaction.type == "支出" ? "minus.circle.fill" : "plus.circle.fill")
                                .foregroundColor(transaction.type == "支出" ? .red : .green)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                
            }
    }
}



#Preview {
    ScreenView()
}
