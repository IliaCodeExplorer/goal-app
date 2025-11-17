//
//  SettingsView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/6/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingBackup = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)
                            
                            Text("🎯")
                                .font(.system(size: 40))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Уровень \(goalManager.userProfile.level)")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(goalManager.userProfile.coins) монет")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Серия: \(goalManager.userProfile.streak) дней")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Data Management
                Section("Управление данными") {
                    Button {
                        showingBackup = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text("Резервное копирование")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Statistics
                Section("Статистика") {
                    HStack {
                        Text("Всего целей")
                        Spacer()
                        Text("\(goalManager.totalGoals)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Завершено")
                        Spacer()
                        Text("\(goalManager.completedGoals)")
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Достижений")
                        Spacer()
                        Text("\(goalManager.achievements.count)")
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("Всего завершений")
                        Spacer()
                        Text("\(goalManager.totalCompletions)")
                            .foregroundColor(.blue)
                    }
                }
                
                // App Info
                Section("О приложении") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Bundle ID")
                        Spacer()
                        Text("com.ilyas.GoalTracker")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Сбросить все данные")
                            Spacer()
                        }
                    }
                } footer: {
                    Text("⚠️ Это действие удалит все цели, достижения и прогресс. Убедитесь что сделали резервную копию!")
                        .font(.caption)
                }
            }
            .navigationTitle("Настройки")
            .sheet(isPresented: $showingBackup) {
                BackupView()
            }
            .alert("Сбросить все данные?", isPresented: $showingResetAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить все", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("Это действие необратимо! Все ваши цели, достижения и прогресс будут удалены.")
            }
        }
    }
    
    private func resetAllData() {
        goalManager.goals = []
        goalManager.achievements = []
        goalManager.rewards = RewardsManager.shared.defaultRewards
        goalManager.userProfile = UserProfile()
    }
}

#Preview {
    SettingsView()
        .environmentObject(GoalManager())
}
