
//
//  BackupManager..swift
//  GoalTracker
//
//  Created by Ilyas on 11/6/25.
//
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Combine
// MARK: - Backup Manager
class BackupManager {
    static let shared = BackupManager()
    
    struct BackupData: Codable {
        let goals: [Goal]
        let achievements: [Achievement]
        let rewards: [Reward]
        let userProfile: UserProfile
        let backupDate: Date
        let appVersion: String
        
        init(goalManager: GoalManager) {
            self.goals = goalManager.goals
            self.achievements = goalManager.achievements
            self.rewards = goalManager.rewards
            self.userProfile = goalManager.userProfile
            self.backupDate = Date()
            self.appVersion = "1.0"
        }
    }
    
    // MARK: - Export to JSON
    func exportData(goalManager: GoalManager) -> URL? {
        let backup = BackupData(goalManager: goalManager)
        
        guard let jsonData = try? JSONEncoder().encode(backup) else {
            print("Failed to encode backup data")
            return nil
        }
        
        let fileName = "GoalTracker_Backup_\(Date().formatted(date: .numeric, time: .omitted)).json"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to write backup file: \(error)")
            return nil
        }
    }
    
    // MARK: - Import from JSON
    func importData(from url: URL, to goalManager: GoalManager) -> Bool {
        do {
            let jsonData = try Data(contentsOf: url)
            let backup = try JSONDecoder().decode(BackupData.self, from: jsonData)
            
            // Restore data
            goalManager.goals = backup.goals
            goalManager.achievements = backup.achievements
            goalManager.rewards = backup.rewards
            goalManager.userProfile = backup.userProfile
            
            // Save to UserDefaults
            goalManager.objectWillChange.send()
            
            return true
        } catch {
            print("Failed to import backup: \(error)")
            return false
        }
    }
}

// MARK: - Backup View
struct BackupView: View {
    @EnvironmentObject var goalManager: GoalManager
    @Environment(\.dismiss) var dismiss
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var exportURL: URL?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Резервное копирование")
                            .font(.headline)
                        
                        Text("Сохраните свои данные, чтобы не потерять прогресс")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Экспорт данных") {
                    Button {
                        exportData()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Экспортировать данные")
                                    .foregroundColor(.primary)
                                
                                Text("Сохранить все данные в файл")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    if let url = exportURL {
                        ShareLink(item: url) {
                            HStack {
                                Image(systemName: "square.and.arrow.up.on.square")
                                    .foregroundColor(.green)
                                
                                Text("Поделиться файлом")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                Section("Импорт данных") {
                    Button {
                        showingImporter = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Импортировать данные")
                                    .foregroundColor(.primary)
                                
                                Text("Восстановить из файла резервной копии")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Section("Информация") {
                    HStack {
                        Text("Всего целей")
                        Spacer()
                        Text("\(goalManager.totalGoals)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Достижений")
                        Spacer()
                        Text("\(goalManager.achievements.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Наград")
                        Spacer()
                        Text("\(goalManager.rewards.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Уровень")
                        Spacer()
                        Text("\(goalManager.userProfile.level)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Монет")
                        Spacer()
                        Text("\(goalManager.userProfile.coins)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Резервное копирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    importData(from: url)
                case .failure(let error):
                    alertMessage = "Ошибка импорта: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            .alert("Результат", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func exportData() {
        if let url = BackupManager.shared.exportData(goalManager: goalManager) {
            exportURL = url
            alertMessage = "✅ Данные успешно экспортированы!"
            showingAlert = true
        } else {
            alertMessage = "❌ Ошибка экспорта данных"
            showingAlert = true
        }
    }
    
    private func importData(from url: URL) {
        let success = BackupManager.shared.importData(from: url, to: goalManager)
        
        if success {
            alertMessage = "✅ Данные успешно восстановлены!"
        } else {
            alertMessage = "❌ Ошибка импорта данных"
        }
        
        showingAlert = true
    }
}

#Preview {
    BackupView()
        .environmentObject(GoalManager())
}
