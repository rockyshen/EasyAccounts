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
    
    @State private var selectedDate = Date(){
        didSet { detailStore.updateYearAndMonth(selectDate: selectedDate) }
    }
    @State private var monthOffset = 0
    
    
    var body: some View {
        VStack(alignment: .leading) {
            // 顶部
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
            
            // 总览 - 按时间排序
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
            
            // 月度收支情况
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
//                        .padding(.vertical, 10) // 设置上下边距
            }
            .padding(.horizontal, 10)
            HStack{
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("当月总收入：")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text("¥ " + detailStore.flowListDto.totalIn)
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Spacer()
                        }
                            
                        HStack{
                            Text("本年总支出：")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text("¥ " + detailStore.flowListDto.totalOut)
                                .font(.headline)
                                .foregroundColor(.red)
                        }

                        HStack{
                            Text("本年结余：")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Text("¥ " + (detailStore.flowListDto.totalEarn ?? "0"))
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                    
                    }
                    .padding(.horizontal,10)
                }
                
                // 月份选择器
                HStack() {
                    Button(action: {
                        monthOffset -= 1
                        self.updateDate()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                    
                    DatePicker(
                        selection: $selectedDate,
                        displayedComponents: .date,
                        label: {Text("选择月份")}
                    )
                    .labelsHidden()
                    
                    Button(action: {
                        monthOffset += 1
                        self.updateDate()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding(.horizontal,8)
                
            }
            
            // 账本概览
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
            .padding()
            VStack(alignment: .leading) {
                FlowList(flows: detailStore.flowListDto.flows)
            }
        }
    }
    
    // 月份选择器，计算月份偏移的方法
    private func updateDate() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: monthOffset, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

#Preview {
    DetailView()
}
