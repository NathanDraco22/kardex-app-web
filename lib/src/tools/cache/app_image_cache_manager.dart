import 'package:cached_network_image_ce/cached_network_image.dart';

/// Administrador de caché persistente y de larga duración para imágenes en la aplicación.
///
/// Configurado con un período de validez prolongado de 365 días (1 año) y una
/// capacidad de hasta 2,000 objetos cacheados (persistidos mediante Hive / IndexedDB en Web).
class AppImageCacheManager {
  AppImageCacheManager._();

  static final DefaultCacheManager instance = DefaultCacheManager(
    stalePeriod: const Duration(days: 365),
    maxNrOfCacheObjects: 2000,
  );
}
