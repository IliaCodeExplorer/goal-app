//
//  DailyBriefingView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import SwiftUI

// MARK: - Daily Briefing View
struct DailyBriefingView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    let summary: DailySummary
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text(greeting)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Yesterday Summary
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Вчера (\(yesterdayDate))")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            // Completed Goals
                            if summary.completedGoals > 0 {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(summary.completedGoals) целей завершено")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                        
                                        Text("+\(summary.coinsEarned) монет")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            // Failed Goals
                            if summary.failedGoals > 0 {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(summary.failedGoals) целей пропущено")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                        
                                        Text("-\(summary.coinsLost) монет")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Penalties Detail
                        if !summary.penalties.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Детали штрафов")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(summary.penalties) { penalty in
                                    HStack(spacing: 12) {
                                        Image(systemName: penalty.reason.icon)
                                            .foregroundColor(.red)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(penalty.goalTitle)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            
                                            Text(penalty.reason.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("-\(penalty.coinsPenalty)")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                            
                                            Text("-\(penalty.statsPenalty) 💪")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Net Result
                        VStack(spacing: 12) {
                            Divider()
                            
                            HStack {
                                Text("Итого за вчера:")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(summary.netCoins > 0 ? "+" : "")\(summary.netCoins) монет")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(summary.netCoins >= 0 ? .green : .red)
                            }
                            .padding()
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(12)
                            
                            if summary.streakBroken {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.red)
                                    
                                    Text("Streak сброшен")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action Button
                        Button {
                            goalManager.userProfile.showDailyBriefing = false
                            goalManager.userProfile.todayPenalties.removeAll()
                            goalManager.saveProfile()
                            dismiss()
                        } label: {
                            Text("Понял, начинаем день")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .padding(.top)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.vertical, 60)
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "🌅 Доброе утро!"
        } else if hour < 18 {
            return "☀️ Добрый день!"
        } else {
            return "🌙 Добрый вечер!"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date()).capitalized
    }
    
    private var yesterdayDate: String {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: yesterday)
    }
}

#Preview {
    DailyBriefingView(summary: DailySummary(
        date: Date(),
        completedGoals: 3,
        failedGoals: 2,
        coinsEarned: 75,
        coinsLost: 20,
        streakBroken: true,
        penalties: [
            PenaltyRecord(goalId: UUID(), goalTitle: "Вода", coinsPenalty: 10, statsPenalty: 2, reason: .notTouched),
            PenaltyRecord(goalId: UUID(), goalTitle: "Бег", coinsPenalty: 10, statsPenalty: 2, reason: .notTouched)
        ]
    ))
    .environmentObject(GoalManager())
}
