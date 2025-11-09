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
        case .virtual: return .purple
        case .food: return .orange
        case .entertainment: return .blue
        case .fitness: return .green
        case .shopping: return .pink
        case .bigGoal: return .yellow
        @unknown default: return .gray
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
    
    var canPurchase: Bool {
        canAfford && !reward.isPurchased
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
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
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: reward.icon)
                            .font(.system(size: 70))
                            .foregroundColor(categoryColor)
                    }
                    .padding(.top)
                    
                    // Info
                    VStack(spacing: 16) {
                        Text(reward.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(reward.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("Стоимость")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.yellow)
                                    
                                    Text("\(reward.cost)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(spacing: 4) {
                                Text("Категория")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(reward.category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(categoryColor)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Кнопка покупки
                    if canPurchase {
                        Button {
                            showingConfirmation = true
                        } label: {
                            Text("Купить награду")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else if !canAfford {
                        VStack(spacing: 12) {
                            Text("Недостаточно монет")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text("Нужно еще \(reward.cost - goalManager.userProfile.coins) монет")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else if reward.isPurchased {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("Награда уже куплена!")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            if let date = reward.purchaseDate {
                                Text("Куплено: \(date.formatted(date: .long, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding()
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
                    if goalManager.purchaseReward(reward) {
                        dismiss()
                    }
                }
            } message: {
                Text("Вы уверены что хотите купить \"\(reward.title)\"?")
            }
        }
    }
    
    private var categoryColor: Color {
        switch reward.category {
        case .virtual: return .purple
        case .food: return .orange
        case .entertainment: return .blue
        case .fitness: return .green
        case .shopping: return .pink
        case .bigGoal: return .yellow
        @unknown default: return .gray
        }
    }}

#Preview {
    RewardsShopView()
        .environmentObject(GoalManager())
}
