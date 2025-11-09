import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        NavigationView {
            ZStack {
                if goalManager.achievements.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Пока нет достижений")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Завершайте цели, чтобы открывать достижения!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Achievement Stats
                            AchievementStatsView()
                                .padding(.horizontal)
                            
                            // Achievements by Rarity
                            ForEach(AchievementRarity.allCases.reversed(), id: \.self) { rarity in
                                let achievements = goalManager.achievements.filter { $0.rarity == rarity }
                                if !achievements.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text(rarity.rawValue)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(rarityColor(rarity))
                                            
                                            Spacer()
                                            
                                            Text("\(achievements.count)")
                                                .font(.headline)
                                                .foregroundColor(rarityColor(rarity))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(rarityColor(rarity).opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                        .padding(.horizontal)
                                        
                                        LazyVGrid(columns: [
                                            GridItem(.flexible()),
                                            GridItem(.flexible())
                                        ], spacing: 16) {
                                            ForEach(achievements) { achievement in
                                                AchievementCardView(achievement: achievement)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Достижения")
        }
    }
    
    private func rarityColor(_ rarity: AchievementRarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

struct AchievementStatsView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Коллекция достижений")
                        .font(.headline)
                    
                    Text("\(goalManager.achievements.count) открыто")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
            }
            
            // Rarity breakdown
            HStack(spacing: 12) {
                ForEach(AchievementRarity.allCases, id: \.self) { rarity in
                    let count = goalManager.achievements.filter { $0.rarity == rarity }.count
                    if count > 0 {
                        VStack(spacing: 4) {
                            Text("\(count)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(rarityColor(rarity))
                            
                            Text(rarity.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(rarityColor(rarity).opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func rarityColor(_ rarity: AchievementRarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

struct AchievementCardView: View {
    let achievement: Achievement
    @State private var isAnimating = false
    @State private var showDetails = false
    
    var body: some View {
        Button {
            showDetails = true
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: rarityGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: rarityColor.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 45))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }
                
                VStack(spacing: 4) {
                    Text(achievement.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(achievement.rarity.rawValue)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(rarityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(rarityColor.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text(achievement.dateEarned, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: rarityColor.opacity(0.2), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: rarityGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
        .sheet(isPresented: $showDetails) {
            AchievementDetailView(achievement: achievement)
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

struct AchievementDetailView: View {
    @Environment(\.dismiss) var dismiss
    let achievement: Achievement
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: rarityGradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .opacity(0.3)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: rarityGradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 150, height: 150)
                            .shadow(color: rarityColor.opacity(0.5), radius: 20, x: 0, y: 10)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    }
                    
                    // Details
                    VStack(spacing: 12) {
                        Text(achievement.rarity.rawValue.uppercased())
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(rarityColor)
                            .tracking(2)
                        
                        Text(achievement.title)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text(achievement.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Reward
                        VStack(spacing: 8) {
                            Text("Награда")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(achievement.reward)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding()
                                .background(rarityColor.opacity(0.2))
                                .cornerRadius(12)
                        }
                        .padding(.top)
                        
                        // Date earned
                        Text("Получено: \(achievement.dateEarned.formatted(date: .long, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Достижение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
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
    AchievementsView()
        .environmentObject(GoalManager())
}
