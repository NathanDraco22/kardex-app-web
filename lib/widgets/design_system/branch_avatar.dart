import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/cache/app_image_cache_manager.dart';
import 'package:kardex_business/kardex_business.dart';

/// Avatar visual de una sucursal.
///
/// Prioriza la URL remota (con caché persistente), luego los bytes locales y,
/// en su defecto, un icono de comercio o almacén según `isCommerce`.
class BranchAvatar extends StatelessWidget {
  const BranchAvatar({
    super.key,
    required this.branch,
    this.size = 48,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  final BranchInDb branch;
  final double size;
  final BorderRadius borderRadius;

  Color get _accent => branch.isCommerce
      ? const Color(0xFFD97706)
      : const Color(0xFF475569);

  bool get _hasRemoteImage => (branch.imageUrl ?? '').trim().isNotEmpty;

  bool get _hasLocalImage => branch.image != null && branch.image!.isNotEmpty;

  Widget _fallback() {
    return Center(
      child: Icon(
        branch.isCommerce
            ? Icons.storefront_rounded
            : Icons.warehouse_rounded,
        color: _accent,
        size: size * 0.46,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (_hasRemoteImage) {
      image = CachedNetworkImage(
        imageUrl: branch.imageUrl!.trim(),
        cacheManager: AppImageCacheManager.instance,
        fit: BoxFit.cover,
        placeholder: (context, url) => _fallback(),
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    } else if (_hasLocalImage) {
      image = Image.memory(
        branch.image!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } else {
      image = _fallback();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: borderRadius,
        border: Border.all(color: _accent.withValues(alpha: 0.14)),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: image,
      ),
    );
  }
}
