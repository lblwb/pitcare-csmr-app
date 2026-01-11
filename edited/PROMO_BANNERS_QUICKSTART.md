# Промо Баннеры - Быстрый Старт

## 1. Инициализация

```bash
# Миграция таблицы
php artisan migrate

# Заполнение примерами
php artisan db:seed --class=PromoBannerSeeder
```

## 2. Получение баннеров в приложении

### GET `/api/banners/active` - Получить активные баннеры

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<PromoBanner>> getActiveBanners() async {
  final response = await http.get(
    Uri.parse('$API_BASE_URL/api/banners/active'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['data'] as List)
        .map((b) => PromoBanner.fromJson(b))
        .toList();
  }
  throw Exception('Failed to load banners');
}
```

### Модель PromoBanner для Flutter

```dart
class PromoBanner {
  final int id;
  final String titleMain;
  final String titleAccent;
  final String? description;
  final String buttonText;
  final String? routeName;
  final List<String> gradientColors;
  final List<double>? gradientStops;
  final int gradientRotation;
  final TextStyle titleStyle;
  final TextStyle accentStyle;
  final ButtonStyle buttonStyle;

  PromoBanner({
    required this.id,
    required this.titleMain,
    required this.titleAccent,
    this.description,
    required this.buttonText,
    this.routeName,
    required this.gradientColors,
    this.gradientStops,
    required this.gradientRotation,
    required this.titleStyle,
    required this.accentStyle,
    required this.buttonStyle,
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: json['id'],
      titleMain: json['title_main'],
      titleAccent: json['title_accent'],
      description: json['description'],
      buttonText: json['button_text'],
      routeName: json['route_name'],
      gradientColors: List<String>.from(json['gradient_colors']),
      gradientStops: json['gradient_stops'] != null
          ? List<double>.from(json['gradient_stops'])
          : null,
      gradientRotation: json['gradient_rotation'],
      titleStyle: _buildTextStyle(json['title_style']),
      accentStyle: _buildTextStyle(json['accent_style']),
      buttonStyle: _buildButtonStyle(json['button_style']),
    );
  }

  static TextStyle _buildTextStyle(Map<String, dynamic> style) {
    return TextStyle(
      color: Color(int.parse(style['color'].replaceFirst('#', '0xff'))),
      fontSize: (style['fontSize'] as num).toDouble(),
      fontWeight: FontWeight.w600,
    );
  }

  static ButtonStyle _buildButtonStyle(Map<String, dynamic> style) {
    return TextButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
```

## 3. Отображение в каруселе

```dart
import 'package:carousel_slider/carousel_slider.dart';

class PromoBannerCarousel extends StatefulWidget {
  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late Future<List<PromoBanner>> banners;

  @override
  void initState() {
    super.initState();
    banners = getActiveBanners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PromoBanner>>(
      future: banners,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return SizedBox.shrink();
        }

        final items = snapshot.data ?? [];
        
        return CarouselSlider.builder(
          options: CarouselOptions(
            height: 180,
            autoPlay: true,
            viewportFraction: 0.95,
          ),
          itemCount: items.length,
          itemBuilder: (context, index, realIndex) {
            return _buildBannerSlide(
              context,
              items[index],
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildBannerSlide(
    BuildContext context,
    PromoBanner banner,
    int index,
  ) {
    _recordDisplay(banner.id);

    return Container(
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: banner.gradientColors
              .map((c) => Color(int.parse(c.replaceFirst('#', '0xff'))))
              .toList(),
          stops: banner.gradientStops ?? [0, 0.5, 1],
          transform: GradientRotation(
            banner.gradientRotation * 3.1415927 / 180,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner.titleMain,
                  style: banner.titleStyle.copyWith(fontSize: 20),
                ),
                Text(
                  banner.titleAccent,
                  style: banner.accentStyle.copyWith(fontSize: 20),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _onBannerClick(context, banner),
                  style: banner.buttonStyle,
                  child: Text(banner.buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recordDisplay(int bannerId) async {
    try {
      await http.post(
        Uri.parse('$API_BASE_URL/api/banners/$bannerId/display'),
      );
    } catch (e) {
      print('Error recording display: $e');
    }
  }

  Future<void> _onBannerClick(
    BuildContext context,
    PromoBanner banner,
  ) async {
    // Записать клик
    try {
      await http.post(
        Uri.parse('$API_BASE_URL/api/banners/${banner.id}/click'),
      );
    } catch (e) {
      print('Error recording click: $e');
    }

    // Навигировать по маршруту если указан
    if (banner.routeName != null) {
      // context.go('/route/${banner.routeName}');
      // или
      // Navigator.pushNamed(context, banner.routeName!);
    }
  }
}
```

## 4. Управление баннерами (администратор)

### Получение всех баннеров

```bash
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:8000/api/admin/banners
```

### Создание баннера

```bash
curl -X POST http://localhost:8000/api/admin/banners \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title_main": "Новое предложение",
    "title_accent": "только сегодня!",
    "description": "Специальное предложение",
    "button_text": "Узнать больше",
    "route_name": "special_offer",
    "gradient_colors": ["#FF5722", "#FFEB3B", "#FFFFFF"],
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
      "foregroundColor": "#FF5722",
      "borderRadius": 12
    },
    "button_color": "#FF5722",
    "order": 5,
    "is_active": true,
    "start_date": "2026-01-04",
    "end_date": "2026-01-05"
  }'
```

### Обновление баннера

```bash
curl -X PUT http://localhost:8000/api/admin/banners/1 \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title_accent": "за 25 минут!",
    "is_active": true
  }'
```

### Удаление баннера

```bash
curl -X DELETE http://localhost:8000/api/admin/banners/1 \
  -H "Authorization: Bearer TOKEN"
```

### Получение аналитики

```bash
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:8000/api/admin/banners/analytics
```

**Ответ**:
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

### Переупорядочение баннеров

```bash
curl -X POST http://localhost:8000/api/admin/banners/reorder \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "orders": [
      {"id": 2, "order": 1},
      {"id": 1, "order": 2},
      {"id": 3, "order": 3},
      {"id": 4, "order": 4}
    ]
  }'
```

### Включение/выключение баннера

```bash
curl -X PATCH http://localhost:8000/api/admin/banners/1/toggle \
  -H "Authorization: Bearer TOKEN"
```

## 5. Примеры настройки стилей

### Минималистский баннер

```json
{
  "title_style": {
    "color": "#FFFFFF",
    "fontSize": 18,
    "fontWeight": "600"
  },
  "accent_style": {
    "color": "#FFFFFF",
    "fontSize": 24,
    "fontWeight": "700"
  },
  "button_style": {
    "backgroundColor": "rgba(255, 255, 255, 0.9)",
    "foregroundColor": "#000000",
    "borderRadius": 8
  }
}
```

### Яркий баннер

```json
{
  "title_style": {
    "color": "#FFFFFF",
    "fontSize": 22,
    "fontWeight": "800",
    "letterSpacing": 1.0
  },
  "accent_style": {
    "color": "#FFFFFF",
    "fontSize": 28,
    "fontWeight": "900",
    "letterSpacing": 1.5
  },
  "button_style": {
    "backgroundColor": "#FFFFFF",
    "foregroundColor": "#000000",
    "borderRadius": 16,
    "borderColor": "#000000",
    "borderWidth": 2
  }
}
```

## 6. Проверка работы

```bash
# Проверить активные баннеры
curl http://localhost:8000/api/banners/active

# Записать просмотр баннера 1
curl -X POST http://localhost:8000/api/banners/1/display

# Записать клик баннера 1
curl -X POST http://localhost:8000/api/banners/1/click
```

## Примечания

- Все JWT токены должны быть добавлены в заголовок `Authorization: Bearer TOKEN`
- Rate limiting активен для предотвращения злоупотреблений
- Используется мягкое удаление (soft delete), удаленные баннеры не отображаются
- CTR (Click-Through Rate) вычисляется как (clicks / displays) * 100
- Баннеры автоматически фильтруются по датам start_date и end_date
