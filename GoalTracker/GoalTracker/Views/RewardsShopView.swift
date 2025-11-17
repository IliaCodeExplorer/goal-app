import SwiftUI

// v2.5 - RewardsShopView (упрощенная версия без isReusable)
// ИЗМЕНЕНИЯ:
// - Удалена поддержка многоразовых наград (isReusable)
// - Удалена история покупок (purchaseHistory)
// - Награда покупается 1 раз (isPurchased)

struct RewardsShopView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var selectedCategory: RewardCategory?
    @State private var showingAddReward = false
    @State private var showingPurchasedOnly = false
    
    var filteredRewards: [Reward] {
        var rewards = goalManager.rewards
        
        if let category = selectedCategory {
            rewards = rewards.filter { $0.category == category }
        }
        
        if showingPurchasedOnly {
            rewards = rewards.filter { $0.isPurchased }
        }
        
        return rewards.sorted { !$0.isPurchased && $1.isPurchased }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Wallet Header
                    WalletHeaderView()
                        .padding(.horizontal)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterPill(
                                title: "Все",
                                icon: "square.grid.2x2",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                            }
                            
                            ForEach(RewardCategory.allCases, id: \.self) { category in
                                FilterPill(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Toggle for purchased
                    Toggle("Показать купленные", isOn: $showingPurchasedOnly)
                        .padding(.horizontal)
                        .tint(.purple)
                    
                    // Rewards Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredRewards) { reward in
                            RewardCardView(reward: reward)
                        }
                    }
                    .padding(.horizontal)
                    .id(showingPurchasedOnly)
                }
                .padding(.vertical)
            }
            .navigationTitle("Магазин Наград")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReward = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddReward) {
                AddRewardView()
            }
        }
    }
}

struct WalletHeaderView: View {
    @EnvironmentObject var goalManager: GoalManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Coins Display
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Баланс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(goalManager.userProfile.coins)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Уровень \(goalManager.userProfile.level)")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    Text("\(goalManager.userProfile.xp)/\(goalManager.userProfile.xpToNextLevel) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.yellow.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Level Progress
            VStack(spacing: 8) {
                HStack {
                    Text("Прогресс уровня")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Int(goalManager.userProfile.levelProgress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(goalManager.userProfile.levelProgress),
                                height: 12
                            )
                            .animation(.spring(), value: goalManager.userProfile.levelProgress)
                    }
                }
                .frame(height: 12)
            }
        }
    }
}

struct FilterPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.purple : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct RewardCardView: View {
    @EnvironmentObject var goalManager: GoalManager
    @State private var showingDetail = false
    let reward: Reward
    
    var canAfford: Bool {
        goalManager.userProfile.coins >= reward.cost
    }
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            reward.isPurchased ?
                            LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: reward.icon)
                        .font(.system(size: 30))
                        .foregroundColor(reward.isPurchased ? .green : categoryColor)
                    
                    if reward.isPurchased {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                            .offset(x: 28, y: -28)
                    }
                }
                
                // Title
                Text(reward.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .frame(height: 36)
                
                // Cost
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("\(reward.cost)")
                        .font(.headline)
                        .foregroundColor(canAfford ? .primary : .red)
                }
                
                // Status badge
                if reward.isPurchased {
                    Text("✓ Куплено")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(6)
                } else {
                    Text(" ")
                        .font(.caption2)
                        .frame(height: 18)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: reward.isPurchased ? Color.green.opacity(0.2) : Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(reward.isPurchased ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            RewardDetailView(reward: reward)
        }
    }
    
    private var categoryColor: Color {
        switch reward.category {
        case .instant: return .orange
        case .experience: return .blue
        case .purchase: return .pink
        case .bigGoal: return .purple
        }
    }
}

struct RewardDetailView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    @State private var showingConfirmation = false
    let reward: Reward
    
    var canAfford: Bool {
        goalManager.userProfile.coins >= reward.cost
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: reward.icon)
                            .font(.system(size: 50))
                            .foregroundColor(categoryColor)
                    }
                    .padding(.top)
                    
                    // Title & Description
                    VStack(spacing: 8) {
                        Text(reward.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(reward.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 16) {
                        StatBlock(title: "Цена", value: "\(reward.cost)", icon: "dollarsign.circle.fill", color: .yellow)
                        StatBlock(title: "Куплено", value: "\(reward.totalPurchases)", icon: "bag.fill", color: .green)
                        StatBlock(title: "Ждет", value: "\(reward.pendingRedemptions)", icon: "clock.fill", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Purchase History Stats
                    if reward.totalPurchases > 0 {
                        VStack(spacing: 12) {
                            Text("📊 Статистика")
                                .font(.headline)
                            
                            HStack {
                                Text("Сегодня:")
                                Spacer()
                                Text("\(reward.todayPurchases) раз")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("За неделю:")
                                Spacer()
                                Text("\(reward.weekPurchases) раз")
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Всего потрачено:")
                                Spacer()
                                Text("\(reward.totalSpent) монет")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.yellow)
                            }
                            
                            if let lastDate = reward.lastPurchaseDate {
                                HStack {
                                    Text("Последняя покупка:")
                                    Spacer()
                                    Text(formatDate(lastDate))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Кнопка "Использовал"
                        if reward.hasUnredeemedPurchases {
                            Button {
                                goalManager.redeemOldestPurchase(rewardId: reward.id)
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("🎉 Использовал в реале!")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            
                            Text("Осталось использовать: \(reward.pendingRedemptions)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        // Кнопка "Купить"
                        if canAfford {
                            Button {
                                showingConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "cart.fill")
                                    Text("Купить ещё")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                            }
                        } else {
                            VStack(spacing: 8) {
                                Text("Недостаточно монет")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                let needed = reward.cost - goalManager.userProfile.coins
                                Text("Нужно ещё \(needed) монет")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Детали награды")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Купить награду?", isPresented: $showingConfirmation) {
                Button("Отмена", role: .cancel) { }
                Button("Купить за \(reward.cost) монет") {
                    _ = goalManager.purchaseReward(reward)
                }
            } message: {
                Text("Купить \"\(reward.title)\" за \(reward.cost) монет?")
            }
        }
    }
    
    private var categoryColor: Color {
        switch reward.category {
        case .instant: return .orange
        case .experience: return .blue
        case .purchase: return .pink
        case .bigGoal: return .purple
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// Helper View
struct StatBlock: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
    #Preview {
        RewardsShopView()
            .environmentObject(GoalManager())
    }

