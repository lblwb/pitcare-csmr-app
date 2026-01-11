// Services Implementation Guide
// 
// This file documents the implementation of services, repositories, and providers
// using Dio and Riverpod for the PitCare application.

// ============================================================================
// 1. SERVICE MODEL
// ============================================================================
// Location: lib/models/service.dart
// 
// The Service model represents a single service from the API catalog.
// Key features:
//   - Immutable using @immutable annotation
//   - Handles null values for category, iconUrl, imageUrl
//   - Computed properties: discountPercentage, displayPrice, discountText
//   - Factory constructor for JSON deserialization
//
// Example usage:
// 
// final service = Service.fromJson({
//   "id": 6,
//   "name": "Техническое обслуживание 1 (ТО-1)",
//   "base_price": 3500,
//   "current_price": 3150,
//   "has_discount": true,
//   ...
// });
//
// print(service.discountPercentage); // Output: 10
// print(service.displayPrice); // Output: "3150 ₽"
// print(service.discountText); // Output: "-10%"

// ============================================================================
// 2. DIO HTTP CLIENT
// ============================================================================
// Location: lib/services/dio_client.dart
//
// Singleton class managing Dio HTTP client with:
//   - Base URL configuration from .env file
//   - Request/response timeouts (30 seconds)
//   - Logging interceptor for debugging
//   - Error handling interceptor
//   - Methods for auth token management
//
// Example usage:
//
// final dioClient = DioClient();
// dioClient.setAuthToken('your_token_here');
// dioClient.setBaseUrl('http://new-url.com');

// ============================================================================
// 3. SERVICE REPOSITORY
// ============================================================================
// Location: lib/services/service_repository.dart
//
// Repository class handling all API calls for services.
// Methods available:
//   - fetchServices() - Get all services
//   - fetchServicesByCategory(String categorySlug)
//   - fetchPopularServices()
//   - fetchServiceDeals() - Services with discounts
//   - fetchTrendingServices()
//   - searchServices(String query)
//   - fetchServiceById(int id)
//
// All methods throw ServiceException on error with detailed error messages.
//
// Example usage:
//
// final repository = ServiceRepository();
// try {
//   final services = await repository.fetchServices();
//   final deals = await repository.fetchServiceDeals();
// } on ServiceException catch (e) {
//   print('Error: ${e.message}');
// }

// ============================================================================
// 4. RIVERPOD PROVIDERS
// ============================================================================
// Location: lib/providers/service_providers.dart
//
// FutureProviders for fetching data:
//   - servicesProvider - All services
//   - servicesByCategoryProvider(String) - By category
//   - popularServicesProvider - Popular services
//   - serviceDealsProvider - Services with discounts
//   - trendingServicesProvider - Trending services
//   - serviceSearchProvider(String) - Search results
//   - serviceByIdProvider(int) - Single service by ID
//
// StateNotifierProviders for managing state:
//   - selectedServiceProvider - Currently selected service
//   - favoriteServicesProvider - List of favorite service IDs
//   - serviceFilterProvider - Current filter state
//   - filteredServicesProvider - Computed filtered services
//
// Example usage in widgets:
//
// class MyWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch provider
//     final servicesAsync = ref.watch(servicesProvider);
//     
//     return servicesAsync.when(
//       data: (services) => ListView(
//         children: services.map((s) => Text(s.name)).toList(),
//       ),
//       loading: () => Center(child: CircularProgressIndicator()),
//       error: (err, stack) => Text('Error: $err'),
//     );
//   }
// }

// ============================================================================
// 5. HOME SCREEN INTEGRATION
// ============================================================================
// Location: lib/screens/home/home_screen.dart
//
// Updated to use ConsumerWidget with WidgetRef to access providers.
// The services grid now:
//   - Fetches real services from API
//   - Shows loading state with spinner
//   - Displays error state with retry button
//   - Shows discount badges on services with active discounts
//   - Takes only first 4 services for grid display
//
// Key changes:
//   - Changed from StatelessWidget to ConsumerWidget
//   - _buildServicesBlock now receives WidgetRef parameter
//   - _buildServicesGrid shows loading/error/data states
//   - _buildServiceItem enhanced with discount badge support

// ============================================================================
// 6. API ENDPOINTS
// ============================================================================
// Base URL: http://127.0.0.1:8000/api
//
// Endpoints implemented:
//
// GET /services
//   Response: { success: true, data: Service[], pagination: {...} }
//
// GET /services/categories/{slug}/services
//   Query params: ?category=category_slug
//
// GET /services/popular
//   Response: { success: true, data: Service[] }
//
// GET /shop/services/deals
//   Response: { success: true, data: Service[] }
//
// GET /shop/services/trending
//   Response: { success: true, data: Service[] }
//
// GET /services/search
//   Query params: ?q=search_query
//   Response: { success: true, data: Service[] }
//
// GET /services/{id}
//   Response: { data: Service }

// ============================================================================
// 7. ERROR HANDLING
// ============================================================================
// The implementation includes comprehensive error handling:
//
// ServiceException types:
//   - Connection timeout
//   - Request timeout
//   - Response timeout
//   - Bad response (server error)
//   - Request cancelled
//   - Certificate error
//   - Connection error
//
// UI displays:
//   - Loading spinners during requests
//   - Error messages with user-friendly text
//   - Retry buttons to refresh data

// ============================================================================
// 8. ENVIRONMENT CONFIGURATION
// ============================================================================
// Location: .env
//
// Required variables:
//   API_BASE_URL=http://127.0.0.1:8000
//
// The DioClient automatically loads these via flutter_dotenv

// ============================================================================
// 9. DEPENDENCIES USED
// ============================================================================
// - flutter_riverpod: ^2.5.1  - State management
// - dio: ^5.4.3+1             - HTTP client
// - flutter_dotenv: ^5.1.0    - Environment variables
// - flutter_svg: ^2.2.0       - SVG rendering (for icons)

// ============================================================================
// 10. USAGE EXAMPLES
// ============================================================================

// Example 1: Fetch and display all services
// -----------
// class ServiceListScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final servicesAsync = ref.watch(servicesProvider);
//     
//     return servicesAsync.when(
//       data: (services) => ListView.builder(
//         itemCount: services.length,
//         itemBuilder: (ctx, idx) {
//           final service = services[idx];
//           return ListTile(
//             title: Text(service.name),
//             subtitle: Text('${service.displayPrice} ${service.discountText ?? ''}'),
//           );
//         },
//       ),
//       loading: () => Center(child: CircularProgressIndicator()),
//       error: (err, stack) => Center(child: Text('Error: $err')),
//     );
//   }
// }

// Example 2: Search services
// -----------
// class SearchWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return TextField(
//       onChanged: (query) {
//         ref.read(serviceFilterProvider.notifier).setSearchQuery(query);
//       },
//     );
//   }
// }

// Example 3: Filter services
// -----------
// class FilterWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Row(
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             ref.read(serviceFilterProvider.notifier).setShowDealsOnly(true);
//           },
//           child: Text('Show Deals'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             ref.read(serviceFilterProvider.notifier).setCategoryFilter('maintenance');
//           },
//           child: Text('Filter by Category'),
//         ),
//       ],
//     );
//   }
// }

// Example 4: Favorite services
// -----------
// class ServiceCard extends ConsumerWidget {
//   final Service service;
//   
//   ServiceCard({required this.service});
//   
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isFavorite = ref.watch(favoriteServicesProvider).contains(service.id);
//     
//     return Card(
//       child: Column(
//         children: [
//           Text(service.name),
//           IconButton(
//             icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
//             onPressed: () {
//               ref.read(favoriteServicesProvider.notifier).toggleFavorite(service.id);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// ============================================================================
// 11. NEXT STEPS
// ============================================================================
// 
// Phase 2 Enhancements:
//   - [ ] Implement service details screen
//   - [ ] Add service booking/order creation
//   - [ ] Cache services for offline viewing
//   - [ ] Implement service ratings and reviews
//   - [ ] Add service filtering by price range
//   - [ ] Implement sort options (popular, price, rating)
//
// Phase 3 Enhancements:
//   - [ ] Add service wishlist persistence
//   - [ ] Implement notification on new services
//   - [ ] Add service comparison feature
//   - [ ] Integrate with user subscription tiers
//   - [ ] Add service recommendations based on user history
