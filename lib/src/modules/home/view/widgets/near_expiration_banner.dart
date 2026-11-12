import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/near_expiration/near_expiration_cubit.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_business/kardex_business.dart';

/// Alerta visual de productos próximos a vencer o vencidos en pantalla de inicio.
class NearExpirationBanner extends StatelessWidget {
  /// Si es true, renderiza un formato más compacto tipo pastilla para escritorio.
  final bool isDesktop;

  const NearExpirationBanner({
    super.key,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return ExpirationDateGate(
      child: BlocBuilder<NearExpirationCubit, NearExpirationState>(
        builder: (context, state) {
          if (state is! NearExpirationLoaded || !state.hasLogs) {
            return const SizedBox.shrink();
          }

          final count = state.count;
          final nearest = state.nearestLog!;
          final days = nearest.expirationDate.difference(DateTime.now()).inDays;

          // Solo mostrar si faltan 100 días o menos (o si ya está vencido)
          if (days > 100) {
            return const SizedBox.shrink();
          }

          final bool isUrgent = days <= 30;
          final Color primaryColor = isUrgent ? const Color(0xFFDC2626) : const Color(0xFFD97706);
          final Color bgColor = isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);
          final Color borderColor = isUrgent ? const Color(0xFFFECACA) : const Color(0xFFFDE68A);

          String daysText;
          if (days < 0) {
            daysText = "vencido hace ${days.abs()} d";
          } else if (days == 0) {
            daysText = "vence hoy";
          } else {
            daysText = "vence en $days d";
          }

          if (isDesktop) {
            return _buildDesktopPill(
              context,
              count: count,
              nearest: nearest,
              daysText: daysText,
              primaryColor: primaryColor,
              bgColor: bgColor,
              borderColor: borderColor,
            );
          }

          return _buildMobileBanner(
            context,
            count: count,
            nearest: nearest,
            daysText: daysText,
            primaryColor: primaryColor,
            bgColor: bgColor,
            borderColor: borderColor,
          );
        },
      ),
    );
  }

  Widget _buildDesktopPill(
    BuildContext context, {
    required int count,
    required ExpirationLogInDb nearest,
    required String daysText,
    required Color primaryColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(RouteNames.expirationLogs),
        borderRadius: BorderRadius.circular(12),
        hoverColor: primaryColor.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notification_important_rounded,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      count == 1
                          ? "1 producto próximo a vencer:"
                          : "$count productos próximos a vencer:",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "${nearest.product.name} ($daysText)",
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ver bitácora",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBanner(
    BuildContext context, {
    required int count,
    required ExpirationLogInDb nearest,
    required String daysText,
    required Color primaryColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(RouteNames.expirationLogs),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.notification_important_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              count == 1
                                  ? "1 producto próximo a vencer"
                                  : "$count productos próximos a vencer",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${nearest.product.name} • $daysText",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
