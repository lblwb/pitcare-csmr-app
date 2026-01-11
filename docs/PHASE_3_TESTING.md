# 🧪 ТЕСТИРОВАНИЕ ФАЗЫ 3: Подписки

Этот документ содержит команды для проверки всех эндпоинтов Phase 3.

**Сервер должен работать на http://localhost:8000**

---

## 🔌 Проверка подключения

```bash
# Базовая проверка API
curl -s http://localhost:8000/api/ | jq '.'
# Ожидаемо: {"message":"API work"}
```

---

## 📋 Тестирование Planов (Публичные)

### 1. Получить все планы
```bash
curl -s http://localhost:8000/api/subscriptions/plans | jq '.'
```

**Ожидаемый результат:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Бесплатный",
      "slug": "free",
      "price": "0.00",
      "formatted_price": "0.00 ₽",
      "duration_days": 999999,
      "features": {...},
      "max_vehicles": 1,
      "bonus_multiplier": 1,
      "referral_program": false,
      "is_free": true
    },
    {
      "id": 2,
      "name": "Базовый",
      "slug": "basic",
      "price": "299.99",
      "formatted_price": "299.99 ₽",
      "duration_days": 30,
      "features": {...},
      "max_vehicles": 3,
      "bonus_multiplier": 1.5,
      "referral_program": true,
      "is_free": false
    },
    {
      "id": 3,
      "name": "Премиум",
      "slug": "premium",
      "price": "699.99",
      "formatted_price": "699.99 ₽",
      "duration_days": 30,
      "features": {...},
      "max_vehicles": 10,
      "bonus_multiplier": 2.5,
      "referral_program": true,
      "is_free": false
    }
  ],
  "count": 3
}
```

✅ Это означает БД работает корректно и все 3 плана загружаются!

---

## 🎟️ Тестирование купонов (Публичные)

### 1. Получить все доступные купоны
```bash
curl -s http://localhost:8000/api/bonuses/coupons | jq '.'
```

**Ожидаемо:** Список из 5 встроенных купонов

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "WELCOME2025",
      "description": "Добро пожаловать на платформу",
      "discount_type": "percentage",
      "discount_value": 15,
      "max_uses": 1000,
      "current_uses": 0,
      "max_uses_per_user": 1
    },
    {
      "id": 2,
      "code": "BASIC10",
      "description": "10% скидка для подписчиков Basic и выше",
      "discount_type": "percentage",
      "discount_value": 10
    },
    ...
  ],
  "count": 5
}
```

---

## 🔗 Тестирование рефералов (Публичные)

### 1. Получить информацию по реферальному коду
```bash
# Сначала нужно получить реальный код из БД
# Или используем пустой код для проверки

curl -s http://localhost:8000/api/referrals/code/INVALIDCODE | jq '.'
```

**Ожидаемо:**
- Если код не существует: 404 или error message
- Если существует: информация о рефере

---

## 🔐 ТЕСТИРОВАНИЕ AUTHENTICATED ENDPOINTS

> ⚠️ Для эндпоинтов с `[auth]` нужен JWT токен
> 
> Получить токен можно через:
> - Регистрацию пользователя
> - Логин существующего пользователя
> 
> Затем использовать так:
> ```bash
> curl -s -H "Authorization: Bearer YOUR_TOKEN_HERE" http://localhost:8000/api/...
> ```

---

## 📝 Подписки (Authenticated)

### 1. Получить текущую подписку
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/subscriptions/current | jq '.'
```

### 2. Оформить подписку
```bash
curl -s -X POST -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"plan_id": 2}' \
  http://localhost:8000/api/subscriptions/purchase | jq '.'
```

### 3. Улучшить подписку
```bash
curl -s -X POST -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"plan_id": 3}' \
  http://localhost:8000/api/subscriptions/upgrade | jq '.'
```

### 4. История подписок
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/subscriptions/history | jq '.'
```

### 5. Переключить авто-продление
```bash
curl -s -X PATCH -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"auto_renew": true}' \
  http://localhost:8000/api/subscriptions/auto-renew | jq '.'
```

---

## 💰 Бонусы (Authenticated)

### 1. Получить все бонусы
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/bonuses | jq '.'
```

**Ожидаемо:**
```json
{
  "success": true,
  "data": [...],
  "total": {
    "active": 1500,
    "spent": 200
  }
}
```

### 2. Только активные бонусы
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/bonuses/active | jq '.'
```

### 3. Статистика
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/bonuses/stats | jq '.'
```

**Ожидаемо:**
```json
{
  "success": true,
  "data": {
    "active_balance": 1500,
    "total_earned": 2000,
    "total_spent": 500,
    "by_reason": {
      "service": {...},
      "referral": {...}
    }
  }
}
```

### 4. История
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/bonuses/history | jq '.'
```

### 5. Применить купон
```bash
curl -s -X POST -H "Authorization: Bearer {TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "coupon_code": "WELCOME2025",
    "base_amount": 1000
  }' \
  http://localhost:8000/api/bonuses/use-coupon | jq '.'
```

---

## 🤝 Рефералы (Authenticated)

### 1. Получить/генерировать код
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/referrals/code | jq '.'
```

**Ожидаемо:**
```json
{
  "success": true,
  "data": {
    "referral_code": "aBcDeF1234",
    "referral_link": "https://app.carservice.com/auth/register?ref=aBcDeF1234"
  }
}
```

### 2. Статистика рефералов
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/referrals/stats | jq '.'
```

### 3. Мои рефералы
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/referrals/list | jq '.'
```

### 4. Заработки от рефералов
```bash
curl -s -H "Authorization: Bearer {TOKEN}" \
  http://localhost:8000/api/referrals/earnings | jq '.'
```

---

## ✅ Чек-лист для проверки

- [ ] Все 3 плана загружаются (GET /subscriptions/plans)
- [ ] 5 купонов доступны (GET /bonuses/coupons)
- [ ] Реферальный код можно запросить (GET /referrals/code) [auth]
- [ ] Можно оформить подписку (POST /subscriptions/purchase) [auth]
- [ ] Можно улучшить подписку (POST /subscriptions/upgrade) [auth]
- [ ] Бонусы работают (GET /bonuses) [auth]
- [ ] Купон применяется (POST /bonuses/use-coupon) [auth]
- [ ] История отслеживается (GET /subscriptions/history) [auth]

---

## 🐛 Если что-то не работает

### Проверить логи сервера
```bash
tail -f /tmp/server.log
```

### Перезапустить сервер
```bash
pkill -f "php artisan serve"
cd "/home/bob/Рабочий стол/BackendProjects/carServiceBack"
php artisan serve --host=0.0.0.0 --port=8000 > /tmp/server.log 2>&1 &
```

### Пересоздать БД
```bash
cd "/home/bob/Рабочий стол/BackendProjects/carServiceBack"
php artisan migrate:fresh --seed
```

---

## 📊 Дополнительные команды

### Проверить статус БД
```bash
cd "/home/bob/Рабочий стол/BackendProjects/carServiceBack"
php artisan tinker
>>> DB::table('subscription_plans')->count()
>>> DB::table('discount_coupons')->count()
```

### Просмотр всех маршрутов
```bash
php artisan route:list --path=api | grep subscription
php artisan route:list --path=api | grep bonus
php artisan route:list --path=api | grep referral
```

---

*Документация тестирования - Phase 3*
*Последнее обновление: 2024-01-04*
