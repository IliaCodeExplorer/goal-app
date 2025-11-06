import SwiftUI

struct CharacterView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingCustomization = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Character Display
                    CharacterAvatarView()
                        .padding(.top)
                    
                    // Stats Overview
                    VStack(spacing: 12) {
                        Text("Общий рейтинг")
                            .font(.headline)
                        
                        Text("\(goalManager.userProfile.characterStats.overall)")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.purple)
                        
                        Text(goalManager.userProfile.characterStats.bodyType.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Balance Wheel (Radar Chart)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Колесо баланса")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        BalanceWheelView(stats: goalManager.userProfile.characterStats)
                            .frame(height: 300)
                            .padding()
                    }
                    
                    // Detailed Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Детальная статистика")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(StatCategory.allCases, id: \.self) { category in
                            StatBarView(
                                category: category,
                                value: goalManager.userProfile.characterStats.statValue(for: category)
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Customization Button
                    Button {
                        showingCustomization = true
                    } label: {
                        Label("Кастомизация персонажа", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Мой Персонаж")
            .sheet(isPresented: $showingCustomization) {
                CharacterCustomizationView()
            }
        }
    }
}

// MARK: - Character Avatar
struct CharacterAvatarView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var isAnimating = false
    
    var bodyType: BodyType {
        goalManager.userProfile.characterStats.bodyType
    }
    
    var body: some View {
        ZStack {
            // Background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
            
            // Character body (simplified representation)
            VStack(spacing: 0) {
                // Head
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                        }
                    )
                
                // Body
                RoundedRectangle(cornerRadius: bodyType == .athletic ? 15 : 25)
                    .fill(
                        LinearGradient(
                            colors: [bodyColor, bodyColor.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(
                        width: bodyWidth,
                        height: 80
                    )
                    .overlay(
                        // Abs (only for fit/athletic)
                        Group {
                            if bodyType == .fit || bodyType == .athletic {
                                VStack(spacing: 4) {
                                    HStack(spacing: 4) {
                                        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 15, height: 15)
                                        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 15, height: 15)
                                    }
                                    HStack(spacing: 4) {
                                        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 15, height: 15)
                                        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 15, height: 15)
                                    }
                                }
                            }
                        }
                    )
                
                // Arms
                HStack(spacing: bodyWidth - 20) {
                    Capsule()
                        .fill(bodyColor)
                        .frame(width: 15, height: 60)
                    
                    Capsule()
                        .fill(bodyColor)
                        .frame(width: 15, height: 60)
                }
                .offset(y: -40)
                
                // Legs
                HStack(spacing: 10) {
                    Capsule()
                        .fill(bodyColor)
                        .frame(width: 20, height: 70)
                    
                    Capsule()
                        .fill(bodyColor)
                        .frame(width: 20, height: 70)
                }
                .offset(y: -40)
            }
            
            // Status indicator
            VStack {
                Text(bodyType.emoji)
                    .font(.system(size: 40))
                    .offset(y: -120)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
    
    private var bodyColor: Color {
        switch bodyType {
        case .overweight: return .gray
        case .average: return .blue
        case .fit: return .green
        case .athletic: return .purple
        }
    }
    
    private var bodyWidth: CGFloat {
        switch bodyType {
        case .overweight: return 70
        case .average: return 60
        case .fit: return 55
        case .athletic: return 50
        }
    }
}

// MARK: - Balance Wheel (Radar Chart)
struct BalanceWheelView: View {
    let stats: CharacterStats
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)
            let radius = size / 2 - 40
            
            ZStack {
                // Background circles
                ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { scale in
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius * CGFloat(scale),
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: false
                        )
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }
                
                // Grid lines
                ForEach(0..<6) { index in
                    Path { path in
                        let angle = Double(index) * 60.0 - 90
                        let radians = angle * .pi / 180
                        let x = center.x + radius * CGFloat(cos(radians))
                        let y = center.y + radius * CGFloat(sin(radians))
                        
                        path.move(to: center)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }
                
                // Stats polygon
                Path { path in
                    let categories = StatCategory.allCases
                    
                    for (index, category) in categories.enumerated() {
                        let value = stats.statValue(for: category)
                        let percentage = CGFloat(value) / 100.0
                        let angle = Double(index) * 60.0 - 90
                        let radians = angle * .pi / 180
                        let x = center.x + radius * percentage * CGFloat(cos(radians))
                        let y = center.y + radius * percentage * CGFloat(sin(radians))
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .fill(Color.purple.opacity(0.3))
                .overlay(
                    Path { path in
                        let categories = StatCategory.allCases
                        
                        for (index, category) in categories.enumerated() {
                            let value = stats.statValue(for: category)
                            let percentage = CGFloat(value) / 100.0
                            let angle = Double(index) * 60.0 - 90
                            let radians = angle * .pi / 180
                            let x = center.x + radius * percentage * CGFloat(cos(radians))
                            let y = center.y + radius * percentage * CGFloat(sin(radians))
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        path.closeSubpath()
                    }
                    .stroke(Color.purple, lineWidth: 2)
                )
                
                // Labels
                ForEach(Array(StatCategory.allCases.enumerated()), id: \.offset) { index, category in
                    let angle = Double(index) * 60.0 - 90
                    let radians = angle * .pi / 180
                    let labelRadius = radius + 30
                    let x = center.x + labelRadius * CGFloat(cos(radians))
                    let y = center.y + labelRadius * CGFloat(sin(radians))
                    
                    VStack(spacing: 4) {
                        Image(systemName: category.icon)
                            .font(.caption)
                            .foregroundColor(category.color)
                        
                        Text("\(stats.statValue(for: category))")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .position(x: x, y: y)
                }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

// MARK: - Stat Bar
struct StatBarView: View {
    let category: StatCategory
    let value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(value)/100")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(category.color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [category.color, category.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(value) / 100,
                            height: 12
                        )
                        .animation(.spring(), value: value)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    CharacterView()
        .environmentObject(GoalManager())
}
