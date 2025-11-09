//
//  LevelUpComponents.swift
//  GoalTracker
//
//  Created on 11/08/2025.
//

import SwiftUI

// MARK: - Level Up Notification
struct LevelUpNotificationView: View {
    let level: Int
    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = -180
    @State private var viewOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.yellow, .orange],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 10)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotation))
            }
            
            Text("LEVEL UP!")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
            
            Text("Уровень \(level)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("🎁 Получено \(level * 50) монет!")
                .font(.headline)
                .foregroundColor(.yellow)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .purple.opacity(0.5), radius: 30)
        )
        .scaleEffect(scale)
        .opacity(viewOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                viewOpacity = 1.0
            }
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 180
            }
        }
    }
}

// MARK: - Coin Animation View
struct CoinAnimationView: View {
    let amount: Int
    @State private var coins: [CoinParticle] = []
    
    struct CoinParticle: Identifiable {
        let id = UUID()
        var offset: CGSize
        var opacity: Double
        var scale: CGFloat
    }
    
    var body: some View {
        ZStack {
            ForEach(coins) { coin in
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(amount > 0 ? .yellow : .red)
                    .offset(coin.offset)
                    .opacity(coin.opacity)
                    .scaleEffect(coin.scale)
            }
            
            Text(amount > 0 ? "+\(amount)" : "\(amount)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(amount > 0 ? .yellow : .red)
                .shadow(color: .black.opacity(0.3), radius: 2)
        }
        .onAppear {
            createCoins()
        }
    }
    
    private func createCoins() {
        // CRITICAL FIX: Guard против 0 и безопасное деление
        guard amount != 0 else { return }
        
        let absAmount = abs(amount)
        let numberOfCoins = min(absAmount / max(10, 1), 20) // Безопасное деление
        
        guard numberOfCoins > 0 else { return } // Дополнительная проверка
        
        for i in 0..<numberOfCoins {
            let angle = Double(i) * (360.0 / Double(numberOfCoins)) * .pi / 180
            let radius: CGFloat = 100
            
            let coin = CoinParticle(
                offset: .zero,
                opacity: 1,
                scale: 1
            )
            
            coins.append(coin)
            
            withAnimation(.easeOut(duration: 1).delay(Double(i) * 0.05)) {
                if i < coins.count { // Безопасный доступ
                    coins[i].offset = CGSize(
                        width: cos(angle) * radius,
                        height: sin(angle) * radius
                    )
                    coins[i].opacity = 0
                    coins[i].scale = 0.3
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LevelUpNotificationView(level: 5)
        CoinAnimationView(amount: 100)
        CoinAnimationView(amount: -25)
    }
    .padding()
    .background(Color.black.opacity(0.3))
}
