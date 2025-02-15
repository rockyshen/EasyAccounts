//
//  Flow.swift
//  EasyAccounts
//  第2个Tab页：流水页，我取名为：DetailView，区别于FlowView
//  FlowView是单条Flow展示的页面！
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI
import ImagePickerView

struct DetailView: View {
    @StateObject var detailStore = DetailStore()
    
    @State private var date = Date() // 默认日期为当前日期
    @State private var showingDatePicker = false
    @State private var isShowingAddFlowView: Bool = false
    
    @State private var selectedDate = Date()
    {
        didSet { detailStore.updateYearAndMonth(selectDate: selectedDate) }
    }
    
    @State private var year: Int
    @State private var month: Int
    
    @State var image: UIImage?
    @State var showImagePicker: Bool = false
    
    // AI识别，等待框
    @State var isLoading: Bool = false
    @State var responseMessage: String?
    
    // 初始化为系统当前年月
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        self._year = State(initialValue: calendar.component(.year, from: currentDate))
        self._month = State(initialValue: calendar.component(.month, from: currentDate))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // 顶部
            HStack {
                Text("流水")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
                
                VStack {
                    Button(action: {
                        isShowingAddFlowView.toggle()
                    }, label : {
                        Text("记一笔")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    })
                    .padding()
                    .sheet(isPresented: $isShowingAddFlowView, content: {
                        AddFlowView(completion: {newFlowAddRequestDto in detailStore.addFlow(flowAddRequestDto: newFlowAddRequestDto)})
                    })
                    
                    Button(action: {
                        // 弹出图片选择器
                        showImagePicker.toggle()
                    }, label : {
                        Text("AI识别")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    })
                    .sheet(isPresented: $showImagePicker){
                        ImagePickerView(sourceType: .photoLibrary){
                            image in self.image = image
                            self.isLoading = true
                            detailStore.analyzeFlowByAi(flowImg: image) {
                                responseMsg in self.isLoading = false
                                self.responseMessage = responseMsg
                            }
                        }
                    }
                    
                    if isLoading {
                        ProgressView("AI正在识别。。。")
                    }
                    
                    if let message = responseMessage {
                        Text(message)
                            .padding()
                            .foregroundColor(message == "添加成功" ? .green : .red)
                    }
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
                
                VStack(spacing: 10) {
                    // 月份选择器
                    HStack {
                        Button(action: decrementMonth) {
                            Text("-")
                                .font(.largeTitle)
//                                .padding()
                        }
                        
                        Text("\(year) - \(String(format: "%02d", month))")
                            .font(.headline)
                            .frame(maxWidth: 90, maxHeight: 5)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        Button(action: incrementMonth) {
                            Text("+")
                                .font(.largeTitle)
//                                .padding()
                        }
                    }
                    
                    Button(action: {
                        // 在这里添加生成报表的逻辑
                        print("报表已生成")
                        detailStore.makeExcel()
                    }) {
                        Text("生成报表")
                            .frame(maxWidth: 90, maxHeight: 5) // 使文本自适应按钮大小
                            .padding() // 添加内边距
                            .background(Color.blue.opacity(0.8)) // 设置背景颜色和透明度
                            .cornerRadius(8) // 设置圆角半径
                            .foregroundColor(.white) // 设置文本颜色
                    }
//                    .padding(.vertical,8)
                }
                .padding(.trailing,10)
            }
            
            // 账本概览
            HStack {
                Text("账本概览")
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            //.padding(.horizontal, 10) // 设置左右边距
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
    
    // 月份选择器，计算月份加减的方法
    private func updateSelectedDate() {
            if let newDate = Calendar.current.date(from: DateComponents(year: year, month: month)) {
                selectedDate = newDate
            }
        }
    
    private func incrementMonth() {
        month += 1
        if month > 12 {
            month = 1
            year += 1
        }
        updateSelectedDate()
    }
    
    private func decrementMonth() {
        month -= 1
        if month < 1 {
            month = 12
            year -= 1
        }
        updateSelectedDate()
    }
}

#Preview {
    DetailView()
}
