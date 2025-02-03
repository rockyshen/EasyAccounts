//
//  Flow.swift
//  EasyAccounts
//  流水页
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct FlowView: View {
    @State private var date = Date() // 默认日期为当前日期
    @State private var showingDatePicker = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Header
            HStack {
                Text("流水")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    Button(action: {
                        // Add functionality for menu button
                    }) {
                        Text("记一笔")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.blue)
            
            HStack {
                Button(action: {
                    // 总览按钮的功能
                }) {
                    Text("总览")
                        .font(.title3) // 设置字体大小
                        .foregroundColor(.black) // 设置字体颜色
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .opacity(0.5)
                }
                
                Spacer()
                
                Button(action: {
                    // 按时间排序按钮的功能
                }) {
                    Text("按时间排序")
                        .font(.title3)
                        .foregroundColor(.black)
                    Image(systemName: "arrowtriangle.down.fill")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .opacity(0.5)
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical,10)
            
            
            // Income and expenditure
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("月度收支情况").foregroundColor(.blue)
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
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("当月总收入：")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥300.00")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        // TODO 加入日期选择器之后，三行高度不一致
                        DatePicker(
                            selection: $date,
                            displayedComponents: [.date],
                            label: { Text("选择日期") }
                        )
                        .labelsHidden()
                    }
                        
                    HStack{
                        Text("本年总支出：")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥33.00")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical,10)

                    HStack{
                        Text("本年结余：")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text("¥267.00")
                            .font(.headline)
                            .foregroundColor(.black)
                    }.padding(.vertical,10)
                }
            }
            .padding(.horizontal,10)


            // Basic overview
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("账本概览")
                            .foregroundColor(.blue)
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
                
                ForEach(transactions, id: \.id) { transaction in
                    VStack(alignment: .leading) {
                        Text(transaction.date)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        HStack{
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
                        
                        Text(transaction.method)
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Divider()
                            .background(Color.gray.opacity(0.5)) // 设置分割线颜色
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                   
                }
            }
            .padding()
            
            Spacer()
        }
    }
}


// TODO 数据，实体类，提取到外面
struct Transaction {
    let id = UUID()
    let date: String
    let category: String
    let amount: String
    let type: String
    let method: String
}

let transactions = [
    Transaction(date: "2024-08-25", category: "生活/吃饭", amount: "-¥33.00", type: "支出", method: "微信"),
    Transaction(date: "2024-08-25", category: "工资/绩效", amount: "+¥3003.00", type: "收入", method: "支付宝")
]


#Preview {
    FlowView()
}
