import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/widgets/elements/elements.dart';

class CustomClientListTile extends StatelessWidget {
  const CustomClientListTile({
    super.key,
    required this.client,
    this.onTap,
    this.trailing,
    this.backgroundColor,
    this.trailingFlex = 1,
  });

  final ClientInDb client;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? backgroundColor;
  final int trailingFlex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Ink(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Contenido: Información del cliente
              Expanded(
                child: ClientShortInfo(
                  client: client,
                  showId: true,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                flex: trailingFlex,
                child:
                    trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
