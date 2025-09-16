import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/status_tag_label.dart';

class MobileRow extends StatelessWidget {
  const MobileRow({
    super.key,
    required this.title,
    required this.color,
    this.subtitle1,
    this.subtitle2,
    required this.isActive,
    this.onEditButtonPresesed,
    this.onTab,
  });

  final String title;
  final Color color;
  final String? subtitle1;
  final String? subtitle2;
  final bool isActive;
  final void Function()? onEditButtonPresesed;
  final void Function()? onTab;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTab,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (subtitle1 != null || subtitle2 != null)
                        Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                subtitle1 ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                subtitle2 ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Builder(
                    builder: (context) {
                      if (isActive) {
                        return const StatusTagLabel(
                          label: "Activo",
                          isActive: true,
                        );
                      } else {
                        return const StatusTagLabel(
                          label: "Inactivo",
                          isActive: false,
                        );
                      }
                    },
                  ),
                ),
                if (onEditButtonPresesed != null)
                  Flexible(
                    fit: FlexFit.tight,
                    child: IconButton(
                      onPressed: onEditButtonPresesed,
                      icon: const Icon(Icons.edit),
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
