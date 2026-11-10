import 'dart:typed_data';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/cache/app_image_cache_manager.dart';

/// Imagen corporativa global de la empresa.
///
/// Prioriza los bytes locales (para previsualizaciones mientras se sube una
/// imagen) y, en su defecto, resuelve la URL remota mediante la caché
/// persistente de la aplicación.
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    this.imageUrl,
    this.localBytes,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.fallback,
    this.placeholder,
    this.fadeInDuration = const Duration(milliseconds: 180),
  });

  final String? imageUrl;
  final Uint8List? localBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final Widget? fallback;
  final Widget? placeholder;
  final Duration fadeInDuration;

  bool get _hasLocalImage => localBytes != null && localBytes!.isNotEmpty;

  bool get _hasRemoteImage => (imageUrl ?? '').trim().isNotEmpty;

  Widget _wrap(Widget child) {
    final content = SizedBox(
      width: width,
      height: height,
      child: child,
    );

    if (borderRadius == null) return content;
    return ClipRRect(
      borderRadius: borderRadius!,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasLocalImage) {
      return _wrap(
        Image.memory(
          localBytes!,
          fit: fit,
          alignment: alignment,
          gaplessPlayback: true,
        ),
      );
    }

    if (_hasRemoteImage) {
      return _wrap(
        CachedNetworkImage(
          imageUrl: imageUrl!.trim(),
          cacheManager: AppImageCacheManager.instance,
          fit: fit,
          alignment: alignment,
          fadeInDuration: fadeInDuration,
          placeholder: (context, url) => placeholder ?? const SizedBox.shrink(),
          errorBuilder: (context, error, stackTrace) => fallback ?? const SizedBox.shrink(),
        ),
      );
    }

    return fallback ?? const SizedBox.shrink();
  }
}
