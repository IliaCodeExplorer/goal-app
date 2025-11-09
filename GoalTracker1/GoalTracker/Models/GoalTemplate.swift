import Foundation

// MARK: - Goal Template
struct GoalTemplate: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: GoalCategory
    let frequency: Frequency
    let trackingType: TrackingType
    let targetValue: Double
    let icon: String
    let difficulty: Difficulty
    
    var statCategory: StatCategory {
        StatCategory.fromGoalCategory(category)
    }
}

// MARK: - Goal Category
enum GoalCategory: String, CaseIterable {
    case muslim = "Мусульманин"
    case fitness = "Спорт"
    case business = "Бизнес"
    case achiever = "Достигатор"
    case family = "Семья"
    case health = "Здоровье"
    case learning = "Обучение"
    
    var icon: String {
        switch self {
        case .muslim: return "moon.stars.fill"
        case .fitness: return "figure.run"
        case .business: return "briefcase.fill"
        case .achiever: return "star.fill"
        case .family: return "heart.fill"
        case .health: return "heart.text.square.fill"
        case .learning: return "book.fill"
        }
    }
}

// MARK: - Predefined Templates
class GoalTemplateManager {
    static let shared = GoalTemplateManager()
    
    let templates: [GoalTemplate] = [
        // МУСУЛЬМАНИН
        GoalTemplate(
            title: "Дополнительные молитвы (Суннах)",
            description: "Совершать дополнительные молитвы каждый день",
            category: .muslim,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "moon.stars.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Ночные молитвы (Тахаджуд)",
            description: "Совершать ночные молитвы",
            category: .muslim,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "moon.fill",
            difficulty: .hard
        ),
        GoalTemplate(
            title: "Чтение Корана",
            description: "Читать Коран ежедневно (страницы)",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "book.closed.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Зикр (100 раз)",
            description: "Произносить зикр 100 раз в день",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 100,
            icon: "hand.raised.fill",
            difficulty: .easy
        ),
        GoalTemplate(
            title: "Дуа после каждой молитвы",
            description: "Читать дуа после обязательных молитв",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "hands.sparkles.fill",
            difficulty: .medium
        ),
        
        // СПОРТ
        GoalTemplate(
            title: "Тренировка в зале",
            description: "Посещать спортзал регулярно",
            category: .fitness,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 3,
            icon: "dumbbell.fill",
            difficulty: .hard
        ),
        GoalTemplate(
            title: "Бег",
            description: "Пробежать километры",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "figure.run",
            difficulty: .hard
        ),
        GoalTemplate(
            title: "Шаги в день",
            description: "Проходить 10000 шагов ежедневно",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 10000,
            icon: "figure.walk",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Йога/Растяжка",
            description: "Заниматься йогой или растяжкой",
            category: .fitness,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "figure.flexibility",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Отжимания",
            description: "Делать отжимания каждый день",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 50,
            icon: "figure.strengthtraining.traditional",
            difficulty: .hard
        ),
        
        // БИЗНЕС
        GoalTemplate(
            title: "Рабочие часы",
            description: "Отработать продуктивные часы",
            category: .business,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 8,
            icon: "clock.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Встречи с клиентами",
            description: "Провести встречи с клиентами",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 5,
            icon: "person.2.fill",
            difficulty: .hard
        ),
        GoalTemplate(
            title: "Новые контакты",
            description: "Найти новых потенциальных клиентов",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 10,
            icon: "phone.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Обучение/Курсы",
            description: "Изучать новые навыки для бизнеса",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 2,
            icon: "graduationcap.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Проверка финансов",
            description: "Анализировать доходы и расходы",
            category: .business,
            frequency: .weekly,
            trackingType: .binary,
            targetValue: 1,
            icon: "chart.line.uptrend.xyaxis",
            difficulty: .easy
        ),
        
        // ДОСТИГАТОР
        GoalTemplate(
            title: "Утренняя рутина",
            description: "Просыпаться в 6 утра",
            category: .achiever,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "sunrise.fill",
            difficulty: .hard
        ),
        GoalTemplate(
            title: "Планирование дня",
            description: "Планировать день заранее",
            category: .achiever,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "list.bullet.clipboard.fill",
            difficulty: .easy
        ),
        GoalTemplate(
            title: "Чтение книг",
            description: "Читать развивающие книги (минуты)",
            category: .achiever,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 30,
            icon: "book.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Медитация",
            description: "Медитировать для ясности ума (минуты)",
            category: .achiever,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 10,
            icon: "brain.head.profile",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Журналинг",
            description: "Вести дневник благодарности",
            category: .achiever,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "pencil.and.list.clipboard",
            difficulty: .easy
        ),
        
        // СЕМЬЯ
        GoalTemplate(
            title: "Время с семьей",
            description: "Проводить качественное время с семьей (часы)",
            category: .family,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 2,
            icon: "house.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Свидание с супругой/супругом",
            description: "Проводить время вдвоем",
            category: .family,
            frequency: .weekly,
            trackingType: .binary,
            targetValue: 1,
            icon: "heart.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Звонки родителям",
            description: "Звонить родителям",
            category: .family,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 2,
            icon: "phone.circle.fill",
            difficulty: .easy
        ),
        GoalTemplate(
            title: "Игры с детьми",
            description: "Играть с детьми",
            category: .family,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "figure.and.child.holdinghands",
            difficulty: .easy
        ),
        GoalTemplate(
            title: "Семейный ужин",
            description: "Ужинать всей семьей вместе",
            category: .family,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "fork.knife",
            difficulty: .medium
        ),
        
        // ЗДОРОВЬЕ
        GoalTemplate(
            title: "Вода",
            description: "Выпивать стаканов воды",
            category: .health,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 8,
            icon: "drop.fill",
            difficulty: .easy
        ),
        GoalTemplate(
            title: "Сон",
            description: "Спать 8 часов",
            category: .health,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 8,
            icon: "bed.double.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Здоровое питание",
            description: "Есть здоровую пищу",
            category: .health,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "leaf.fill",
            difficulty: .hard
        ),
        GoalTemplate(
            title: "Витамины",
            description: "Принимать витамины",
            category: .health,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "pills.fill",
            difficulty: .easy
        ),
        GoalTemplate(
            title: "Без сахара",
            description: "День без сладкого",
            category: .health,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "xmark.circle.fill",
            difficulty: .hard
        ),
        
        // ОБУЧЕНИЕ
        GoalTemplate(
            title: "Изучение языка",
            description: "Изучать новый язык (минуты)",
            category: .learning,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 30,
            icon: "character.book.closed.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Онлайн курсы",
            description: "Проходить онлайн обучение (часы)",
            category: .learning,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 3,
            icon: "play.rectangle.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Документация",
            description: "Читать техническую документацию",
            category: .learning,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "doc.text.fill",
            difficulty: .medium
        ),
        GoalTemplate(
            title: "Практика кода",
            description: "Решать задачи на программирование",
            category: .learning,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "chevron.left.forwardslash.chevron.right",
            difficulty: .hard
        ),
    ]
    
    func templates(for category: GoalCategory) -> [GoalTemplate] {
        templates.filter { $0.category == category }
    }
}
