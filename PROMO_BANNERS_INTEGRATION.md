# 🎨 Промо-баннеры - Полная интеграция в PitCare App

## ✅ Что реализовано

Все компоненты промо-баннеров успешно интегрированы в основную логику приложения с использованием:
- ✅ **Dio** для HTTP запросов
- ✅ **Riverpod** для управления состоянием
- ✅ **Flutter UI** виджеты для отображения

---

## 📁 Созданные файлы

### 1. Модель данных
**Файл:** [lib/models/promo_banner.dart](../lib/models/promo_banner.dart)

```dart
class PromoBannerModel {
  final int id;
  final String titleMain;
  final String titleAccent;
  final String? description;
  final String buttonText;
  final String? routeName;
  final List<String> gradientColors;
  final List<double>? gradientStops;
  final int gradientRotation;
  final TextStyleModel titleStyle;
  final TextStyleModel accentStyle;
  final ButtonStyleModel buttonStyle;
  // ... другие поля
}
```

**Подмодели:**
- `TextStyleModel` - Стиль текста (размер, вес, цвет)
- `ButtonStyleModel` - Стиль кнопки (округление, отступы, цвета)

### 2. Сервис (Repository)
**Файл:** [lib/services/promo_banner_repository.dart](../lib/services/promo_banner_repository.dart)

```dart
class PromoBannerRepository {
  // Получить активные баннеры
  Future<List<PromoBannerModel>> fetchActiveBanners()
  
  // Получить все баннеры (включая неактивные)
  Future<List<PromoBannerModel>> fetchAllBanners()
  
  // Получить баннер по ID
  Future<PromoBannerModel> fetchBannerById(int bannerId)
  
  // Записать просмотр
  Future<void> recordDisplay(int bannerId)
  
  // Записать клик
  Future<void> recordClick(int bannerId)
  
  // Записать показ + клик
  Future<void> recordImpression(int bannerId)
}
```

### 3. Riverpod Провайдеры
**Файл:** [lib/providers/service_providers.dart](../lib/providers/service_providers.dart) (дополнен)

```dart
// Получить активные баннеры
final activePromoBannersProvider = FutureProvider<List<PromoBannerModel>>

// Получить все баннеры
final allPromoBannersProvider = FutureProvider<List<PromoBannerModel>>

// Получить баннер по ID
final promoBannerByIdProvider = FutureProvider.family<PromoBannerModel, int>

// Отслеживать отображенные баннеры
final displayedBannersProvider = StateNotifierProvider<DisplayedBannersNotifier, List<int>>

// Первый активный баннер
final firstPromoBannerProvider = FutureProvider<PromoBannerModel?>

// Отсортированные баннеры
final sortedPromoBannersProvider = FutureProvider<List<PromoBannerModel>>
```

### 4. UI Виджеты
**Файл:** [lib/widgets/promo_banner_widget.dart](../lib/widgets/promo_banner_widget.dart)

**Доступные виджеты:**

#### a) `PromoBannerWidget` - Один баннер
```dart
PromoBannerWidget(
  banner: bannerModel,
  padding: EdgeInsets.all(16),
  onDismiss: () { /* обработка закрытия */ },
)
```

#### b) `PromoBannerCarouselWidget` - Карусель баннеров
```dart
PromoBannerCarouselWidget(
  padding: EdgeInsets.symmetric(horizontal: 16),
  height: 180,
)
```

#### c) `PromoBannerSingleWidget` - Первый баннер
```dart
PromoBannerSingleWidget(
  padding: EdgeInsets.all(16),
  onDismiss: () { /* обработка закрытия */ },
)
```

### 5. Интеграция в home_screen
**Файл:** [lib/screens/home/home_screen.dart](../lib/screens/home/home_screen.dart) (обновлена)

Добавлено после хедера:
```dart
// Promo Banners
const PromoBannerSingleWidget(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
),
```

---

## 🚀 Использование

### Получение списка баннеров
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получить активные баннеры
    final bannersAsync = ref.watch(activePromoBannersProvider);
    
    return bannersAsync.when(
      data: (banners) => ListView(
        children: banners.map((banner) => 
          PromoBannerWidget(banner: banner)
        ).toList(),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Ошибка: $error'),
    );
  }
}
```

### Использование в карусели
```dart
// Автоматически загружает и отображает все активные баннеры
PromoBannerCarouselWidget(
  height: 180,
  padding: EdgeInsets.symmetric(horizontal: 16),
)
```

### Использование одного баннера
```dart
// Автоматически загружает первый активный баннер
PromoBannerSingleWidget(
  onDismiss: () => print('Баннер закрыт'),
)
```

### Запись метрик
```dart
final repository = ref.read(promoBannerRepositoryProvider);

// Записать просмотр
await repository.recordDisplay(bannerId);

// Записать клик
await repository.recordClick(bannerId);

// Записать показ + клик
await repository.recordImpression(bannerId);
```

---

## 📊 API Endpoints

```
GET  /api/banners/active       - Получить активные баннеры
GET  /api/banners              - Получить все баннеры
GET  /api/banners/{id}         - Получить баннер по ID
POST /api/banners/{id}/display - Записать просмотр
POST /api/banners/{id}/click   - Записать клик
POST /api/banners/{id}/impression - Записать показ + клик
```

---

## 🎨 Структура ответа API

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title_main": "Выездной ремонт",
      "title_accent": "за 30 минут!",
      "description": "Приезжаем в любую точку города",
      "button_text": "Вызвать мастера",
      "route_name": "/service/emergency",
      "gradient_colors": ["#00E676", "#1DE9B6", "#FFFFFF"],
      "gradient_stops": [0.0, 0.65, 1.0],
      "gradient_rotation": 128,
      "title_style": {
        "font_size": 20,
        "font_weight": 700,
        "font_family": "Roboto",
        "color": "#FFFFFF",
        "line_height": 1.2
      },
      "accent_style": {
        "font_size": 20,
        "font_weight": 800,
        "font_family": "Roboto",
        "color": "#FFFFFF",
        "line_height": 1.2
      },
      "button_style": {
        "border_radius": 12,
        "padding_horizontal": 16,
        "padding_vertical": 12,
        "background_color": "#FFFFFF",
        "text_color": "#00C853",
        "font_size": 16
      },
      "button_color": "#FFFFFF",
      "order": 1,
      "is_active": true,
      "start_date": "2026-01-01T00:00:00Z",
      "end_date": "2026-02-01T00:00:00Z",
      "display_count": 1250,
      "click_count": 85
    }
  ]
}
```

---

## 🔧 Особенности

### 1. Автоматическая фильтрация по датам
```dart
// Баннеры автоматически фильтруются по startDate и endDate
bool get isValid {
  final now = DateTime.now();
  final afterStart = startDate == null || now.isAfter(startDate!);
  final beforeEnd = endDate == null || now.isBefore(endDate!);
  return isActive && afterStart && beforeEnd;
}
```

### 2. Градиент из конфигурации
```dart
// Градиент строится из цветов и stops из API
Gradient _buildGradient() {
  final colors = banner.gradientColors
    .map((colorStr) => _colorFromHex(colorStr))
    .toList();

  return LinearGradient(
    colors: colors,
    stops: banner.gradientStops,
    begin: Alignment(0, -1),
    end: Alignment(1, 1),
  );
}
```

### 3. Отслеживание просмотров и кликов
```dart
// Просмотр записывается при отображении виджета
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read(promoBannerRepositoryProvider).recordDisplay(banner.id);
});

// Клик записывается при нажатии кнопки
void _onButtonPressed(BuildContext context, WidgetRef ref) {
  ref.read(promoBannerRepositoryProvider).recordClick(banner.id);
  
  if (banner.routeName != null) {
    context.go(banner.routeName!);
  }
}
```

### 4. Обработка ошибок
```dart
// Используется кастомное исключение PromoBannerException
try {
  final banners = await repository.fetchActiveBanners();
} on PromoBannerException catch (e) {
  print('Banner error: ${e.message} (${e.statusCode})');
} catch (e) {
  print('Unexpected error: $e');
}
```

---

## 📱 Использование в home_screen

Баннер автоматически загружается и отображается на главной странице:

```dart
// lib/screens/home/home_screen.dart

@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          _buildHomeHeaderBlock(context),
          const SizedBox(height: 14),
          
          // ✅ Промо-баннер добавлен здесь
          const PromoBannerSingleWidget(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          
          const SizedBox(height: 14),
          _buildSlider(context),
          // ... другой контент
        ],
      ),
    ),
  );
}
```

---

## 🎯 Примеры использования

### Пример 1: Отображение карусели на главной странице
```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Карусель с автоматической загрузкой
        PromoBannerCarouselWidget(
          height: 200,
          padding: EdgeInsets.all(16),
        ),
        // Другой контент...
      ],
    );
  }
}
```

### Пример 2: Кастомная обработка списка баннеров
```dart
class CustomBannerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(activePromoBannersProvider);
    final displayedBanners = ref.watch(displayedBannersProvider);
    
    return bannersAsync.when(
      data: (banners) => ListView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          final isDisplayed = displayedBanners.contains(banner.id);
          
          return PromoBannerWidget(
            banner: banner,
            onDismiss: () {
              // Отметить как отображенный
              ref.read(displayedBannersProvider.notifier)
                .markAsDisplayed(banner.id);
            },
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
```

### Пример 3: Отслеживание метрик
```dart
class BannerAnalyticsWidget extends ConsumerWidget {
  final int bannerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(promoBannerRepositoryProvider);
    
    return ElevatedButton(
      onPressed: () async {
        // Записать клик
        await repository.recordClick(bannerId);
        
        // Записать комбинированное событие
        await repository.recordImpression(bannerId);
        
        print('Banner $bannerId clicked and recorded');
      },
      child: Text('Track Click'),
    );
  }
}
```

---

## 🔌 Интеграция с маршрутизацией

Баннеры автоматически навигируют по маршруту, указанному в `route_name`:

```dart
// Из API приходит:
{
  "route_name": "/service/emergency"
}

// При клике баннер автоматически вызывает:
context.go("/service/emergency")
```

Убедитесь, что маршруты определены в вашей конфигурации go_router.

---

## 📈 Мониторинг метрик

Все метрики отправляются на сервер автоматически:

- **Display count** - увеличивается при отображении баннера
- **Click count** - увеличивается при клике по кнопке
- **Impression** - объединенное событие показа и клика

Метрики используются для:
- A/B тестирования
- Оптимизации кампаний
- Аналитики эффективности

---

## ⚙️ Конфигурация

Все параметры баннеров настраиваются на сервере через API:

```json
{
  "gradient_colors": ["#00E676", "#1DE9B6"],
  "gradient_rotation": 128,
  "title_style": { "font_size": 20, ... },
  "button_style": { "border_radius": 12, ... },
  "start_date": "2026-01-01T00:00:00Z",
  "end_date": "2026-02-01T00:00:00Z"
}
```

Изменения применяются автоматически без необходимости обновления приложения.

---

## 🐛 Обработка ошибок

Все ошибки при загрузке или отправке метрик обрабатываются gracefully:

```dart
// При ошибке загрузки баннеров виджет показывает пустой контент
PromoBannerSingleWidget(), // error: SizedBox.shrink()

// При ошибке записи метрик логируются в консоль, но не показываются пользователю
try {
  await repository.recordDisplay(bannerId);
} catch (e) {
  debugPrint('Error recording display: $e');
  // Не выбрасываем исключение
}
```

---

## ✨ Заключение

Система промо-баннеров полностью интегрирована в PitCare App:

- ✅ Использует существующий Dio клиент
- ✅ Использует Riverpod для управления состоянием
- ✅ Автоматическая фильтрация по датам
- ✅ Отслеживание просмотров и кликов
- ✅ Гибкая конфигурация из API
- ✅ Graceful обработка ошибок
- ✅ Интеграция с go_router

**Готова к использованию на prodction! 🚀**
