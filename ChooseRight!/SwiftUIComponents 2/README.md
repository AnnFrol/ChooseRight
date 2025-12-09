# SwiftUI Components Migration

Этот каталог содержит SwiftUI версии компонентов, мигрированных с UIKit.

## Структура

```
SwiftUIComponents/
├── Buttons/              # SwiftUI версии кастомных кнопок
│   ├── AddButtonView.swift
│   ├── CloseButtonView.swift
│   ├── DeleteItemButtonView.swift
│   ├── PlusMinusButtonView.swift
│   └── AddAttributeButtonView.swift
├── Views/                # SwiftUI версии основных экранов
│   ├── MainView.swift
│   └── MainComparisonRowView.swift
├── Extensions/           # Расширения для SwiftUI
│   ├── Color + Extensions.swift
│   └── Font + Extensions.swift
└── Integration/          # Интеграция с UIKit
    └── MainViewHostingController.swift
```

## Использование

### 1. Замена MainViewController на SwiftUI версию

В `SceneDelegate.swift` замените:

```swift
// Старый код
window?.rootViewController = UINavigationController(rootViewController: MainViewController())

// Новый код
let mainView = MainViewWrapper()
let hostingController = MainViewHostingController(rootView: mainView)
window?.rootViewController = UINavigationController(rootViewController: hostingController)
```

**Подробная инструкция:** См. [INTEGRATION_GUIDE.md](./INTEGRATION_GUIDE.md)

### 2. Использование SwiftUI кнопок в UIKit

Для использования SwiftUI кнопок в существующих UIKit view controllers, используйте `UIHostingController`:

```swift
let addButtonView = AddButtonView {
    // Ваш код
}
let hostingView = UIHostingController(rootView: addButtonView)
// Добавьте hostingView.view как subview
```

### 3. Использование SwiftUI Alert

SwiftUI Alert уже интегрирован в `MainView.swift`. Пример использования:

```swift
.alert("Title", isPresented: $showAlert) {
    TextField("Input", text: $text)
    Button("Cancel", role: .cancel) {}
    Button("Save") {
        // Действие
    }
}
```

## Преимущества миграции

1. **Меньше кода**: SwiftUI более декларативный и требует меньше строк кода
2. **Автоматические анимации**: Встроенные анимации для изменений состояния
3. **Лучшая производительность**: SwiftUI оптимизирован для современных устройств
4. **Проще тестирование**: Декларативный подход упрощает unit-тестирование
5. **Поддержка тем**: Автоматическая поддержка светлой/темной темы

## SwiftUI Previews

Все компоненты имеют превью для быстрой разработки в Xcode:

### Как использовать превью

1. Откройте любой файл с SwiftUI компонентом в Xcode
2. Нажмите `Option + Command + P` или кнопку "Resume" в Canvas
3. Превью автоматически обновится при изменении кода

### Доступные превью

- **MainView** - главный экран (3 варианта: пустой, с данными, темная тема)
- **MainComparisonRowView** - ячейка сравнения (светлая/темная тема)
- **AddButtonView** - кнопка добавления с анимацией
- **CloseButtonView** - кнопка закрытия
- **DeleteItemButtonView** - кнопка удаления
- **PlusMinusButtonView** - кнопки +/- 
- **AddAttributeButtonView** - кнопка добавления атрибута
- **AllComponentsPreview** - все компоненты вместе

### Превью с данными

Для превью MainView с реальными данными:
1. Запустите приложение один раз, чтобы создать данные в CoreData
2. Затем превью сможет отобразить их

## Следующие шаги

1. ✅ Созданы SwiftUI версии кнопок
2. ✅ Создана SwiftUI версия MainView
3. ✅ Интегрированы алерты
4. ✅ Добавлены превью для всех компонентов
5. ⏳ Миграция ComparisonListViewController (сложная, требует переработки)
6. ⏳ Миграция ObjectDetailsViewController (сложная, требует переработки)

## Примечания

- Сложные экраны (ComparisonListViewController, ObjectDetailsViewController) пока остаются в UIKit
- Для их интеграции используйте `UIViewControllerRepresentable` или `UIHostingController`
- Постепенная миграция позволяет тестировать каждый компонент отдельно

