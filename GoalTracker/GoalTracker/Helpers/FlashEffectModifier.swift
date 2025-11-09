//
//  FlashEffectModifier.swift
//  GoalTracker
//
//  Created by Ilyas on 11/6/25.
//

import SwiftUI

// MARK: - Flash Effect Types
enum FlashType {
    case success // Зеленая вспышка (успех)
    case damage  // Красная вспышка (урон)
    case neutral // Синяя вспышка (нейтральное)
    
    var color: Color {
        switch self {
        case .success: return .green
        case .damage: return .red
        case .neutral: return .blue
        }
    }
}

// MARK: - Flash Effect Modifier
struct FlashEffectModifier: ViewModifier {
    let isActive: Bool
    let type: FlashType
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(type.color.opacity(isActive ? 0.3 : 0))
                    .allowsHitTesting(false)
                    .animation(.easeOut(duration: 0.3), value: isActive)
            )
    }
}

extension View {
    func flashEffect(_ isActive: Bool, type: FlashType) -> some View {
        self.modifier(FlashEffectModifier(isActive: isActive, type: type))
    }
}

// MARK: - Floating Damage/Heal Numbers
struct FloatingNumberView: View {
    let value: Int
    let isPositive: Bool
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text("\(isPositive ? "+" : "")\(value)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(isPositive ? .green : .red)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    offset = -50
                    opacity = 0
                }
            }
    }
}

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

extension View {
    func shake(with attempts: Int) -> some View {
        self.modifier(ShakeEffect(animatableData: CGFloat(attempts)))
    }
}

// MARK: - Screen Flash Overlay
struct ScreenFlashView: View {
    @Binding var isActive: Bool
    let type: FlashType
    
    var body: some View {
        if isActive {
            Rectangle()
                .fill(type.color.opacity(0.4))
                .ignoresSafeArea()
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isActive = false
                    }
                }
        }
    }
}
