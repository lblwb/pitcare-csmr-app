# Маркетинговый функционал - Управление Промо Баннерами

## Описание

Полнофункциональная система управления промо баннерами для отображения в мобильном приложении сервиса. Включает создание, редактирование, удаление и аналитику по просмотрам и кликам.

## Архитектура

### Компоненты

- **Model**: `App\Models\PromoBanner` - модель для хранения данных баннеров
- **Controller**: `App\Http\Controllers\PromoBannerController` - API контроллер
- **Service**: `App\Services\PromoBannerService` - бизнес-логика
- **Requests**: `StorePromoBannerRequest`, `UpdatePromoBannerRequest` - валидация
- **Seeder**: `PromoBannerSeeder` - инициализация примеров

### Таблица базы данных

```sql
CREATE TABLE promo_banners (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title_main VARCHAR(255) NOT NULL,           -- Основной заголовок
    title_accent VARCHAR(255) NOT NULL,         -- Акцентный заголовок
    description TEXT,                           -- Описание
    button_text VARCHAR(255) NOT NULL,          -- Текст кнопки
    route_name VARCHAR(255),                    -- Маршрут при клике
    gradient_colors JSON NOT NULL,              -- Массив цветов градиента
    gradient_stops JSON,                        -- Остановки градиента [0.0, 0.65, 1.0]
    gradient_rotation INT DEFAULT 128,          -- Угол поворота градиента (градусы)
    title_style JSON NOT NULL,                  -- Стили для заголовка
    accent_style JSON NOT NULL,                 -- Стили для акцента
    button_style JSON NOT NULL,                 -- Стили для кнопки
    button_color VARCHAR(255),                  -- Цвет кнопки
    order INT DEFAULT 0,                        -- Порядок отображения
    is_active BOOLEAN DEFAULT TRUE,             -- Активен ли баннер
    start_date TIMESTAMP,                       -- Дата начала показа
    end_date TIMESTAMP,                         -- Дата окончания показа
    display_count INT DEFAULT 0,                -- Количество просмотров
    click_count INT DEFAULT 0,                  -- Количество кликов
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,                       -- Soft delete
    INDEXES: order, is_active, start_date, end_date
);
```

## API Endpoints

### Публичные endpoints (для мобильного приложения)

#### GET `/api/banners/active`
Получить активные баннеры для отображения в приложении.

**Rate limit**: 60 запросов/минуту

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title_main": "Выездной ремонт",
      "title_accent": "за 30 минут!",
      "description": "Мастер приедет к вам и выполнит ремонт на месте",
      "button_text": "Вызвать мастера",
      "route_name": "call_master",
      "gradient_colors": ["#00E676", "#1DE9B6", "#FFFFFF"],
      "gradient_stops": [0.0, 0.65, 1.0],
      "gradient_rotation": 128,
      "title_style": {
        "color": "#FFFFFF",
        "fontSize": 20,
        "fontWeight": "700",
        "letterSpacing": 0.2
      },
      "accent_style": {
        "color": "#FFFFFF",
        "fontSize": 20,
        "fontWeight": "800",
        "letterSpacing": 0.2
      },
      "button_style": {
        "backgroundColor": "#FFFFFF",
        "foregroundColor": "#00C853",
        "borderRadius": 12,
        "borderColor": "#00C853",
        "borderWidth": 1
      },
      "button_color": "#00C853",
      "order": 1,
      "is_active": true
    }
  ]
}
```

#### POST `/api/banners/{id}/display`
Записать просмотр баннера.

**Rate limit**: 120 запросов/минуту

**Request params**: 
- `id` - ID баннера

**Response**:
```json
{
  "success": true,
  "message": "Display recorded"
}
```

#### POST `/api/banners/{id}/click`
Записать клик по баннеру.

**Rate limit**: 60 запросов/минуту

**Request params**:
- `id` - ID баннера

**Response**:
```json
{
  "success": true,
  "message": "Click recorded"
}
```

### Админ endpoints (требуется аутентификация)

#### GET `/api/admin/banners`
Получить все баннеры с пагинацией (15 на странице).

**Auth**: Требуется токен Sanctum и роль admin

**Rate limit**: 30 запросов/минуту

**Query params**:
- `page` - номер страницы (по умолчанию 1)
- `per_page` - количество на странице (по умолчанию 15)

**Response**:
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "total": 4,
    "per_page": 15,
    "current_page": 1,
    "last_page": 1
  }
}
```

#### POST `/api/admin/banners`
Создать новый баннер.

**Auth**: Требуется токен Sanctum и роль admin

**Rate limit**: 10 запросов/минуту

**Request body**:
```json
{
  "title_main": "Выездной ремонт",
  "title_accent": "за 30 минут!",
  "description": "Мастер приедет к вам",
  "button_text": "Вызвать мастера",
  "route_name": "call_master",
  "gradient_colors": ["#00E676", "#1DE9B6", "#FFFFFF"],
  "gradient_stops": [0.0, 0.65, 1.0],
  "gradient_rotation": 128,
  "title_style": {
    "color": "#FFFFFF",
    "fontSize": 20,
    "fontWeight": "700",
    "letterSpacing": 0.2
  },
  "accent_style": {
    "color": "#FFFFFF",
    "fontSize": 20,
    "fontWeight": "800",
    "letterSpacing": 0.2
  },
  "button_style": {
    "backgroundColor": "#FFFFFF",
    "foregroundColor": "#00C853",
    "borderRadius": 12,
    "borderColor": "#00C853",
    "borderWidth": 1
  },
  "button_color": "#00C853",
  "order": 1,
  "is_active": true,
  "start_date": "2026-01-04",
  "end_date": "2026-02-04"
}
```

#### GET `/api/admin/banners/{id}`
Получить информацию о конкретном баннере.

**Rate limit**: 60 запросов/минуту

#### PUT `/api/admin/banners/{id}`
Обновить баннер.

**Rate limit**: 20 запросов/минуту

**Request body**: Те же поля, что и при создании (опциональны)

#### DELETE `/api/admin/banners/{id}`
Удалить баннер (soft delete).

**Rate limit**: 20 запросов/минуту

#### GET `/api/admin/banners/analytics`
Получить аналитику по всем баннерам.

**Rate limit**: 30 запросов/минуту

**Response**:
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_banners": 4,
      "active_banners": 4,
      "total_displays": 1250,
      "total_clicks": 125,
      "overall_ctr": 10.0
    },
    "banners": [
      {
        "id": 1,
        "title": "Выездной ремонт",
        "is_active": true,
        "displays": 350,
        "clicks": 42,
        "ctr": 12.0
      }
    ]
  }
}
```

#### POST `/api/admin/banners/reorder`
Переупорядочить баннеры.

**Rate limit**: 20 запросов/минуту

**Request body**:
```json
{
  "orders": [
    {"id": 1, "order": 1},
    {"id": 2, "order": 2},
    {"id": 3, "order": 3},
    {"id": 4, "order": 4}
  ]
}
```

#### PATCH `/api/admin/banners/{id}/toggle`
Включить/выключить баннер.

**Rate limit**: 20 запросов/минуту

**Response**:
```json
{
  "success": true,
  "message": "Banner status updated",
  "data": {...}
}
```

## Использование в Flutter коде

### Получение активных баннеров

```dart
final response = await http.get(
  Uri.parse('$API_BASE_URL/api/banners/active'),
  headers: {'Accept': 'application/json'},
);

final data = jsonDecode(response.body);
final banners = (data['data'] as List)
    .map((b) => PromoBannerModel.fromJson(b))
    .toList();
```

### Запись просмотра баннера

```dart
await http.post(
  Uri.parse('$API_BASE_URL/api/banners/$bannerId/display'),
  headers: {'Accept': 'application/json'},
);
```

### Запись клика по баннеру

```dart
await http.post(
  Uri.parse('$API_BASE_URL/api/banners/$bannerId/click'),
  headers: {'Accept': 'application/json'},
);
// Затем навигировать по маршруту
```

## Использование в коде PHP

### Использование сервиса

```php
use App\Services\PromoBannerService;

class YourController
{
    public function __construct(
        private PromoBannerService $bannerService
    ) {}

    public function showBanners()
    {
        $banners = $this->bannerService->getActiveBanners();
        
        return response()->json($banners);
    }

    public function createBanner(array $data)
    {
        if (!$this->bannerService->validateBannerData($data)) {
            return response()->json(['error' => 'Invalid data'], 422);
        }

        $banner = $this->bannerService->createBanner($data);
        return response()->json($banner, 201);
    }

    public function getAnalytics()
    {
        $analytics = $this->bannerService->getAnalytics();
        return response()->json($analytics);
    }
}
```

## Примеры баннеров

В системе предустановлены 4 примера баннеров:

1. **Выездной ремонт** - Мастер приезжает за 30 минут
   - Цвета: Mint Green → Teal → White
   - Кнопка: "Вызвать мастера" (зеленая)

2. **Диагностика** - Бесплатная диагностика до 15 км
   - Цвета: Indigo → Cyan → White
   - Кнопка: "Заказать" (синяя)

3. **Эвакуатор** - Эвакуаторе со скидкой 20%
   - Цвета: Orange → Amber → White
   - Кнопка: "Срочно" (оранжевая)

4. **Техническое обслуживание** - ТО со скидкой
   - Цвета: Purple → Pink → White
   - Кнопка: "Подробнее" (красная)

## Функции модели PromoBanner

```php
// Получить активные баннеры
$activeBanners = PromoBanner::active()->get();

// Получить упорядоченные баннеры
$orderedBanners = PromoBanner::ordered()->get();

// Получить активные и упорядоченные
$banners = PromoBanner::active()->ordered()->get();

// Статический метод для получения для отображения
$displayBanners = PromoBanner::getActiveForDisplay();

// Записать просмотр
$banner->recordDisplay();

// Записать клик
$banner->recordClick();

// Получить CTR (Click-Through Rate)
$ctr = $banner->getClickThroughRate(); // Возвращает процент
```

## Примечания

- Все цвета хранятся в формате HEX (#RRGGBB или #RRGGBBAA)
- Градиент может иметь от 2 до бесконечности цветов
- Остановки градиента (gradient_stops) - массив чисел от 0 до 1
- Порядок сортировки баннеров - по полю `order` (ASC)
- Активные баннеры - это баннеры где `is_active=true` и текущая дата между `start_date` и `end_date`
- CTR вычисляется как (clicks / displays) * 100
- Используется Soft Delete, поэтому удаленные баннеры сохраняются в БД

## Миграция БД

```bash
php artisan migrate
```

## Заполнение примерами

```bash
php artisan db:seed --class=PromoBannerSeeder
```

## Тестирование

### Получить активные баннеры
```bash
curl http://localhost:8000/api/banners/active
```

### Создать баннер (требует аутентификацию)
```bash
curl -X POST http://localhost:8000/api/admin/banners \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{...}'
```

### Получить аналитику
```bash
curl http://localhost:8000/api/admin/banners/analytics \
  -H "Authorization: Bearer YOUR_TOKEN"
```
