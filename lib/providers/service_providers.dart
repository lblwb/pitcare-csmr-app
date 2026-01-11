import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pit_care/models/bonus.dart';
import 'package:pit_care/models/order.dart';
import 'package:pit_care/models/promo_banner.dart';
import 'package:pit_care/models/referral.dart';
import 'package:pit_care/models/service.dart';
import 'package:pit_care/models/subscription.dart';
import 'package:pit_care/models/user.dart';
import 'package:pit_care/models/vehicle.dart';
import 'package:pit_care/services/auth_repository.dart';
import 'package:pit_care/services/bonus_repository.dart';
import 'package:pit_care/services/dio_client.dart';
import 'package:pit_care/services/order_repository.dart';
import 'package:pit_care/services/promo_banner_repository.dart';
import 'package:pit_care/services/referral_repository.dart';
import 'package:pit_care/services/service_repository.dart';
import 'package:pit_care/services/subscription_repository.dart';
import 'package:pit_care/services/vehicle_repository.dart';

/// Provider for DioClient singleton instance
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Provider for ServiceRepository
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ServiceRepository(dioClient: dioClient);
});

/// Provider for fetching all services
final servicesProvider = FutureProvider<List<Service>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.fetchServices();
});

/// Provider for fetching services by category
final servicesByCategoryProvider = FutureProvider.family<List<Service>, String>(
  (ref, category) async {
    final repository = ref.watch(serviceRepositoryProvider);
    return repository.fetchServicesByCategory(category);
  },
);

/// Provider for fetching popular services
final popularServicesProvider = FutureProvider<List<Service>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.fetchPopularServices();
});

/// Provider for fetching service deals (with discounts)
final serviceDealsProvider = FutureProvider<List<Service>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.fetchServiceDeals();
});

/// Provider for fetching trending services
final trendingServicesProvider = FutureProvider<List<Service>>((ref) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.fetchTrendingServices();
});

/// Provider for searching services
final serviceSearchProvider = FutureProvider.family<List<Service>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) {
    return [];
  }
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.searchServices(query);
});

/// Provider for fetching a single service by ID
final serviceByIdProvider = FutureProvider.family<Service, int>((
  ref,
  id,
) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.fetchServiceById(id);
});

/// State notifier for managing selected service
class SelectedServiceNotifier extends StateNotifier<Service?> {
  SelectedServiceNotifier() : super(null);

  void selectService(Service service) {
    state = service;
  }

  void clearSelection() {
    state = null;
  }
}

/// Provider for selected service state
final selectedServiceProvider =
    StateNotifierProvider<SelectedServiceNotifier, Service?>(
      (ref) => SelectedServiceNotifier(),
    );

/// State notifier for managing favorites/bookmarks
class FavoriteServicesNotifier extends StateNotifier<List<int>> {
  FavoriteServicesNotifier() : super([]);

  void toggleFavorite(int serviceId) {
    if (state.contains(serviceId)) {
      state = state.where((id) => id != serviceId).toList();
    } else {
      state = [...state, serviceId];
    }
  }

  bool isFavorite(int serviceId) => state.contains(serviceId);
}

/// Provider for favorite services state
final favoriteServicesProvider =
    StateNotifierProvider<FavoriteServicesNotifier, List<int>>(
      (ref) => FavoriteServicesNotifier(),
    );

/// Filter state for services
class ServiceFilterState {
  final String? categoryFilter;
  final String searchQuery;
  final bool showDealsOnly;
  final bool showPopularOnly;

  ServiceFilterState({
    this.categoryFilter,
    this.searchQuery = '',
    this.showDealsOnly = false,
    this.showPopularOnly = false,
  });

  ServiceFilterState copyWith({
    String? categoryFilter,
    String? searchQuery,
    bool? showDealsOnly,
    bool? showPopularOnly,
  }) {
    return ServiceFilterState(
      categoryFilter: categoryFilter ?? this.categoryFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      showDealsOnly: showDealsOnly ?? this.showDealsOnly,
      showPopularOnly: showPopularOnly ?? this.showPopularOnly,
    );
  }
}

/// State notifier for service filters
class ServiceFilterNotifier extends StateNotifier<ServiceFilterState> {
  ServiceFilterNotifier() : super(ServiceFilterState());

  void setCategoryFilter(String? category) {
    state = state.copyWith(categoryFilter: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setShowDealsOnly(bool value) {
    state = state.copyWith(showDealsOnly: value);
  }

  void setShowPopularOnly(bool value) {
    state = state.copyWith(showPopularOnly: value);
  }

  void clearFilters() {
    state = ServiceFilterState();
  }
}

/// Provider for service filter state
final serviceFilterProvider =
    StateNotifierProvider<ServiceFilterNotifier, ServiceFilterState>(
      (ref) => ServiceFilterNotifier(),
    );

/// Computed provider that returns filtered services based on current filters
final filteredServicesProvider = FutureProvider<List<Service>>((ref) async {
  final filterState = ref.watch(serviceFilterProvider);

  if (filterState.searchQuery.isNotEmpty) {
    return ref
        .watch(serviceSearchProvider(filterState.searchQuery))
        .when(
          data: (services) => _applyFilters(services, filterState),
          loading: () => [],
          error: (error, stack) => [],
        );
  }

  if (filterState.showDealsOnly) {
    return ref
        .watch(serviceDealsProvider)
        .when(
          data: (services) => _applyFilters(services, filterState),
          loading: () => [],
          error: (error, stack) => [],
        );
  }

  if (filterState.showPopularOnly) {
    return ref
        .watch(popularServicesProvider)
        .when(
          data: (services) => _applyFilters(services, filterState),
          loading: () => [],
          error: (error, stack) => [],
        );
  }

  if (filterState.categoryFilter != null) {
    return ref
        .watch(servicesByCategoryProvider(filterState.categoryFilter!))
        .when(
          data: (services) => _applyFilters(services, filterState),
          loading: () => [],
          error: (error, stack) => [],
        );
  }

  return ref
      .watch(servicesProvider)
      .when(
        data: (services) => _applyFilters(services, filterState),
        loading: () => [],
        error: (error, stack) => [],
      );
});

/// Helper function to apply additional filters
List<Service> _applyFilters(
  List<Service> services,
  ServiceFilterState filterState,
) {
  var filtered = services;

  if (filterState.categoryFilter != null &&
      filterState.categoryFilter!.isNotEmpty) {
    filtered = filtered
        .where(
          (service) =>
              service.category?.toLowerCase() ==
              filterState.categoryFilter!.toLowerCase(),
        )
        .toList();
  }

  return filtered;
}

// ============================================================================
// VEHICLE PROVIDERS
// ============================================================================

/// Provider for VehicleRepository
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return VehicleRepository(dioClient: dioClient);
});

/// Provider for fetching all vehicles
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.fetchVehicles();
});

/// Provider for fetching a single vehicle by ID
final vehicleByIdProvider = FutureProvider.family<Vehicle, int>((
  ref,
  id,
) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.fetchVehicleById(id);
});

// ============================================================================
// ORDER PROVIDERS
// ============================================================================

/// Provider for OrderRepository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return OrderRepository(dioClient: dioClient);
});

/// Provider for fetching all orders
final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.fetchOrders();
});

/// Provider for fetching orders by status
final ordersByStatusProvider = FutureProvider.family<List<Order>, String>((
  ref,
  status,
) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.fetchOrdersByStatus(status);
});

/// Provider for fetching a single order by ID
final orderByIdProvider = FutureProvider.family<Order, int>((ref, id) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.fetchOrderById(id);
});

// ============================================================================
// SUBSCRIPTION PROVIDERS
// ============================================================================

/// Provider for SubscriptionRepository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SubscriptionRepository(dioClient: dioClient);
});

/// Provider for fetching all subscription plans
final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((
  ref,
) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.fetchPlans();
});

/// Provider for fetching current user's subscription
final currentSubscriptionProvider = FutureProvider<UserSubscription>((
  ref,
) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return repository.getCurrentSubscription();
});

// ============================================================================
// BONUS & COUPON PROVIDERS
// ============================================================================

/// Provider for BonusRepository
final bonusRepositoryProvider = Provider<BonusRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BonusRepository(dioClient: dioClient);
});

/// Provider for fetching all user bonuses
final bonusesProvider = FutureProvider<List<Bonus>>((ref) async {
  final repository = ref.watch(bonusRepositoryProvider);
  return repository.fetchBonuses();
});

/// Provider for fetching active bonuses only
final activeBonusesProvider = FutureProvider<List<Bonus>>((ref) async {
  final repository = ref.watch(bonusRepositoryProvider);
  return repository.fetchActiveBonuses();
});

/// Provider for fetching bonus statistics
final bonusStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(bonusRepositoryProvider);
  return repository.getBonusStats();
});

/// Provider for fetching all available coupons
final couponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final repository = ref.watch(bonusRepositoryProvider);
  return repository.fetchCoupons();
});

// ============================================================================
// REFERRAL PROVIDERS
// ============================================================================

/// Provider for ReferralRepository
final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReferralRepository(dioClient: dioClient);
});

/// Provider for getting user's referral code
final referralCodeProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(referralRepositoryProvider);
  return repository.getReferralCode();
});

/// Provider for fetching all referrals
final referralsProvider = FutureProvider<List<Referral>>((ref) async {
  final repository = ref.watch(referralRepositoryProvider);
  return repository.fetchReferrals();
});

/// Provider for fetching referral statistics
final referralStatsProvider = FutureProvider<ReferralStats>((ref) async {
  final repository = ref.watch(referralRepositoryProvider);
  return repository.getReferralStats();
});

// ============================================================================
// AUTH PROVIDERS
// ============================================================================

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient: dioClient);
});

/// Provider for current authenticated user
final currentUserProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

// ============================================================================
// STATE NOTIFIERS
// ============================================================================

/// State notifier for managing auth state
class AuthStateNotifier extends StateNotifier<User?> {
  AuthStateNotifier() : super(null);

  void setUser(User? user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

/// Provider for auth state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, User?>(
  (ref) => AuthStateNotifier(),
);

/// State notifier for managing selected vehicle
class SelectedVehicleNotifier extends StateNotifier<Vehicle?> {
  SelectedVehicleNotifier() : super(null);

  void selectVehicle(Vehicle vehicle) {
    state = vehicle;
  }

  void clearSelection() {
    state = null;
  }
}

/// Provider for selected vehicle state
final selectedVehicleProvider =
    StateNotifierProvider<SelectedVehicleNotifier, Vehicle?>(
      (ref) => SelectedVehicleNotifier(),
    );

/// State notifier for managing selected order
class SelectedOrderNotifier extends StateNotifier<Order?> {
  SelectedOrderNotifier() : super(null);

  void selectOrder(Order order) {
    state = order;
  }

  void clearSelection() {
    state = null;
  }
}

/// Provider for selected order state
final selectedOrderProvider =
    StateNotifierProvider<SelectedOrderNotifier, Order?>(
      (ref) => SelectedOrderNotifier(),
    );

// ============================================================================
// PROMO BANNER PROVIDERS
// ============================================================================

/// Provider for PromoBannerRepository
final promoBannerRepositoryProvider = Provider<PromoBannerRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PromoBannerRepository(dioClient: dioClient);
});

/// Provider for fetching all active promo banners
final activePromoBannersProvider = FutureProvider<List<PromoBannerModel>>((
  ref,
) async {
  final repository = ref.watch(promoBannerRepositoryProvider);
  return repository.fetchActiveBanners();
});

/// Provider for fetching all promo banners (including inactive)
final allPromoBannersProvider = FutureProvider<List<PromoBannerModel>>((
  ref,
) async {
  final repository = ref.watch(promoBannerRepositoryProvider);
  return repository.fetchAllBanners();
});

/// Provider for fetching a single banner by ID
final promoBannerByIdProvider = FutureProvider.family<PromoBannerModel, int>((
  ref,
  id,
) async {
  final repository = ref.watch(promoBannerRepositoryProvider);
  return repository.fetchBannerById(id);
});

/// State notifier for managing displayed banners
class DisplayedBannersNotifier extends StateNotifier<List<int>> {
  DisplayedBannersNotifier() : super([]);

  void markAsDisplayed(int bannerId) {
    if (!state.contains(bannerId)) {
      state = [...state, bannerId];
    }
  }

  bool isDisplayed(int bannerId) => state.contains(bannerId);
}

/// Provider for tracking displayed banners
final displayedBannersProvider =
    StateNotifierProvider<DisplayedBannersNotifier, List<int>>(
      (ref) => DisplayedBannersNotifier(),
    );

/// Computed provider that returns first active banner
final firstPromoBannerProvider = FutureProvider<PromoBannerModel?>((ref) async {
  final banners = await ref.watch(activePromoBannersProvider.future);
  return banners.isNotEmpty ? banners.first : null;
});

/// Computed provider that returns sorted banners (by order)
final sortedPromoBannersProvider = FutureProvider<List<PromoBannerModel>>((
  ref,
) async {
  final banners = await ref.watch(activePromoBannersProvider.future);
  final sorted = [...banners];
  sorted.sort((a, b) => a.order.compareTo(b.order));
  return sorted;
});
