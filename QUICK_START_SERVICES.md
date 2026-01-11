# 🚀 Быстрый старт: Все сервисы PitCare готовы!

## ✅ Что было реализовано

### 📦 Новые модели данных (7 моделей)
1. **Vehicle** - Управление автомобилями пользователя
2. **Order** - Управление заказами услуг  
3. **User** - Профиль пользователя и аутентификация
4. **SubscriptionPlan & UserSubscription** - Система подписок
5. **Bonus & Coupon** - Бонусная система и купоны скидок
6. **Referral & ReferralStats** - Реферальная программа

### 🔌 Новые репозитории (7 сервисов)
1. **VehicleRepository** - CRUD операции с автомобилями
2. **OrderRepository** - Создание и управление заказами
3. **SubscriptionRepository** - Управление подписками
4. **BonusRepository** - Управление бонусами и купонами
5. **ReferralRepository** - Реферальная программа
6. **AuthRepository** - Аутентификация и профиль пользователя
7. **ServiceRepository** (расширенный) - Существующий сервис услуг

### 📡 Riverpod провайдеры (30+)
- **FutureProviders** - для асинхронных операций
- **StateNotifierProviders** - для управления состоянием
- **Family providers** - для параметризованных запросов

---

## 🎯 Быстрые примеры использования

### 1. Получить список всех автомобилей
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pit_care/providers/service_providers.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    
    return vehicles.when(
      data: (list) => ListView(
        children: list.map((v) => ListTile(title: Text(v.displayName))).toList()
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Ошибка: $e'),
    );
  }
}
```

### 2. Создать новый заказ
```dart
final orderRepo = ref.read(orderRepositoryProvider);
final order = await orderRepo.createOrder(
  serviceId: 1,
  vehicleId: 5,
  scheduledDate: DateTime.now().add(Duration(days: 1)),
  notes: "Нужен качественный ремонт",
);
```

### 3. Получить активные бонусы
```dart
final bonuses = ref.watch(activeBonusesProvider);

return bonuses.when(
  data: (list) => Text('Бонусов: ${list.fold<int>(0, (sum, b) => sum + b.amount)}'),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Ошибка: $e'),
);
```

### 4. Проверить подписку
```dart
final subscription = ref.watch(currentSubscriptionProvider);

return subscription.when(
  data: (sub) => sub.isExpired 
    ? Text('Подписка истекла. До возобновления: ${sub.daysRemaining} дней')
    : Text('Подписка активна'),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Ошибка: $e'),
);
```

### 5. Получить реферальный код
```dart
final code = ref.watch(referralCodeProvider);

return code.when(
  data: (referralCode) => Column(
    children: [
      Text('Ваш код: $referralCode'),
      ElevatedButton(
        onPressed: () => Clipboard.setData(ClipboardData(text: referralCode)),
        child: Text('Копировать'),
      ),
    ],
  ),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => Text('Ошибка: $e'),
);
```

### 6. Авторизация
```dart
final authRepo = ref.read(authRepositoryProvider);

final response = await authRepo.login(
  email: 'user@example.com',
  password: 'password123',
);

if (response.success) {
  ref.read(authStateProvider.notifier).setUser(response.user);
  // Перейти на главный экран
} else {
  showError(response.message);
}
```

---

## 📊 API Endpoints (Полный список)

### Services (Услуги)
```
GET  /api/services
GET  /api/services?category={slug}
GET  /api/services/popular
GET  /api/shop/services/deals
GET  /api/shop/services/trending
GET  /api/services/search?q={query}
GET  /api/services/{id}
```

### Vehicles (Автомобили)
```
GET    /api/vehicles
GET    /api/vehicles/{id}
POST   /api/vehicles
PUT    /api/vehicles/{id}
DELETE /api/vehicles/{id}
POST   /api/vehicles/{id}/set-primary
```

### Orders (Заказы)
```
GET    /api/orders
GET    /api/orders?status={status}
GET    /api/orders/{id}
POST   /api/orders
PUT    /api/orders/{id}
POST   /api/orders/{id}/cancel
POST   /api/orders/{id}/review
```

### Subscriptions (Подписки)
```
GET  /api/subscriptions/plans
GET  /api/subscriptions/current
POST /api/subscriptions/subscribe
POST /api/subscriptions/cancel
POST /api/subscriptions/renew
```

### Bonuses (Бонусы)
```
GET  /api/bonuses
GET  /api/bonuses/active
GET  /api/bonuses/stats
GET  /api/bonuses/history
GET  /api/bonuses/coupons
POST /api/bonuses/apply
POST /api/bonuses/use-coupon
```

### Referrals (Рефералы)
```
GET  /api/referrals/code
GET  /api/referrals/code/{code}
GET  /api/referrals
GET  /api/referrals/stats
POST /api/referrals/register
```

### Authentication (Аутентификация)
```
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
PUT  /api/auth/profile
POST /api/auth/change-password
POST /api/auth/logout
POST /api/auth/forgot-password
POST /api/auth/reset-password
```

---

## 📂 Где найти?

| Что | Где |
|-----|-----|
| Моделі данных | `lib/models/*.dart` |
| Сервисы (Dio) | `lib/services/*_repository.dart` |
| Riverpod провайдеры | `lib/providers/service_providers.dart` |
| HTTP клиент | `lib/services/dio_client.dart` |
| Документация | `SERVICES_IMPLEMENTATION_COMPLETE.md` |

---

## 🎓 Архитектура слоев

```
┌────────────────────────────────────────┐
│        Widgets (UI Layer)              │
│    (ConsumerWidget, ConsumerStateful)   │
└────────────┬─────────────────────────┘
             │ читают/пишут state
             ▼
┌────────────────────────────────────────┐
│     Riverpod Providers                 │
│   (FutureProvider, StateNotifier)       │
└────────────┬─────────────────────────┘
             │ используют
             ▼
┌────────────────────────────────────────┐
│    Repositories (Business Logic)        │
│   (XyzRepository классы)                │
└────────────┬─────────────────────────┘
             │ используют
             ▼
┌────────────────────────────────────────┐
│     HTTP Client Layer (Dio)             │
│      (DioClient singleton)              │
└────────────┬─────────────────────────┘
             │ делают запросы
             ▼
        Backend API
    (http://127.0.0.1:8000)
```

---

## 🔧 Обработка ошибок

Каждый сервис выбрасывает свое исключение:

```dart
try {
  final vehicles = await vehicleRepository.fetchVehicles();
} on VehicleException catch (e) {
  print('Vehicle error: ${e.message} (${e.statusCode})');
} on DioException catch (e) {
  print('Network error: ${e.message}');
} catch (e) {
  print('Unknown error: $e');
}
```

---

## 🔐 Аутентификация

Токен автоматически управляется:

```dart
// При входе
final response = await authRepo.login(...);
// Токен сохранен в DioClient автоматически

// При выходе
await authRepo.logout();
// Токен удален из заголовков
```

---

## 📈 Следующие этапы

1. **Интеграция в UI** - Добавить виджеты, которые используют новые провайдеры
2. **Кэширование** - Реализовать локальное хранилище с Hive
3. **Оффлайн режим** - Работа приложения без интернета
4. **Персонализация** - История просмотров и рекомендации
5. **Push уведомления** - Уведомления о статусе заказов

---

## 📞 Поддержка

Если что-то не работает:
1. Проверьте, что API сервер запущен на http://127.0.0.1:8000
2. Проверьте логи Dio (включен LogInterceptor)
3. Убедитесь, что у вас установлены все зависимости: `flutter pub get`
4. Перестройте приложение: `flutter clean && flutter pub get`

---

**✨ Все готово к использованию! Начните разрабатывать! ✨**
