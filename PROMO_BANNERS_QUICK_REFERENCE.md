# 🚀 Промо-баннеры - Быстрый старт

## ✨ Что готово

Система промо-баннеров полностью интегрирована в приложение PitCare с использованием Dio и Riverpod.

---

## 📍 Где найти

| Компонент | Путь |
|-----------|------|
| Модель | `lib/models/promo_banner.dart` |
| Сервис | `lib/services/promo_banner_repository.dart` |
| Провайдеры | `lib/providers/service_providers.dart` |
| Виджеты | `lib/widgets/promo_banner_widget.dart` |
| Home Screen | `lib/screens/home/home_screen.dart` |

---

## 🎯 3 способа использования

### 1️⃣ Одиночный баннер (уже используется в home_screen)
```dart
PromoBannerSingleWidget(
  padding: EdgeInsets.all(16),
  onDismiss: () => print('Dismissed'),
)
```

### 2️⃣ Карусель баннеров
```dart
PromoBannerCarouselWidget(
  height: 200,
  padding: EdgeInsets.symmetric(horizontal: 16),
)
```

### 3️⃣ Кастомный контроль
```dart
final bannersAsync = ref.watch(activePromoBannersProvider);

bannersAsync.when(
  data: (banners) => ListView(
    children: banners.map((b) => PromoBannerWidget(banner: b)).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => SizedBox.shrink(),
);
```

---

## 🔗 API Endpoints

Все автоматически используют существующий Dio клиент:

```
GET  /api/banners/active         ← Получить активные баннеры
POST /api/banners/{id}/display   ← Записать просмотр
POST /api/banners/{id}/click     ← Записать клик
```

---

## 📊 Пример ответа API

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title_main": "Выездной ремонт",
      "title_accent": "за 30 минут!",
      "description": "Быстро и качественно",
      "button_text": "Вызвать мастера",
      "route_name": "/service/emergency",
      "gradient_colors": ["#00E676", "#1DE9B6", "#FFFFFF"],
      "gradient_stops": [0.0, 0.65, 1.0],
      "gradient_rotation": 128,
      "title_style": {
        "font_size": 20,
        "font_weight": 700,
        "color": "#FFFFFF"
      },
      "accent_style": {
        "font_size": 20,
        "font_weight": 800,
        "color": "#FFFFFF"
      },
      "button_style": {
        "border_radius": 12,
        "padding_horizontal": 16,
        "padding_vertical": 12,
        "background_color": "#FFFFFF",
        "text_color": "#00C853"
      },
      "is_active": true,
      "start_date": "2026-01-01T00:00:00Z",
      "end_date": "2026-02-01T00:00:00Z"
    }
  ]
}
```

---

## 💡 Ключевые особенности

### ✅ Автоматическая фильтрация
Баннеры автоматически отфильтровываются по датам `start_date` и `end_date`.

### ✅ Использование Dio
Использует существующий `DioClient` для всех запросов.

### ✅ Riverpod провайдеры
- `activePromoBannersProvider` - активные баннеры
- `allPromoBannersProvider` - все баннеры
- `firstPromoBannerProvider` - первый баннер
- `sortedPromoBannersProvider` - отсортированные баннеры
- `displayedBannersProvider` - отслеживание отображенных

### ✅ Запись метрик
Просмотры и клики записываются автоматически:
```dart
// Просмотр записывается при отображении
PromoBannerWidget(banner: banner)

// Клик записывается при нажатии кнопки
onPressed: () => ref.read(promoBannerRepositoryProvider).recordClick(id)
```

### ✅ Навигация
Баннеры автоматически навигируют по маршруту из `route_name`:
```dart
"route_name": "/service/emergency"
// При клике: context.go("/service/emergency")
```

---

## 📝 Примеры

### Получить список активных баннеров
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(activePromoBannersProvider);
    
    return banners.when(
      data: (list) => Text('Баннеров: ${list.length}'),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Ошибка: $e'),
    );
  }
}
```

### Отобразить все баннеры в списке
```dart
final banners = ref.watch(sortedPromoBannersProvider);

return banners.when(
  data: (list) => ListView(
    children: list.map((b) => PromoBannerWidget(banner: b)).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => SizedBox.shrink(),
);
```

### Отслеживание метрик
```dart
final repo = ref.read(promoBannerRepositoryProvider);

// Записать просмотр
await repo.recordDisplay(bannerId);

// Записать клик
await repo.recordClick(bannerId);

// Записать комбинированное событие
await repo.recordImpression(bannerId);
```

---

## ✅ На главной странице

Баннер уже добавлен в `home_screen.dart`:

```dart
Column(
  children: [
    _buildHomeHeaderBlock(context),
    const SizedBox(height: 14),
    
    // ✅ Промо-баннер здесь
    const PromoBannerSingleWidget(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    const SizedBox(height: 14),
    _buildSlider(context),
    // ...
  ],
)
```

---

## 🎨 Кастомизация

Все параметры настраиваются на сервере:

- **Цвета** - `gradient_colors` и `gradient_stops`
- **Текст** - `title_main`, `title_accent`, `description`, `button_text`
- **Стили** - `title_style`, `accent_style`, `button_style`
- **Даты** - `start_date` и `end_date`
- **Маршруты** - `route_name`

Изменения применяются без обновления приложения! 🚀

---

## 🐛 Обработка ошибок

Все ошибки обрабатываются gracefully:

```dart
// Если ошибка загрузки → SizedBox.shrink()
// Если ошибка метрик → логируется, но не показывается
```

---

## 📚 Полная документация

Подробнее в [PROMO_BANNERS_INTEGRATION.md](PROMO_BANNERS_INTEGRATION.md)

---

**✨ Готово к использованию! ✨**
