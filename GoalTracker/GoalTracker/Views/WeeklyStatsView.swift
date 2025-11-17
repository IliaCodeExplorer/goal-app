//
//  WeeklyStatsView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import SwiftUI

// MARK: - Weekly Stats View
struct WeeklyStatsView: View {
    let stats: WeeklyStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Average line
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("За неделю:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if stats.trackingType == .numeric {
                    Text("\(String(format: "%.1f", stats.averageValue)) / \(String(format: "%.0f", stats.totalTarget / 7))")
                        .font(.caption)
                        .fontWeight(.semibold)
                } else {
                    Text("\(Int(stats.successRate))% дней")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Text("(\(Int(stats.averagePercentage))%)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(performanceColor)
                
                Image(systemName: stats.trend.icon)
                    .font(.caption)
                    .foregroundColor(stats.trend.color)
                
                Spacer()
            }
            
            // Mini chart
            HStack(spacing: 4) {
                ForEach(stats.dailyValues) { day in
                    VStack(spacing: 4) {
                        if stats.trackingType == .numeric {
                            // Для numeric - bar chart с фиксированной высотой
                                    ZStack(alignment: .bottom) {
                                               RoundedRectangle(cornerRadius: 2)
                                                   .fill(Color.gray.opacity(0.2))
                                                   .frame(height: 30)
                                               
                                               RoundedRectangle(cornerRadius: 2)
                                                   .fill(barColor(for: day))
                                                   .frame(height: max(2, 30 * CGFloat(day.percentage / 100)))
                                           }
                                           .frame(height: 30)
                        } else {
                            // Для binary/habit - checkmarks
                            ZStack {
                                Circle()
                                    .fill(dayBackgroundColor(for: day))
                                    .frame(width: 28, height: 28)
                                
                                dayIcon(for: day)
                            }
                        }
                        
                        // Day label
                        Text(day.dayName)
                            .font(.system(size: 9, weight: .medium))         .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: stats.trackingType == .numeric ? 50 : 55)
        }
        .padding(8)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var performanceColor: Color {
        if stats.averagePercentage >= 80 {
            return .green
        } else if stats.averagePercentage >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func barColor(for day: WeeklyStats.DayValue) -> Color {
        if day.isFailed {
            return .red
        } else if day.percentage >= 100 {
            return .green
        } else if day.percentage >= 80 {
            return .blue
        } else if day.percentage >= 50 {
            return .orange
        } else if day.percentage > 0 {
            return .orange
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func dayBackgroundColor(for day: WeeklyStats.DayValue) -> Color {
        if day.isFailed {
            return Color.red.opacity(0.2)
        } else if day.percentage >= 100 {
            return Color.green.opacity(0.2)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private func dayIcon(for day: WeeklyStats.DayValue) -> some View {
        Group {
            if day.isFailed {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            } else if day.percentage >= 100 {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
            } else if !day.wasTracked {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            } else {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    WeeklyStatsView(stats: WeeklyStats(
        dailyValues: [],
        averageValue: 5.0,
        averagePercentage: 62.5,
        totalValue: 35,
        totalTarget: 56,
        successRate: 71.4,
        trend: .improving,
        trackingType: .numeric
    ))
    .padding()
}
