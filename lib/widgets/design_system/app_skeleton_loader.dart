import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'app_theme_tokens.dart';

/// Skeleton loader elegante basado en Shimmer para listas, tablas y tarjetas.
class AppSkeletonLoader extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppSkeletonLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  /// Skeleton que simula una lista de tarjetas o elementos tipo ListTile.
  static Widget listTile({
    int count = 5,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const _SkeletonTileItem(),
    );
  }

  /// Skeleton que simula tarjetas de Bento / Cuadrícula.
  static Widget cards({
    int count = 4,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const _SkeletonCardItem(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade200,
      highlightColor: highlightColor ?? Colors.grey.shade50,
      child: child,
    );
  }
}

class _SkeletonTileItem extends StatelessWidget {
  const _SkeletonTileItem();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppThemeTokens.borderRadiusMd,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppThemeTokens.borderRadiusMd,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    constraints: const BoxConstraints(maxWidth: 180),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppThemeTokens.borderRadiusSm,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 11,
                    constraints: const BoxConstraints(maxWidth: 110),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppThemeTokens.borderRadiusSm,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppThemeTokens.borderRadiusFull,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCardItem extends StatelessWidget {
  const _SkeletonCardItem();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppThemeTokens.borderRadiusLg,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppThemeTokens.borderRadiusSm,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 90,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppThemeTokens.borderRadiusSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppThemeTokens.borderRadiusSm,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppThemeTokens.borderRadiusSm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
