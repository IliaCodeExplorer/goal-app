//
//  PenaltyNotificationView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/17/25.
//

import SwiftUI

// MARK: - Penalty Notification View
struct PenaltyNotificationView: View {
    let penalty: PenaltyRecord
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Red background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.red.opacity(0.5), radius: 20, x: 0, y: 10)
                
                // Content
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                        
                        Image(systemName: penalty.reason.icon)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("⚠️ ШТРАФ")
                            .font(.caption2)
                            .fontWeight(.black)
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1.5)
                        
                        Text(penalty.goalTitle)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(penalty.reason.description)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("-\(penalty.coinsPenalty)")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.purple)
                                Text("-\(penalty.statsPenalty)")
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .frame(height: 140)
            .padding(.horizontal)
            .padding(.top, 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        PenaltyNotificationView(
            penalty: PenaltyRecord(
                goalId: UUID(),
                goalTitle: "Вода",
                coinsPenalty: 10,
                statsPenalty: 2,
                reason: .notTouched
            )
        )
    }
}
