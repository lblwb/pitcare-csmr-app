# 🚗 PitCare Services Implementation - Dio + Riverpod

## 📋 Overview

This document describes the complete implementation of the services system for the PitCare customer app using Dio for HTTP requests and Riverpod for state management.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Widgets                              │
│              (home_screen.dart - ConsumerWidget)             │
└─────────────┬───────────────────────────────────────────────┘
              │
              │ watches
              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Riverpod Providers                          │
│   (service_providers.dart - FutureProviders & State)         │
└─────────────┬───────────────────────────────────────────────┘
              │
              │ uses
              ▼
┌─────────────────────────────────────────────────────────────┐
│                Service Repository                           │
│      (service_repository.dart - Business Logic)             │
└─────────────┬───────────────────────────────────────────────┘
              │
              │ uses
              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Dio HTTP Client                            │
│         (dio_client.dart - Network Layer)                   │
└─────────────┬───────────────────────────────────────────────┘
              │
              │ HTTP
              ▼
     Backend API Server
   (http://127.0.0.1:8000)
```

## 📁 File Structure

```
lib/
├── models/
│   └── service.dart              # Service model & ServiceResponse
├── services/
│   ├── dio_client.dart           # HTTP client singleton
│   └── service_repository.dart   # API call logic
├── providers/
│   └── service_providers.dart    # Riverpod providers
└── screens/
    └── home/
        └── home_screen.dart      # Home screen with services grid
```

## 🔧 Implementation Details

### 1. Service Model (`lib/models/service.dart`)

Immutable model representing a service with computed properties for displaying prices and discounts.

**Key Features:**
- Handles nullable fields (category, iconUrl, imageUrl)
- Computed properties: `discountPercentage`, `displayPrice`, `discountText`
- JSON serialization with factory constructor

**Response Structure:**
```json
{
  "success": true,
  "data": [
    {
      "id": 6,
      "name": "Техническое обслуживание 1 (ТО-1)",
      "slug": "to-1-maintenance",
      "description": "Первое плановое обслуживание",
      "category": "maintenance",
      "base_price": 3500,
      "current_price": 3150,
      "has_discount": true,
      "estimated_duration_minutes": 60,
      "icon_url": "https://via.placeholder.com/50?text=TO1",
      "image_url": "https://via.placeholder.com/300?text=Maintenance",
      "difficulty_level": "easy",
      "popularity_score": 95,
      "orders_count": 0
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 15,
    "total": 10,
    "last_page": 1
  }
}
```

### 2. Dio HTTP Client (`lib/services/dio_client.dart`)

Singleton HTTP client with:
- Base URL from `.env` file
- Request/response timeouts (30 seconds)
- Logging interceptor for debugging
- Error interceptor for centralized error handling
- Methods for auth token management

**Initialization:**
```dart
// Automatically loads API_BASE_URL from .env
final dioClient = DioClient();

// Optional: Set auth token
dioClient.setAuthToken('your_token');
```

### 3. Service Repository (`lib/services/service_repository.dart`)

Business logic layer handling all API interactions.

**Available Methods:**
- `fetchServices()` - All services
- `fetchServicesByCategory(String categorySlug)` - Filtered by category
- `fetchPopularServices()` - Top services
- `fetchServiceDeals()` - Services with discounts
- `fetchTrendingServices()` - Trending services
- `searchServices(String query)` - Search functionality
- `fetchServiceById(int id)` - Single service details

**Error Handling:**
All methods throw `ServiceException` with:
- `message` - User-friendly error text
- `statusCode` - HTTP status code
- `originalError` - Original DioException

### 4. Riverpod Providers (`lib/providers/service_providers.dart`)

#### FutureProviders
```dart
// Fetch all services
ref.watch(servicesProvider)

// By category
ref.watch(servicesByCategoryProvider('maintenance'))

// Popular services
ref.watch(popularServicesProvider)

// Services with discounts
ref.watch(serviceDealsProvider)

// Trending
ref.watch(trendingServicesProvider)

// Search
ref.watch(serviceSearchProvider('диагностика'))

// Single service
ref.watch(serviceByIdProvider(6))
```

#### StateNotifierProviders
```dart
// Selected service
ref.watch(selectedServiceProvider)
ref.read(selectedServiceProvider.notifier).selectService(service)

// Favorites
ref.watch(favoriteServicesProvider)
ref.read(favoriteServicesProvider.notifier).toggleFavorite(serviceId)

// Filters
ref.watch(serviceFilterProvider)
ref.read(serviceFilterProvider.notifier).setShowDealsOnly(true)
```

### 5. Home Screen Integration (`lib/screens/home/home_screen.dart`)

Updated to `ConsumerWidget` for Riverpod integration.

**Features:**
- Real-time service fetching
- Loading state with spinner
- Error state with retry button
- Discount badges on services
- First 4 services displayed in grid

**State Handling:**
```dart
final servicesAsync = ref.watch(servicesProvider);

servicesAsync.when(
  data: (services) => _buildGrid(services),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(onRetry: () => ref.refresh(servicesProvider)),
)
```

## 🌐 API Endpoints

All endpoints are prefixed with `/api` and base URL from `.env` (default: `http://127.0.0.1:8000`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/services` | All services with pagination |
| GET | `/services?category={slug}` | Filter by category |
| GET | `/services/{id}` | Single service details |
| GET | `/services/popular` | Top 10 popular services |
| GET | `/services/search?q={query}` | Search services |
| GET | `/shop/services/deals` | Services with discounts |
| GET | `/shop/services/trending` | Trending services |

## ⚙️ Configuration

### Environment Variables (`.env`)
```env
API_BASE_URL=http://127.0.0.1:8000
APP_ENV=development
ENABLE_ANALYTICS=true
ENABLE_LOGGING=true
```

## 📦 Dependencies

- `flutter_riverpod: ^2.5.1` - State management
- `dio: ^5.4.3+1` - HTTP client
- `flutter_dotenv: ^5.1.0` - Environment configuration
- `flutter_svg: ^2.2.0` - SVG icon rendering

## 💻 Usage Examples

### Example 1: Display All Services
```dart
class ServiceListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    
    return servicesAsync.when(
      data: (services) => ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ListTile(
            title: Text(service.name),
            subtitle: Text(service.displayPrice),
            trailing: service.hasDiscount 
              ? Text(service.discountText!)
              : null,
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
```

### Example 2: Search with Filter
```dart
class ServiceSearchWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TextField(
          onChanged: (query) {
            ref.read(serviceFilterProvider.notifier).setSearchQuery(query);
          },
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(serviceFilterProvider.notifier).setShowDealsOnly(true);
          },
          child: Text('Show Deals Only'),
        ),
        Consumer(
          builder: (context, ref, child) {
            final filtered = ref.watch(filteredServicesProvider);
            return filtered.when(
              data: (services) => Text('${services.length} services found'),
              loading: () => CircularProgressIndicator(),
              error: (e, st) => Text('Error'),
            );
          },
        ),
      ],
    );
  }
}
```

### Example 3: Service with Favorites
```dart
class ServiceCard extends ConsumerWidget {
  final Service service;

  ServiceCard({required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteServicesProvider).contains(service.id);

    return Card(
      child: Stack(
        children: [
          Column(
            children: [
              Text(service.name),
              Text(service.displayPrice),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                ref.read(favoriteServicesProvider.notifier)
                    .toggleFavorite(service.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🚀 Features Implemented

### Phase 1 - Core Services
- ✅ Service model with all fields
- ✅ Dio HTTP client with interceptors
- ✅ Service repository with 7 API methods
- ✅ Riverpod providers for all endpoints
- ✅ Error handling and logging
- ✅ Home screen integration
- ✅ Loading and error UI states
- ✅ Discount badge display

### Phase 2 - Future Enhancements
- [ ] Service detail screen
- [ ] Order/booking creation
- [ ] Offline caching with Hive
- [ ] Service ratings and reviews
- [ ] Price range filtering
- [ ] Sort options (popular, price, rating)
- [ ] Service comparison
- [ ] Wishlist persistence

### Phase 3 - Advanced Features
- [ ] Personalized recommendations
- [ ] Service notifications
- [ ] Integration with subscription tiers
- [ ] Analytics tracking
- [ ] Service history

## 🧪 Testing

To test the implementation:

1. **Start Backend:**
   ```bash
   cd your-backend-dir
   php artisan serve  # Starts on http://127.0.0.1:8000
   ```

2. **Run App:**
   ```bash
   flutter pub get
   flutter run
   ```

3. **View Home Screen:**
   - Services grid should load with real data
   - Discount badges visible on discounted items
   - Loading spinner shows during fetch
   - Error message displays if request fails

## 🐛 Debugging

### Enable Logging
The Dio client includes a logging interceptor that prints:
- Request URL and method
- Request headers and body
- Response status and body
- Errors and stack traces

Check the console output in VS Code's DEBUG CONSOLE.

### Common Issues

**Issue:** Services don't load
- Check `.env` file has correct API_BASE_URL
- Verify backend is running on that URL
- Check network connectivity
- View logs for detailed error messages

**Issue:** Null category error
- Category field is now nullable (`String?`)
- Handles both null and string values
- Backend sometimes returns null for category

**Issue:** Icons not showing
- SVG paths must be correct
- Use placeholder SVG for missing icons
- Check `icon_url` is not null

## 📚 References

- [Riverpod Documentation](https://riverpod.dev)
- [Dio Documentation](https://github.com/flutterchina/dio)
- [Flutter Async Patterns](https://flutter.dev/docs/cookbook/networking)

## 👨‍💻 Author Notes

This implementation follows Flutter best practices:
- Separation of concerns (Model-Repository-Provider-UI)
- Immutable data models
- Proper error handling
- Responsive loading/error states
- Testable architecture

The use of Riverpod providers makes the code:
- Easy to test (providers can be mocked)
- Reusable across the app
- Easily refactorable
- Performant with caching

---

**Last Updated:** 4 января 2026 г.  
**Status:** ✅ Production Ready
