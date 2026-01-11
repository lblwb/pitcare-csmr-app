import 'dart:async';
// import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:latlong2/latlong.dart';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';
// import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

enum StatusDisplayTypes {
  selectAddress,
  // searchResults,
  // branchSelection,
  selectionServices,
  formServiceDetails,
  trackingServiceProgress,
  serviceCompleted,
  feedback,
}

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key, this.routerState, this.fromServiceDetails});

  final GoRouterState? routerState;
  final bool? fromServiceDetails;

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  LatLng _initialCenter = const LatLng(
    55.755826,
    37.617634,
  ); // Москва по умолчанию
  LatLng? _currentLocation;
  bool _isLocating = false;
  Timer? _trackingTimer;
  bool _followUser =
      true; // автоматическое центрирование камеры за пользователем
  // Центр для плашки подтверждения адреса (без раннего доступа к MapController)
  LatLng _bannerCenter = const LatLng(55.755826, 37.617634);
  // Обратное геокодирование адреса
  Timer? _geocodeDebounce;
  String? _bannerAddress;
  int _geocodeRetryCount = 0;
  static const int _maxGeocodeRetries = 3;
  static const String _defaultAddressRU = 'Москва, Центральная часть';

  late StatusDisplayTypes statusDisplayType = StatusDisplayTypes.selectAddress;

  Color _primaryElementColor = const Color(0xFF000000);

  GoRouterState? get routerState => widget.routerState;

  @override
  void initState() {
    super.initState();

    if (widget.fromServiceDetails == true) {
      setState(() {
        statusDisplayType = StatusDisplayTypes.formServiceDetails;
      });
    }

    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = latLng;
        _initialCenter = latLng;
        _bannerCenter = latLng;
        _isLocating = false;
      });

      // Перемещаем камеру к текущей геопозиции
      _mapController.move(latLng, 16.0);

      // Запускаем периодическое обновление геопозиции (раз в секунду)
      _startPositionPolling();
      // Разрешаем адрес для текущего центра
      _resolveBannerAddress();
    } catch (e) {
      debugPrint('Ошибка геолокации: $e');
      setState(() => _isLocating = false);
    }
  }

  void _centerOnMyLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16.0);
    } else {
      _initLocation();
    }
  }

  void _searchHere(BuildContext context) {
    final center = _mapController.camera.center;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Поиск по точке: ${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)}',
        ),
      ),
    );
    debugPrint('Search at: ${center.latitude}, ${center.longitude}');
    // Здесь можно вызвать реальный поиск/запрос API с координатами центра
    // context.push(RouteNames.addressesBranches); // пример навигации, если потребуется
  }

  void _formSelServices(BuildContext context) {
    setState(() {
      statusDisplayType = StatusDisplayTypes.formServiceDetails;
    });
  }

  void _startPositionPolling() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        final latLng = LatLng(position.latitude, position.longitude);
        if (!mounted) return;
        setState(() {
          _currentLocation = latLng;
        });
        if (_followUser) {
          _mapController.move(latLng, _mapController.camera.zoom);
        }
      } catch (e) {
        debugPrint('Polling geolocation error: $e');
      }
    });
  }

  void _confirmCurrentCenter(BuildContext context) {
    setState(() {
      statusDisplayType = StatusDisplayTypes.selectionServices;
    });

    debugPrint(
      'Confirmed address at: ${_bannerCenter.latitude}, ${_bannerCenter.longitude}',
    );

    debugPrint('statusScreenType: $statusDisplayType');

    final center = _bannerCenter;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Адрес подтверждён: ${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)}',
        ),
      ),
    );
    // TODO: отправить выбранный адрес на сервер или сохранить в состоянии приложения
  }

  // Проверка, содержит ли строка кириллицу (для определения русской локализации)
  bool _hasCyrillic(String s) {
    return RegExp(r'[А-Яа-яЁё]').hasMatch(s);
  }

  // Извлечение названия улицы из полного адреса
  String _extractStreetName(String address) {
    if (address.isEmpty) return address;

    // Разделяем адрес по запятым и берём первую значимую часть
    final parts = address.split(',').map((e) => e.trim()).toList();

    // Фильтруем пустые части и координаты
    final filtered = parts
        .where((part) => part.isNotEmpty && !RegExp(r'^[\d.]+$').hasMatch(part))
        .toList();

    if (filtered.isNotEmpty) {
      // Возвращаем первую часть адреса (обычно улица)
      return filtered.first;
    }

    return address;
  }

  Future<void> _resolveBannerAddress() async {
    final lat = _bannerCenter.latitude;
    final lon = _bannerCenter.longitude;

    try {
      if (kIsWeb) {
        // Используем Nominatim для веба (без ключа)
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&zoom=18&addressdetails=1&accept-language=ru&namedetails=1',
        );

        debugPrint('Nominatim URI: $uri');

        final resp = await http
            .get(uri, headers: {'Accept-Language': 'ru-RU'})
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () =>
                  throw TimeoutException('Nominatim request timeout'),
            );

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final displayName = data['display_name'] as String?;
          debugPrint('Nominatim data: ${data.toString()}');

          if (displayName != null && displayName.isNotEmpty) {
            setState(() {
              _bannerAddress = displayName;
              _geocodeRetryCount = 0; // Сброс счётчика при успехе
            });
          } else {
            _handleAddressResolveFailed();
          }
        } else {
          debugPrint('Nominatim error: ${resp.statusCode}');
          _handleAddressResolveFailed();
        }
      } else {
        // Нативное обратное геокодирование с фоллбеком на Nominatim (RU)
        final placemarks = await geocoding.placemarkFromCoordinates(
          lat,
          lon,
          localeIdentifier: 'ru_RU',
        );
        debugPrint('Placemarks: ${jsonEncode(placemarks)}');

        String? nativeAddress;
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts =
              [p.street, p.subLocality, p.locality, p.administrativeArea]
                  .where((e) => e != null && e!.trim().isNotEmpty)
                  .map((e) => e!.trim())
                  .toList();
          nativeAddress = parts.isNotEmpty ? parts.join(', ') : null;
        }

        // Если нативный адрес содержит кириллицу, используем его
        if (nativeAddress != null && _hasCyrillic(nativeAddress)) {
          setState(() {
            _bannerAddress = nativeAddress!;
            _geocodeRetryCount = 0;
          });
        } else {
          // Если нативный адрес пустой или не на русском, запрашиваем у Nominatim
          await _fetchFromNominatim(lat, lon, nativeAddress);
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      _handleAddressResolveFailed();
    }
  }

  Future<void> _fetchFromNominatim(
    double lat,
    double lon,
    String? fallbackAddress,
  ) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&zoom=18&addressdetails=1&accept-language=ru&namedetails=1',
      );

      debugPrint('Nominatim fallback URI: $uri');

      final resp = await http
          .get(uri, headers: {'Accept-Language': 'ru-RU'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                throw TimeoutException('Nominatim request timeout'),
          );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final displayName = data['display_name'] as String?;

        if (displayName != null && displayName.isNotEmpty) {
          setState(() {
            _bannerAddress = displayName;
            _geocodeRetryCount = 0;
          });
        } else {
          setState(() {
            _bannerAddress = fallbackAddress ?? _defaultAddressRU;
          });
          _handleAddressResolveFailed();
        }
      } else {
        debugPrint('Nominatim fallback error: ${resp.statusCode}');
        setState(() {
          _bannerAddress = fallbackAddress ?? _defaultAddressRU;
        });
        _handleAddressResolveFailed();
      }
    } catch (e) {
      debugPrint('Nominatim fallback error: $e');
      setState(() {
        _bannerAddress = fallbackAddress ?? _defaultAddressRU;
      });
      _handleAddressResolveFailed();
    }
  }

  void _handleAddressResolveFailed() {
    _geocodeRetryCount++;
    debugPrint('Address resolve failed. Retry count: $_geocodeRetryCount');

    // Если ещё есть попытки, перезапускаем процесс
    if (_geocodeRetryCount < _maxGeocodeRetries) {
      debugPrint('Retrying address resolution...');
      _geocodeDebounce?.cancel();
      _geocodeDebounce = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          _resolveBannerAddress();
        }
      });
    } else {
      // Максимум попыток достигнут, устанавливаем адрес по умолчанию
      debugPrint('Max retries reached. Setting default address.');
      setState(() {
        if (_bannerAddress == null || _bannerAddress!.isEmpty) {
          _bannerAddress = _defaultAddressRU;
        }
        _geocodeRetryCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _geocodeDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   backgroundBar: Colors.transparent,
      //   title: 'Карта',
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () => context.pop(),
      //   ),
      // ),
      body: Stack(
        children: [
          _buildRenderMapView(context),
          _buildMapHeaderBar(context),
          _buildMapBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildMapHeaderBar(BuildContext ctx) {
    // return const Positioned(
    //   // top: MediaQuery.of(ctx).padding.top + 8,
    //   top: 12,
    //   left: 16,
    //   right: 16,
    //   child: Expanded(child: SizedBox(height: 10)),
    // );

    return Positioned(
      child: Container(
        margin: const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
        height: 60,
        child: CustomAppBar(
          title: 'На главную',
          centerTitle: false,
          showBackButton: true,
          backButtonAction: () {
            // Сначала проверяем статус отображения
            switch (statusDisplayType) {
              case StatusDisplayTypes.selectAddress:
                {
                  // Если на экране выбора адреса, выходим назад
                  Navigator.of(ctx).pop();
                }
                break;

              case StatusDisplayTypes.selectionServices:
                {
                  // Возвращаемся к выбору адреса
                  setState(() {
                    statusDisplayType = StatusDisplayTypes.selectAddress;
                  });
                }
                break;

              case StatusDisplayTypes.formServiceDetails:
                {
                  // Возвращаемся к выбору услуг
                  setState(() {
                    statusDisplayType = StatusDisplayTypes.selectionServices;
                  });
                }
                break;

              case StatusDisplayTypes.trackingServiceProgress:
                {
                  // Возвращаемся к форме деталей услуги
                  setState(() {
                    statusDisplayType = StatusDisplayTypes.formServiceDetails;
                  });
                }
                break;

              case StatusDisplayTypes.serviceCompleted:
                {
                  // Возвращаемся к отслеживанию прогресса услуги
                  setState(() {
                    statusDisplayType =
                        StatusDisplayTypes.trackingServiceProgress;
                  });
                }
                break;

              case StatusDisplayTypes.feedback:
                {
                  // Возвращаемся к завершённой услуге
                  setState(() {
                    statusDisplayType = StatusDisplayTypes.serviceCompleted;
                  });
                }
                break;
            }
          },

          leading: const Row(children: []),
          colorElements: _primaryElementColor,
          backgroundBar: Colors.transparent,
          actions: [
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () => {},
              style: ElevatedButton.styleFrom(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 8,
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(38, 38),
                fixedSize: const Size(38, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: _primaryElementColor,
                size: 24,
              ),
            ),
          ],
          borderBottomRadius: const BorderRadius.all(Radius.circular(0)),
        ),
      ),
    );
  }

  List<Widget> _buildMapSelServicesBar(BuildContext ctx) {
    return <Widget>[
      Positioned(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(ctx).size.height * 0.12,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                backgroundColor: const Color(0xFF7949FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: () => {
                // _formSelServices(ctx),
                setState(() {
                  statusDisplayType = StatusDisplayTypes.formServiceDetails;
                }),
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // children: [Text('Сломался — найти помощь'), SizedBox(width: 8)],
                children: [
                  Text('Сломался — найти помощь'),
                  Icon(Icons.car_crash_rounded),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                backgroundColor: const Color(0xFF27282A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              onPressed: () => {
                setState(() {
                  statusDisplayType = StatusDisplayTypes.formServiceDetails;
                }),
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Обслуживание авто'), Icon(Icons.build_circle)],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildMapSelAdressBar(BuildContext ctx) {
    return <Widget>[
      // Кнопка «Я сломался»
      Positioned(
        left: 16,
        right: 16,
        // width: MediaQuery.of(ctx).size.width - 32,
        bottom: MediaQuery.of(ctx).size.height * 0.12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 18,
                ),
                backgroundColor: const Color(0xFF27282A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Я сломался'),
              onPressed: () => _searchHere(ctx),
            ),
          ],
        ),
      ),

      // Плашка подтверждения адреса над кнопкой «Я сломался»
      Positioned(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(ctx).size.height * 0.20,
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7949FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Container(
                  // height: 80,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  margin: const EdgeInsets.only(top: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _extractStreetName(
                          _bannerAddress ?? 'Загрузка адреса...',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF000000),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // if (_bannerAddress != null && _bannerAddress!.isNotEmpty)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 4),
                      //     child: Text(
                      //       _bannerAddress!,
                      //       style: const TextStyle(
                      //         fontFamily: 'Manrope',
                      //         fontWeight: FontWeight.w400,
                      //         fontSize: 12,
                      //         color: Color(0xFF888888),
                      //       ),
                      //       maxLines: 1,
                      //       overflow: TextOverflow.ellipsis,
                      //     ),
                      //   ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _confirmCurrentCenter(ctx),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          backgroundColor: const Color(0xFF7949FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Подтвердить адрес'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildMapSelFormServiceDetailsBar(BuildContext ctx) {
    return <Widget>[
      Positioned(
        left: 16,
        right: 16,
        top: MediaQuery.of(ctx).size.height * 0.12,
        bottom: MediaQuery.of(ctx).size.height * 0.12,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                const Text(
                  'Расскажите о вашей проблеме',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF000000),
                  ),
                ),
                const Text(
                  'После ознакомления с вашей проблемой, подберем подходящее решение и специалиста.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF000000),
                  ),
                ),

                // Поле для описания проблемы для ИИ с изображениями
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      const Text(
                        'Опишите проблему',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Расскажите, что произошло с вашим автомобилем...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontFamily: 'Manrope',
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF7949FF),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const Text(
                        'Добавьте фото проблемы',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF000000),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          //spacing: 12,
                          children: [
                            // Кнопка добавления фото
                            GestureDetector(
                              onTap: () {
                                // Логика добавления фото
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF7949FF,
                                    ).withValues(alpha: 0.2),
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 4,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      color: Color(0xFF7949FF),
                                      size: 28,
                                    ),
                                    Text(
                                      'Добавить',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: Color(0xFF7949FF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    // Переход к следующему статусу или экрану

                    debugPrint('Детали услуги отправлены');

                    SnackBar snackBar = const SnackBar(
                      content: Text(
                        'Заявка отправлена! Ожидайте уведомления от нашего специалиста!',
                      ),
                    );
                    ScaffoldMessenger.of(ctx).showSnackBar(snackBar);

                    Timer(const Duration(seconds: 2), () {
                      setState(() {
                        statusDisplayType =
                            StatusDisplayTypes.trackingServiceProgress;
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF7949FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: const Text('Продолжить'),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildMapTrackingServiceBar(BuildContext ctx) {
    return <Widget>[
      Positioned(
        left: 16,
        right: 16,
        // top: MediaQuery.of(ctx).size.height * 0.12,
        bottom: MediaQuery.of(ctx).size.height * 0.12,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Text(
                      'Отслеживание прогресса услуги',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Text(
                      'Ваш запрос принят! Наш специалист уже в пути к вам.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF000000),
                      ),
                    ),

                    // Здесь можно добавить индикатор прогресса или карту с маршрутом специалиста
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        statusDisplayType = StatusDisplayTypes.serviceCompleted;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: const Color(
                        0xFF7949FF,
                      ).withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: const Text('Показать мастера на карте'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        statusDisplayType = StatusDisplayTypes.serviceCompleted;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: const Color(
                        0xFF000000,
                      ).withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: const Text('Создать новую заявку'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // Нижняя плашка с кнопками в зависимости от статуса
  Widget _buildMapBottomBar(BuildContext ctx) {
    return Stack(
      children: [
        // Плашка выбора адреса
        if (statusDisplayType == StatusDisplayTypes.selectAddress)
          ..._buildMapSelAdressBar(ctx),
        //
        if (statusDisplayType == StatusDisplayTypes.selectionServices)
          ..._buildMapSelServicesBar(ctx),

        if (statusDisplayType == StatusDisplayTypes.formServiceDetails)
          ..._buildMapSelFormServiceDetailsBar(ctx),

        if (statusDisplayType == StatusDisplayTypes.trackingServiceProgress)
          ..._buildMapTrackingServiceBar(ctx),

        // Кнопка «Моё местоположение»
        if (statusDisplayType == StatusDisplayTypes.selectAddress)
          Positioned(
            right: 16,
            bottom: MediaQuery.of(ctx).size.height * 0.8,
            child: FloatingActionButton.small(
              heroTag: 'my_location_btn',
              onPressed: _centerOnMyLocation,
              child: const Icon(Icons.location_history),
            ),
          ),
      ],
    );
  }

  Widget _buildRenderMapView(BuildContext ctx) {
    return SizedBox(
      height: MediaQuery.of(ctx).size.height,
      width: MediaQuery.of(ctx).size.width,
      child: Stack(
        children: [
          //
          // Карта
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              cameraConstraint: const CameraConstraint.containLatitude(),
              initialCenter: _initialCenter,
              initialZoom: 15.0,
              onLongPress: (tapPosition, point) {},
              onMapEvent: (event) {
                // Обновляем центр для плашки при любых событиях карты
                setState(() {
                  _bannerCenter = event.camera.center;
                });
                // Дебаунс на обратное геокодирование, чтобы не спамить запросами
                _geocodeDebounce?.cancel();
                _geocodeDebounce = Timer(const Duration(milliseconds: 600), () {
                  _resolveBannerAddress();
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    // "https://tile0.maps.2gis.com/tiles?&x={x}&y={y}&z={z}&v=1&ts=online_hd&theme=night",
                    "https://tile0.maps.2gis.com/tiles?&x={x}&y={y}&z={z}&v=2&ts=online_hd&lang=ru",
                // tileProvider: NetworkTileProvider(
                //   silenceExceptions: true,
                //   // cachingProvider:
                //   //     BuiltInMapCachingProvider.getOrCreateInstance(
                //   //       maxCacheSize: 1_000_000_000,
                //   //     ),
                // ),
                maxZoom: 21,
                minZoom: 10,
              ),

              // Маркер текущей геопозиции (синий кружок)
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: max(156, 140),
                      // height: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF282829),
                        ),
                        child: Row(
                          spacing: 4,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const Row(
                              children: [
                                Text(
                                  'Вы находитесь тут?',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Центральный пин как в Uber (закреплённый в центре карты)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                // Text('$statusDisplayType'),
                // Тень/подложка под пином
                SizedBox(height: 2),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x55000000),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SizedBox(width: 20, height: 4),
                ),
              ],
            ),
          ),

          // Postioned виджет плашки подтверждения адреса внизу

          // Индикатор загрузки геолокации
          if (_isLocating)
            Positioned(
              top: MediaQuery.of(ctx).size.height * -0.8,
              right: 16,
              // bottom: 150,
              child: const CircularProgressIndicator(),
            ),

          //
        ],
      ),
    );
  }
}
