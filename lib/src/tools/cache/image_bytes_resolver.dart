import 'dart:typed_data';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:kardex_business/kardex_business.dart';
import 'app_image_cache_manager.dart';

/// Herramienta para resolver bytes de imágenes a partir de URLs o Base64 con soporte de caché persistente.
class ImageBytesResolver {
  ImageBytesResolver._();

  static final Map<String, Uint8List> _memoryCache = {};

  /// Resuelve los bytes (`Uint8List`) de una imagen dada su [url].
  ///
  /// Primero consulta la caché en memoria RAM. Si no está en memoria, intenta
  /// obtenerlo desde la caché persistente local de [AppImageCacheManager].
  /// Si el archivo aún no ha sido descargado, lo descarga y lo guarda en caché.
  static Future<Uint8List?> resolve(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return null;

    if (_memoryCache.containsKey(cleanUrl)) {
      return _memoryCache[cleanUrl];
    }

    try {
      final fileInfo = await AppImageCacheManager.instance.getFileFromCache(cleanUrl);
      if (fileInfo != null) {
        final bytes = await fileInfo.file.readAsBytes();
        _memoryCache[cleanUrl] = bytes;
        return bytes;
      }

      await for (final response in AppImageCacheManager.instance.getFileStream(cleanUrl)) {
        if (response is FileInfo) {
          final bytes = await response.file.readAsBytes();
          _memoryCache[cleanUrl] = bytes;
          return bytes;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  /// Limpia la caché en memoria RAM.
  static void clearMemoryCache() {
    _memoryCache.clear();
  }
}

/// Extensión sobre [BranchInDb] para resolver de forma transparente los bytes del logo de la sucursal.
extension BranchImageResolver on BranchInDb {
  /// Retorna los bytes del logo de la sucursal con prioridad en la nube.
  ///
  /// 1. Prioridad: Si existe [imageUrl], resuelve los bytes desde la caché local o red
  ///    y los asigna a [image] en memoria para optimizar lecturas posteriores.
  /// 2. Fallback: Si no tiene [imageUrl] o falló su resolución, usa los bytes locales de [image] (Base64).
  Future<Uint8List?> resolveLogoBytes() async {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final bytes = await ImageBytesResolver.resolve(imageUrl!);
      if (bytes != null) {
        image = bytes;
        return bytes;
      }
    }

    if (image != null && image!.isNotEmpty) {
      return image;
    }

    return null;
  }
}
