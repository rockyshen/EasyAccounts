//
//  Flow.swift
//  EasyAccounts
//  流水页，我取名为：DetailView，区别于FlowView
//  FlowView是单条Flow展示的页面！
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI
import ImagePickerView

struct DetailView: View {
    @StateObject var detailStore = DetailStore()
    @StateObject var accountStore = AccountStore()
    @StateObject var actionStore = ActionStore()
    @StateObject var typeStore = TypeStore()
    
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
    @State private var responseMessage = ""
    @State var isLoading: Bool = false
//    @State private var showAlert = false
    @State private var showProcessingAlert = false
    @State private var showCompletionAlert = false
    
    // 初始化为系统当前年月
    init() {
        let currentDate = Date()
        let calendar = Calendar.current
        self._year = State(initialValue: calendar.component(.year, from: currentDate))
        self._month = State(initialValue: calendar.component(.month, from: currentDate))
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
    
    var body: some View {
        VStack(alignment: .leading) {
            // 顶部
            HStack {
                Text("流水")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
                
                Menu {
                    // 手动录入：记一笔
                    Button(action: {
                        isShowingAddFlowView.toggle()
                    }, label : {
                        Text("记一笔")
                    })
                    
                    // 上传图片：AI识别
                    Button(action: {
                        // 弹出图片选择器
                        showImagePicker.toggle()
                    }, label : {
                        Text("AI识别")
                    })
                } label: {Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.blue))
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
            }
            .padding()
            .background(Color.blue)
            // 弹出：修改Flow详情页
            .sheet(isPresented: $isShowingAddFlowView, content: {
                AddFlowView(completion: {newFlowAddRequestDto in detailStore.addFlow(flowAddRequestDto: newFlowAddRequestDto)})
            })
            // 弹出：图片选择页
            .sheet(isPresented: $showImagePicker, content: {
                ImagePickerView(sourceType: .photoLibrary){
                    image in
                    self.image = image
                    self.isLoading = true
                    self.responseMessage = "🤖️处理中..."
                    self.showProcessingAlert = true
                    detailStore.analyzeFlowByAi(flowImg: image) {
                        responseMsg in
                        self.responseMessage = responseMsg
                        self.isLoading = false
                        self.showProcessingAlert = false
                        self.showCompletionAlert = true
                    }
                }
            })
            .alert(isPresented: $showCompletionAlert) {
                Alert(title: Text("状态"), message: Text(responseMessage), dismissButton: .default(Text("好")) {
                    // Reset image and state when alert is dismissed
                    self.image = nil
                    self.responseMessage = ""
                })
            }

            // 总览 - 按时间排序
            HStack {
                Button(action: {
                    // 总览按钮的功能
                }) {
                    Text("总览")
                        .font(.title3) // 设置字体大小
                        .foregroundColor(.blackDarkMode) // 设置字体颜色
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
                        .foregroundColor(.blackDarkMode)
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
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 左侧横线
                        Spacer()
                        Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 右侧横线
                    }
                )
            }
            .padding(.horizontal, 10)
            
            HStack{
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("当月总收入：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text("¥ " + detailStore.flowListDto.totalIn)
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Spacer()
                        }
                        
                        HStack{
                            Text("本年总支出：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text("¥ " + detailStore.flowListDto.totalOut)
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        
                        HStack{
                            Text("本年结余：")
                                .font(.subheadline)
                                .foregroundColor(.blackDarkMode)
                            Text("¥ " + (detailStore.flowListDto.totalEarn ?? "0"))
                                .font(.headline)
                                .foregroundColor(.blackDarkMode)
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
                }
                .padding(.trailing,10)
            }
                
            // 账本概览
            HStack {
                Text("账本概览")
                    .foregroundColor(.accentColor)
            }
            .frame(maxWidth: .infinity)
            //.padding(.horizontal, 10) // 设置左右边距
            .overlay(
                HStack {
                    Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 左侧横线
                    Spacer()
                    Rectangle().frame(width: 100, height: 1).foregroundColor(.accentColor) // 右侧横线
                }
            )
            .padding()
            
            VStack(alignment: .leading) {
                FlowList(flows: detailStore.flowListDto.flows, detailStore: detailStore,
                         accountStore: accountStore,
                         actionStore: actionStore,
                         typeStore: typeStore
                )
            }
        }
        //AI识别过程中，顶层的Alert弹窗
        .overlay(
            Group {
                if showProcessingAlert {
                    VStack {
                        if isLoading {
                            ProgressView(responseMessage)
                                .foregroundColor(.blackDarkMode)
                        }
                    }
                    .padding()
                    .background(Color.whiteDarkMode)
                    .cornerRadius(10)
                    .transition(.opacity.animation(.easeInOut))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            if self.isLoading {
                                self.showProcessingAlert = false
                            }
                        }
                    }
                }
            }
        )
    }
}

#Preview {
    DetailView()
}
