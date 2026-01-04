import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:latlong2/latlong.dart';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

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

  @override
  void initState() {
    super.initState();
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
      print('Ошибка геолокации: $e');
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

  Future<void> _resolveBannerAddress() async {
    final lat = _bannerCenter.latitude;
    final lon = _bannerCenter.longitude;
    try {
      if (kIsWeb) {
        // Используем Nominatim для веба (без ключа)
        final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&zoom=18&addressdetails=1&accept-language=ru&namedetails=1',
        );
        final resp = await http.get(
          uri,
          headers: {
            // 'User-Agent': 'pit_care_app/1.0 (reverse-geocoding)',
            'Accept-Language': 'ru-RU',
          },
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final displayName = data['display_name'] as String?;
          debugPrint(data['address']?.toString() ?? 'No address found');
          setState(() {
            _bannerAddress =
                displayName ??
                '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
          });
        } else {
          setState(() {
            _bannerAddress =
                '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
          });
        }
      } else {
        // Нативное обратное геокодирование с фоллбеком на Nominatim (RU)
        final placemarks = await geocoding.placemarkFromCoordinates(
          lat,
          lon,
          localeIdentifier: 'ru_RU',
        );
        debugPrint(placemarks.toString());
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

        // Если нативный адрес пустой или не на русском, запрашиваем у Nominatim на русском
        if (nativeAddress != null && _hasCyrillic(nativeAddress)) {
          setState(() {
            _bannerAddress = nativeAddress!;
          });
        } else {
          try {
            final uri = Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&zoom=18&addressdetails=1&accept-language=ru&namedetails=1',
            );
            final resp = await http.get(
              uri,
              headers: {'Accept-Language': 'ru-RU'},
            );
            if (resp.statusCode == 200) {
              final data = jsonDecode(resp.body) as Map<String, dynamic>;
              final displayName = data['display_name'] as String?;
              setState(() {
                _bannerAddress =
                    displayName ??
                    (nativeAddress ??
                        '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}');
              });
            } else {
              setState(() {
                _bannerAddress =
                    nativeAddress ??
                    '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
              });
            }
          } catch (e) {
            setState(() {
              _bannerAddress =
                  nativeAddress ??
                  '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      setState(() {
        _bannerAddress = '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
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
      appBar: CustomAppBar(
        backgroundBar: Colors.transparent,
        title: 'Карта',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildRenderMapView(context),
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
                    "https://tile0.maps.2gis.com/tiles?&x={x}&y={y}&z={z}&v=1&ts=online_hd",
                tileProvider: NetworkTileProvider(
                  silenceExceptions: true,
                  cachingProvider:
                      BuiltInMapCachingProvider.getOrCreateInstance(
                        maxCacheSize: 1_000_000_000,
                      ),
                ),
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

          // Кнопка «Я сломался»
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).size.height * 0.08,
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
            bottom: MediaQuery.of(ctx).size.height * 0.16,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Вы находитесь тут?',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _bannerAddress ?? 'Определяем адрес…',
                          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _followUser = false;
                                });
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Перетащите карту и нажмите «Я сломался» для выбора точки.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Изменить адрес'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => _confirmCurrentCenter(ctx),
                              child: const Text('Да'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Кнопка «Моё местоположение»
          Positioned(
            right: 16,
            bottom: MediaQuery.of(ctx).size.height * 0.8,
            child: FloatingActionButton.small(
              heroTag: 'my_location_btn',
              onPressed: _centerOnMyLocation,
              child: const Icon(Icons.location_history),
            ),
          ),

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
