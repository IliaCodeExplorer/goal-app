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
        // Мусульманин
        GoalTemplate(
            title: "Дополнительные молитвы (Суннах)",
            description: "Совершать дополнительные молитвы каждый день",
            category: .muslim,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "moon.stars.fill"
        ),
        GoalTemplate(
            title: "Ночные молитвы (Тахаджуд)",
            description: "Совершать ночные молитвы",
            category: .muslim,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "moon.fill"
        ),
        GoalTemplate(
            title: "Чтение Корана",
            description: "Читать Коран ежедневно",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "book.closed.fill"
        ),
        GoalTemplate(
            title: "Зикр (100 раз)",
            description: "Произносить зикр 100 раз в день",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 100,
            icon: "hand.raised.fill"
        ),
        GoalTemplate(
            title: "Дуа после каждой молитвы",
            description: "Читать дуа после обязательных молитв",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "hands.sparkles.fill"
        ),
        
        // Спорт
        GoalTemplate(
            title: "Тренировка в зале",
            description: "Посещать спортзал регулярно",
            category: .fitness,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 3,
            icon: "dumbbell.fill"
        ),
        GoalTemplate(
            title: "Бег",
            description: "Пробежать километры",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "figure.run"
        ),
        GoalTemplate(
            title: "Шаги в день",
            description: "Проходить 10000 шагов ежедневно",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 10000,
            icon: "figure.walk"
        ),
        GoalTemplate(
            title: "Йога/Растяжка",
            description: "Заниматься йогой или растяжкой",
            category: .fitness,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "figure.flexibility"
        ),
        
        // Бизнес
        GoalTemplate(
            title: "Рабочие часы",
            description: "Отработать продуктивные часы",
            category: .business,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 8,
            icon: "clock.fill"
        ),
        GoalTemplate(
            title: "Встречи с клиентами",
            description: "Провести встречи с клиентами",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 5,
            icon: "person.2.fill"
        ),
        GoalTemplate(
            title: "Новые контакты",
            description: "Найти новых потенциальных клиентов",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 10,
            icon: "phone.fill"
        ),
        GoalTemplate(
            title: "Обучение/Курсы",
            description: "Изучать новые навыки для бизнеса",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 2,
            icon: "graduationcap.fill"
        ),
        
        // Достигатор
        GoalTemplate(
            title: "Утренняя рутина",
            description: "Просыпаться в 6 утра",
            category: .achiever,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "sunrise.fill"
        ),
        GoalTemplate(
            title: "Планирование дня",
            description: "Планировать день заранее",
            category: .achiever,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "list.bullet.clipboard.fill"
        ),
        GoalTemplate(
            title: "Чтение книг",
            description: "Читать развивающие книги",
            category: .achiever,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 30,
            icon: "book.fill"
        ),
        GoalTemplate(
            title: "Медитация",
            description: "Медитировать для ясности ума",
            category: .achiever,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 10,
            icon: "brain.head.profile"
        ),
        
        // Семья
        GoalTemplate(
            title: "Время с семьей",
            description: "Проводить качественное время с семьей",
            category: .family,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 2,
            icon: "house.fill"
        ),
        GoalTemplate(
            title: "Свидание с супругой/супругом",
            description: "Проводить время вдвоем",
            category: .family,
            frequency: .weekly,
            trackingType: .binary,
            targetValue: 1,
            icon: "heart.fill"
        ),
        GoalTemplate(
            title: "Звонки родителям",
            description: "Звонить родителям",
            category: .family,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 2,
            icon: "phone.circle.fill"
        ),
        GoalTemplate(
            title: "Игры с детьми",
            description: "Играть с детьми",
            category: .family,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "figure.and.child.holdinghands"
        ),
        
        // Здоровье
        GoalTemplate(
            title: "Вода",
            description: "Выпивать стаканов воды",
            category: .health,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 8,
            icon: "drop.fill"
        ),
        GoalTemplate(
            title: "Сон",
            description: "Спать 8 часов",
            category: .health,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 8,
            icon: "bed.double.fill"
        ),
        GoalTemplate(
            title: "Здоровое питание",
            description: "Есть здоровую пищу",
            category: .health,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "leaf.fill"
        ),
        
        // Обучение
        GoalTemplate(
            title: "Изучение языка",
            description: "Изучать новый язык",
            category: .learning,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 30,
            icon: "character.book.closed.fill"
        ),
        GoalTemplate(
            title: "Онлайн курсы",
            description: "Проходить онлайн обучение",
            category: .learning,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 3,
            icon: "play.rectangle.fill"
        ),
    ]
    
    func templates(for category: GoalCategory) -> [GoalTemplate] {
        templates.filter { $0.category == category }
    }
}
