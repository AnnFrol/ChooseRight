# Руководство по интеграции SwiftUI MainView

## Быстрый старт

### Вариант 1: Полная замена (рекомендуется для тестирования)

В файле `SceneDelegate.swift` замените:

```swift
// Старый код
window?.rootViewController = UINavigationController(rootViewController: MainViewController())

// Новый код
let mainView = MainViewWrapper()
let hostingController = MainViewHostingController(rootView: mainView)
window?.rootViewController = UINavigationController(rootViewController: hostingController)
```

### Вариант 2: Переключение через флаг

В файле `SceneDelegateExtension.swift` измените:

```swift
private static let useSwiftUI = true  // true для SwiftUI, false для UIKit
```

Затем в `SceneDelegate.swift` используйте:

```swift
setupRootViewController()
```

## Что работает

✅ **Список сравнений** - отображается корректно  
✅ **Создание нового сравнения** - открывает ComparisonListViewController  
✅ **Удаление сравнения** - работает через контекстное меню  
✅ **Переименование сравнения** - работает через контекстное меню  
✅ **Изменение цвета** - работает через контекстное меню  
✅ **Навигация** - переход к ComparisonListViewController работает  
✅ **Алерты** - все алерты работают через SwiftUI Alert  

## Особенности интеграции

### Навигация

Навигация реализована через `NotificationCenter`:
- При выборе сравнения отправляется уведомление `NavigateToComparison`
- При создании нового сравнения отправляется уведомление `NavigateToNewComparison`
- `MainViewHostingController` обрабатывает эти уведомления и выполняет навигацию

### Данные

- Используется тот же `CoreDataManager.shared`
- Данные синхронизируются автоматически через `@Published` в ViewModel
- При изменении данных вызывается `loadData()` для обновления списка

### Стилизация

- Все цвета соответствуют UIKit версии через `Color.specialColors`
- Все шрифты соответствуют UIKit версии через `Font` расширения
- Визуально идентично оригинальной версии

## Откат к UIKit версии

Если нужно вернуться к UIKit версии:

1. В `SceneDelegate.swift` верните оригинальный код:
```swift
window?.rootViewController = UINavigationController(rootViewController: MainViewController())
```

2. Или в `SceneDelegateExtension.swift` установите:
```swift
private static let useSwiftUI = false
```

## Тестирование

1. Запустите приложение
2. Проверьте отображение списка сравнений
3. Создайте новое сравнение - должно открыться ComparisonListViewController
4. Выберите существующее сравнение - должен открыться ComparisonListViewController
5. Используйте контекстное меню для изменения/удаления

## Известные ограничения

- Сложные экраны (ComparisonListViewController, ObjectDetailsViewController) остаются в UIKit
- Некоторые анимации могут отличаться от оригинальных
- Notch view (верхний индикатор) пока не реализован в SwiftUI версии

## Следующие шаги

1. Добавить Notch view в SwiftUI версию
2. Улучшить анимации переходов
3. Добавить поддержку drag-to-refresh
4. Оптимизировать производительность для больших списков

