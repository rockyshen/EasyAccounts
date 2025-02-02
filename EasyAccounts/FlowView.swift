//
//  Flow.swift
//  EasyAccounts
//  流水页
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct FlowView: View {
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("流水")
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
            
            // Date picker and buttons
            HStack {
                DatePicker(
                    selection: .constant(Date()), // Placeholder date
                    in: ...Date(),
                    displayedComponents: [.date]
                ) {
                    Text("2024-08-25")
                }
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                
                Spacer()
                
                Button(action: {
                    // Add functionality for generate report button
                }) {
                    Text("生成报表")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Income and expenditure
            VStack(alignment: .leading) {
                Text("本年总收入")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text("¥300.00")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("本年总支出")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Text("¥33.00")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
                
                Text("本年结余：¥267.00")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Basic overview
            VStack(alignment: .leading) {
                Text("基本概览")
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


// TODO 数据，实体类，提取到外面
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


#Preview {
    FlowView()
}
