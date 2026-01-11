//
//  SettingView.swift
//  EasyAccounts
//  设置页 - 深色科技风格
//  Created by 沈俊杰 on 2025/2/2.
//

import SwiftUI

struct SettingView: View {
    @StateObject var accountStore = AccountStore()
    @StateObject var actionStore = ActionStore()
    @StateObject var typeStore = TypeStore()
    
    // 主题管理器
    @ObservedObject private var themeManager = ThemeManager.shared
    
    // 偏好设置状态
    @AppStorage("languageCode") private var languageCode = "zh_CN"
    
    var body: some View {
        NavigationView {
            ZStack {
                // 深色背景
                Color.themeBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - 顶部标题（固定）
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("$ config --list")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.themeAccent)
                            Text("// System preferences")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.themeTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.themeBg)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // MARK: - ACCOUNT SETTINGS
                        SettingSectionHeader(title: "ACCOUNT_SETTINGS")
                        
                        VStack(spacing: 8) {
                            NavigationLink(destination: SettingActionView(actionStore: actionStore)) {
                                SettingRow(
                                    icon: "arrow.left.arrow.right",
                                    label: "action_types",
                                    showArrow: true
                                )
                            }
                            
                            NavigationLink(destination: SettingAccountView(accountStore: accountStore)) {
                                SettingRow(
                                    icon: "creditcard",
                                    label: "bank_accounts",
                                    showArrow: true
                                )
                            }
                            
                            NavigationLink(destination: SettingTypeView(typeStore: typeStore)) {
                                SettingRow(
                                    icon: "folder",
                                    label: "categories",
                                    showArrow: true
                                )
                            }
                            
                            SettingRow(
                                icon: "doc.text",
                                label: "quick_templates",
                                showArrow: true
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - PREFERENCES
                        SettingSectionHeader(title: "PREFERENCES")
                        
                        VStack(spacing: 8) {
                            SettingToggleRow(
                                icon: "moon.fill",
                                label: "dark_mode_enabled",
                                isOn: $themeManager.isDarkMode
                            )
                            
                            SettingRow(
                                icon: "globe",
                                label: languageCode,
                                showArrow: true
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - DATA
                        SettingSectionHeader(title: "DATA")
                        
                        VStack(spacing: 8) {
                            SettingRow(
                                icon: "arrow.down.circle",
                                label: "export_data",
                                showArrow: true
                            )
                            
                            SettingRow(
                                icon: "arrow.up.circle",
                                label: "import_data",
                                showArrow: true
                            )
                            
                            SettingRow(
                                icon: "icloud",
                                label: "cloud_sync",
                                showArrow: true
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // MARK: - ABOUT
                        SettingSectionHeader(title: "ABOUT")
                        
                        VStack(spacing: 8) {
                            SettingRow(
                                icon: "info.circle",
                                label: "version_info",
                                value: "v1.0.0",
                                showArrow: false
                            )
                            
                            SettingRow(
                                icon: "envelope",
                                label: "contact_us",
                                showArrow: true
                            )
                            
                            SettingRow(
                                icon: "star",
                                label: "rate_app",
                                showArrow: true
                            )
                        }
                        .padding(.horizontal, 16)
                        
                            Spacer(minLength: 100)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - 分组标题组件
struct SettingSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text("# \(title)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.themeTextSecondary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }
}

// MARK: - 设置项行组件
struct SettingRow: View {
    let icon: String
    let label: String
    var value: String? = nil
    var showArrow: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.themeTextSecondary)
                .frame(width: 24)
            
            // 标签
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.themeTextPrimary)
            
            Spacer()
            
            // 值（如果有）
            if let value = value {
                Text(value)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.themeTextSecondary)
            }
            
            // 箭头
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.themeTextSecondary)
            }
        }
        .padding(16)
        .background(Color.themeCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeBorderLight, lineWidth: 1)
        )
    }
}

// MARK: - 带开关的设置项行组件
struct SettingToggleRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.themeTextSecondary)
                .frame(width: 24)
            
            // 标签
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.themeTextPrimary)
            
            Spacer()
            
            // 开关
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.themeAccent)
        }
        .padding(16)
        .background(Color.themeCardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeBorderLight, lineWidth: 1)
        )
    }
}

#Preview {
    SettingView()
}
