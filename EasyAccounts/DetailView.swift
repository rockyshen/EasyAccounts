//
//  Flow.swift
//  EasyAccounts
//  第2个Tab页：流水页，我取名为：DetailView，区别于FlowView
//  FlowView是单条Flow展示的页面！
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct DetailView: View {
    @StateObject var detailStore = DetailStore()
    
    @State private var date = Date() // 默认日期为当前日期
    @State private var showingDatePicker = false
    @State private var isShowingAddFlowView: Bool = false
    
    
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
                        isShowingAddFlowView.toggle()
                    }, label : {
                        Text("记一笔")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    })
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .sheet(isPresented: $isShowingAddFlowView, content: {
                        AddFlowView(completion: {newFlowAddRequestDto in detailStore.addFlow(flowAddRequestDto: newFlowAddRequestDto)})
                    })
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
                    
                FlowList(flows: detailStore.flowListDto.flows)
            }
        }
    }
}


//#Preview {
//    DetailView()
//}
