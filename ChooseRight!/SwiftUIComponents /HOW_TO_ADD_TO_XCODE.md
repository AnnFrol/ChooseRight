# Как добавить SwiftUI компоненты в Xcode проект

Файлы созданы в файловой системе, но их нужно добавить в проект Xcode вручную.

## Способ 1: Через Xcode (рекомендуется)

### Шаг 1: Откройте проект в Xcode
1. Откройте `ChooseRight!.xcodeproj` в Xcode

### Шаг 2: Добавьте папку SwiftUIComponents
1. В навигаторе проекта (левая панель) найдите папку `ChooseRight!`
2. Правый клик на папке `ChooseRight!`
3. Выберите **"Add Files to 'ChooseRight!'..."**
4. Перейдите в папку `ChooseRight!/SwiftUIComponents`
5. Выберите всю папку `SwiftUIComponents`
6. **ВАЖНО:** Убедитесь, что установлены галочки:
   - ✅ **"Copy items if needed"** (НЕ ставить, файлы уже на месте)
   - ✅ **"Create groups"** (создать группы)
   - ✅ **"Add to targets: ChooseRight!"** (добавить в таргет)
7. Нажмите **"Add"**

### Шаг 3: Проверьте структуру
После добавления в навигаторе проекта должна появиться папка `SwiftUIComponents` со следующей структурой:
```
ChooseRight!
  └── SwiftUIComponents/
      ├── Buttons/
      │   ├── CloseButtonView.swift
      │   ├── DeleteItemButtonView.swift
      │   ├── PlusMinusButtonView.swift
      │   └── AddAttributeButtonView.swift
      ├── Extensions/
      │   ├── Color + Extensions.swift
      │   └── Font + Extensions.swift
      ├── Views/
      │   ├── MainView.swift
      │   └── MainComparisonRowView.swift
      ├── Integration/
      │   ├── MainViewHostingController.swift
      │   └── SceneDelegateExtension.swift
      └── PreviewHelpers/
          ├── AllComponentsPreview.swift
          └── PreviewHelpers.swift
```

## Способ 2: Добавление отдельных файлов

Если способ 1 не сработал, добавьте файлы по одному:

1. Правый клик на папке `ChooseRight!` в навигаторе
2. **"Add Files to 'ChooseRight!'..."**
3. Выберите файл (например, `MainView.swift`)
4. Убедитесь, что галочка **"Add to targets: ChooseRight!"** установлена
5. Нажмите **"Add"**
6. Повторите для всех файлов

## Проверка

После добавления файлов:

1. Попробуйте собрать проект: `⌘ + B`
2. Если есть ошибки компиляции, проверьте:
   - Все файлы добавлены в таргет
   - Нет дублирующихся файлов
3. Откройте любой SwiftUI файл и проверьте превью: `⌥ + ⌘ + ↩`

## Если файлы не видны

1. Закройте и откройте Xcode
2. Очистите проект: `Product → Clean Build Folder` (`⇧ + ⌘ + K`)
3. Пересоберите проект: `⌘ + B`

## Альтернативный способ: через Finder

1. Откройте Finder
2. Перейдите в папку проекта
3. Перетащите папку `SwiftUIComponents` в навигатор проекта Xcode
4. В появившемся диалоге выберите:
   - ✅ **"Create groups"**
   - ✅ **"Add to targets: ChooseRight!"**
5. Нажмите **"Finish"**

## После добавления

После успешного добавления файлов вы сможете:
- ✅ Видеть их в навигаторе проекта
- ✅ Открывать и редактировать
- ✅ Использовать превью SwiftUI
- ✅ Компилировать проект

