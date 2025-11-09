import Foundation

// VERSION 2.0
// CHANGES:
// - Recalibrated all difficulty levels based on real-world effort
// - Easy = можно сделать на автопилоте
// - Medium = нужна дисциплина
// - Hard = требует усилий и выхода из зоны комфорта
// - Epic = экстремально сложно, редко кто делает регулярно

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

// MARK: - Predefined Templates with REALISTIC difficulty
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
            difficulty: .hard  // РЕАЛИСТИЧНО: требует вставать для дополнительных молитв
        ),
        GoalTemplate(
            title: "Ночные молитвы (Тахаджуд)",
            description: "Совершать ночные молитвы",
            category: .muslim,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "moon.fill",
            difficulty: .epic  // РЕАЛИСТИЧНО: вставать ночью КАЖДУЮ ночь = экстрим
        ),
        GoalTemplate(
            title: "Чтение Корана",
            description: "Читать Коран ежедневно (страницы)",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "book.closed.fill",
            difficulty: .medium  // РЕАЛИСТИЧНО: 5 страниц = 10-15 минут, выполнимо
        ),
        GoalTemplate(
            title: "Зикр (100 раз)",
            description: "Произносить зикр 100 раз в день",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 100,
            icon: "hand.raised.fill",
            difficulty: .easy  // РЕАЛИСТИЧНО: 100 раз можно в транспорте
        ),
        GoalTemplate(
            title: "Дуа после каждой молитвы",
            description: "Читать дуа после обязательных молитв",
            category: .muslim,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "hands.sparkles.fill",
            difficulty: .easy  // РЕАЛИСТИЧНО: добавить 30 секунд после молитвы легко
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
            difficulty: .hard  // РЕАЛИСТИЧНО: 3 раза в неделю зал = нужна дисциплина
        ),
        GoalTemplate(
            title: "Бег",
            description: "Пробежать километры",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 5,
            icon: "figure.run",
            difficulty: .hard  // РЕАЛИСТИЧНО: 5км каждый день = сложно
        ),
        GoalTemplate(
            title: "Шаги в день",
            description: "Проходить 10000 шагов ежедневно",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 10000,
            icon: "figure.walk",
            difficulty: .medium  // РЕАЛИСТИЧНО: 10к шагов требует планирования
        ),
        GoalTemplate(
            title: "Йога/Растяжка",
            description: "Заниматься йогой или растяжкой",
            category: .fitness,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "figure.flexibility",
            difficulty: .medium  // РЕАЛИСТИЧНО: ежедневно 15-20 минут = средне
        ),
        GoalTemplate(
            title: "Отжимания",
            description: "Делать отжимания каждый день",
            category: .fitness,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 50,
            icon: "figure.strengthtraining.traditional",
            difficulty: .hard  // РЕАЛИСТИЧНО: 50 отжиманий каждый день нелегко
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
            difficulty: .medium  // РЕАЛИСТИЧНО: 8 часов ПРОДУКТИВНЫХ = средне
        ),
        GoalTemplate(
            title: "Встречи с клиентами",
            description: "Провести встречи с клиентами",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 5,
            icon: "person.2.fill",
            difficulty: .hard  // РЕАЛИСТИЧНО: 5 встреч в неделю = много подготовки
        ),
        GoalTemplate(
            title: "Новые контакты",
            description: "Найти новых потенциальных клиентов",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 10,
            icon: "phone.fill",
            difficulty: .hard  // РЕАЛИСТИЧНО: 10 новых лидов в неделю = сложно
        ),
        GoalTemplate(
            title: "Обучение/Курсы",
            description: "Изучать новые навыки для бизнеса",
            category: .business,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 2,
            icon: "graduationcap.fill",
            difficulty: .medium  // РЕАЛИСТИЧНО: 2 часа обучения в неделю реально
        ),
        GoalTemplate(
            title: "Проверка финансов",
            description: "Анализировать доходы и расходы",
            category: .business,
            frequency: .weekly,
            trackingType: .binary,
            targetValue: 1,
            icon: "chart.line.uptrend.xyaxis",
            difficulty: .easy  // РЕАЛИСТИЧНО: раз в неделю проверить = просто
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
            difficulty: .hard  // РЕАЛИСТИЧНО: вставать в 6 КАЖДЫЙ день = сложно
        ),
        GoalTemplate(
            title: "Планирование дня",
            description: "Планировать день заранее",
            category: .achiever,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "list.bullet.clipboard.fill",
            difficulty: .easy  // РЕАЛИСТИЧНО: 5 минут на план = легко
        ),
        GoalTemplate(
            title: "Чтение книг",
            description: "Читать развивающие книги (минуты)",
            category: .achiever,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 30,
            icon: "book.fill",
            difficulty: .medium  // РЕАЛИСТИЧНО: 30 минут каждый день = средне
        ),
        GoalTemplate(
            title: "Медитация",
            description: "Медитировать для ясности ума (минуты)",
            category: .achiever,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 10,
            icon: "brain.head.profile",
            difficulty: .medium  // РЕАЛИСТИЧНО: 10 минут медитации требует привычки
        ),
        GoalTemplate(
            title: "Журналинг",
            description: "Вести дневник благодарности",
            category: .achiever,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "pencil.and.list.clipboard",
            difficulty: .easy  // РЕАЛИСТИЧНО: 5 минут написать = легко
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
            difficulty: .medium  // РЕАЛИСТИЧНО: 2 часа качественного времени = средне
        ),
        GoalTemplate(
            title: "Свидание с супругой/супругом",
            description: "Проводить время вдвоем",
            category: .family,
            frequency: .weekly,
            trackingType: .binary,
            targetValue: 1,
            icon: "heart.fill",
            difficulty: .medium  // РЕАЛИСТИЧНО: раз в неделю найти время = средне
        ),
        GoalTemplate(
            title: "Звонки родителям",
            description: "Звонить родителям",
            category: .family,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 2,
            icon: "phone.circle.fill",
            difficulty: .easy  // РЕАЛИСТИЧНО: 2 звонка в неделю = просто
        ),
        GoalTemplate(
            title: "Игры с детьми",
            description: "Играть с детьми",
            category: .family,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "figure.and.child.holdinghands",
            difficulty: .easy  // РЕАЛИСТИЧНО: поиграть 15-20 минут = легко
        ),
        GoalTemplate(
            title: "Семейный ужин",
            description: "Ужинать всей семьей вместе",
            category: .family,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "fork.knife",
            difficulty: .medium  // РЕАЛИСТИЧНО: синхронизировать всех = средне
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
            difficulty: .easy  // РЕАЛИСТИЧНО: пить воду = просто
        ),
        GoalTemplate(
            title: "Сон",
            description: "Спать 8 часов",
            category: .health,
            frequency: .daily,
            trackingType: .numeric,
            targetValue: 8,
            icon: "bed.double.fill",
            difficulty: .medium  // РЕАЛИСТИЧНО: 8 часов регулярно = нужна дисциплина
        ),
        GoalTemplate(
            title: "Здоровое питание",
            description: "Есть здоровую пищу",
            category: .health,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "leaf.fill",
            difficulty: .hard  // РЕАЛИСТИЧНО: КАЖДЫЙ день здоровая еда = сложно
        ),
        GoalTemplate(
            title: "Витамины",
            description: "Принимать витамины",
            category: .health,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "pills.fill",
            difficulty: .easy  // РЕАЛИСТИЧНО: выпить таблетку = легко
        ),
        GoalTemplate(
            title: "Без сахара",
            description: "День без сладкого",
            category: .health,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "xmark.circle.fill",
            difficulty: .hard  // РЕАЛИСТИЧНО: отказ от сахара КАЖДЫЙ день = очень сложно
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
            difficulty: .medium  // РЕАЛИСТИЧНО: 30 минут языка каждый день = средне
        ),
        GoalTemplate(
            title: "Онлайн курсы",
            description: "Проходить онлайн обучение (часы)",
            category: .learning,
            frequency: .weekly,
            trackingType: .numeric,
            targetValue: 3,
            icon: "play.rectangle.fill",
            difficulty: .medium  // РЕАЛИСТИЧНО: 3 часа курсов в неделю = средне
        ),
        GoalTemplate(
            title: "Документация",
            description: "Читать техническую документацию",
            category: .learning,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "doc.text.fill",
            difficulty: .medium  // РЕАЛИСТИЧНО: каждый день читать доки = требует усилий
        ),
        GoalTemplate(
            title: "Практика кода",
            description: "Решать задачи на программирование",
            category: .learning,
            frequency: .daily,
            trackingType: .binary,
            targetValue: 1,
            icon: "chevron.left.forwardslash.chevron.right",
            difficulty: .hard  // РЕАЛИСТИЧНО: кодить каждый день задачи = сложно
        ),
    ]
    
    func templates(for category: GoalCategory) -> [GoalTemplate] {
        templates.filter { $0.category == category }
    }
}
