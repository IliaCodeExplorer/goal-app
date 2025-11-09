//
//  ProfileView.swift
//  GoalTracker
//
//  Created by Ilyas on 11/7/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingBackup = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    ProfileHeaderView()
                    
                    // Character Stats
                    CharacterStatsSection()
                    
                    // Achievements Summary
                    AchievementsSummarySection()
                    
                    // Quick Actions
                    QuickActionsSection(
                        showingBackup: $showingBackup,
                        showingSettings: $showingSettings
                    )
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .sheet(isPresented: $showingBackup) {
                BackupView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // Level Badge
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Уровень \(goalManager.userProfile.level)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            // XP Progress
            VStack(spacing: 8) {
                HStack {
                    Text("XP: \(goalManager.userProfile.xp) / \(goalManager.userProfile.xpToNextLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(goalManager.userProfile.levelProgress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: goalManager.userProfile.levelProgress)
                    .tint(.blue)
                    .scaleEffect(y: 1.5)
            }
            .padding(.horizontal, 40)
            
            // Coins
            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                    Text("\(goalManager.userProfile.coins)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Монеты")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 50)
                
                VStack {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("\(goalManager.userProfile.streak)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Дней подряд")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 50)
                
                VStack {
                    Image(systemName: "trophy.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text("\(goalManager.achievements.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Достижений")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Character Stats Section
struct CharacterStatsSection: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Характеристики персонажа")
                .font(.headline)
            
            ForEach(StatCategory.allCases, id: \.self) { category in
                CharacterStatRow(
                    category: category,
                    value: goalManager.userProfile.characterStats.statValue(for: category)
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct CharacterStatRow: View {
    let category: StatCategory
    let value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                
                Text(category.rawValue)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(value)/100")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(category.color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(category.color)
                        .frame(width: geometry.size.width * CGFloat(value) / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Achievements Summary
struct AchievementsSummarySection: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingAllAchievements = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Достижения")
                    .font(.headline)
                
                Spacer()
                
                if !goalManager.achievements.isEmpty {
                    Button("Все") {
                        showingAllAchievements = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if goalManager.achievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Пока нет достижений")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(goalManager.achievements.prefix(6)) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .sheet(isPresented: $showingAllAchievements) {
            AchievementsView()
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(rarityColor)
            }
            
            Text(achievement.title)
                .font(.caption2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
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
}

// MARK: - Quick Actions
struct QuickActionsSection: View {
    @Binding var showingBackup: Bool
    @Binding var showingSettings: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: { showingBackup = true }) {
                HStack {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Резервное копирование")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: { showingSettings = true }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text("Настройки")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(GoalManager())
}
