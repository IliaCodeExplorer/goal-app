import SwiftUI

struct AddRewardView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var cost: String = ""
    @State private var selectedCategory: RewardCategory = .instant
    @State private var selectedIcon: String = "gift.fill"
    @State private var showingIconPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Детали награды") {
                    HStack {
                        Button {
                            showingIconPicker = true
                        } label: {
                            Image(systemName: selectedIcon)
                                .font(.title)
                                .foregroundColor(categoryColor)
                                .frame(width: 50, height: 50)
                                .background(categoryColor.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Название награды", text: $title)
                                .font(.body)
                            
                            Text("Нажмите на иконку для выбора")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    TextField("Описание", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.body)
                }
                
                Section("Стоимость") {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        
                        TextField("Цена в монетах", text: $cost)
                            .keyboardType(.numberPad)
                            .onChange(of: cost) { oldValue, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue {
                                    cost = filtered
                                }
                            }
                    }
                    
                    Text("Текущий баланс: \(goalManager.userProfile.coins) монет")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $selectedCategory) {
                        ForEach(RewardCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text(selectedCategory.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button {
                        saveReward()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Добавить награду")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Новая награда")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPicker(selectedIcon: $selectedIcon)
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !cost.isEmpty && Int(cost) != nil && Int(cost)! > 0
    }
    
    private func saveReward() {
        guard let costValue = Int(cost) else { return }
        
        let newReward = Reward(
            title: title,
            description: description,
            cost: costValue,
            icon: selectedIcon,
            category: selectedCategory,
            status: .available,
            isCustom: true
        )
        
        goalManager.addCustomReward(newReward)
        dismiss()
    }
    
    private var categoryColor: Color {
        switch selectedCategory {
        case .instant: return .orange
        case .experience: return .blue
        case .purchase: return .pink
        case .bigGoal: return .purple
        }
    }
}

#Preview {
    AddRewardView()
        .environmentObject(GoalManager())
}
