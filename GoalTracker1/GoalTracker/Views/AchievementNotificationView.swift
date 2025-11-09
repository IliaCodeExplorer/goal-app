//
//  AchievementNotificationView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/5/25.
//

import SwiftUI

struct AchievementNotificationView: View {
    let achievement: Achievement
    @State private var isAnimating = false
    @State private var sparkleOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Background with rarity color
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: rarityGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: rarityColor.opacity(0.5), radius: 20, x: 0, y: 10)
                
                // Content
                HStack(spacing: 16) {
                    // Icon with animation
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 35))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(achievement.rarity.rawValue.uppercased())
                            .font(.caption2)
                            .fontWeight(.black)
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(1.5)
                        
                        Text(achievement.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)
                        
                        Text(achievement.reward)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // Sparkle effects
                ForEach(0..<5) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .offset(
                            x: cos(Double(i) * 1.26 + Double(sparkleOffset)) * 80,
                            y: sin(Double(i) * 1.26 + Double(sparkleOffset)) * 80
                        )
                        .opacity(0.7)
                }
            }
            .frame(height: 140)
            .padding(.horizontal)
            .padding(.top, 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                sparkleOffset = 6.28
            }
        }
    }
    
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    private var rarityGradient: [Color] {
        switch achievement.rarity {
        case .common:
            return [Color.gray, Color.gray.opacity(0.7)]
        case .rare:
            return [Color.blue, Color.cyan]
        case .epic:
            return [Color.purple, Color.pink]
        case .legendary:
            return [Color.orange, Color.yellow]
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
        
        AchievementNotificationView(
            achievement: Achievement(
                title: "Неудержимый",
                description: "Завершено 10 целей!",
                icon: "crown.fill",
                reward: "👑 Корона победителя",
                rarity: .legendary
            )
        )
    }
}
