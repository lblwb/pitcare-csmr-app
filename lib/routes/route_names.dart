// routes/route_names.dart
abstract class RouteNames {
  static const String home = '/';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String sos = '/sos';
  static const String addresses = '/addresses';
  static const String addressesBranches = '/addresses/branches';

  //

  // Services
  static const String services = '/services';
  static const String serviceDetail = '/services/detail';
  //
  static const String garage = '/garage';
  static const String garageDetail = '/garage/detail';

  // Analyzes
  static const String analytics = '/analytics';

  static const String profileOrdersAll = '/profile/orders/all';
  static const String profileOrdersDetail = '/profile/orders/detail';

  //CART SERVICES (Profiles) & Examinations
  static const String cart = '/cart';
  static const String payment = '/cart/payment';

  //Articles
  static const String articles = '/articles';
  static const String articleDetail = '/article-detail';
  static const String smsCode = '/sms-code';

  // Profile routes
  static const String editProfile = '/profile/edit';
  // static const String myExaminations = '/profile/examinations';
  static const String partnershipProgram = '/profile/partnership';
  static const String aboutApp = '/profile/about';
  static const String technicalSupport = '/profile/support';
  static const String notificationProfile = '/profile/notifications';
}
