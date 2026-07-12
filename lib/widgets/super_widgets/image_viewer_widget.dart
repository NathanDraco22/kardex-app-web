import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/image_viewer_dialog.dart';

/// Un widget premium para mostrar la previsualización de una o múltiples imágenes.
///
/// Si contiene imágenes, muestra la primera de la lista con un efecto hover y una
/// insignia que indica la cantidad de imágenes adicionales (ej: +2).
/// Al tocar el widget, se abre el diálogo a pantalla completa [showImageViewerDialog].
class ImageViewerWidget extends StatefulWidget {
  final List<String> imageUrls;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final String placeholderText;

  const ImageViewerWidget({
    super.key,
    required this.imageUrls,
    this.width = 120,
    this.height = 120,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.placeholderText = "Sin imagen",
  });

  @override
  State<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  bool _isHovered = false;

  void _handleTap() {
    if (widget.imageUrls.isEmpty) return;
    showImageViewerDialog(context, imageUrls: widget.imageUrls);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImages = widget.imageUrls.isNotEmpty;
    final multipleImages = widget.imageUrls.length > 1;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: hasImages ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: _isHovered && hasImages
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              if (_isHovered && hasImages)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen de fondo o Marcador de posición
                if (hasImages)
                  CachedNetworkImage(
                    imageUrl: widget.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: widget.width * 0.25,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Error",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FluentIcons.cube_12_filled,
                        size: widget.width * 0.25,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ],
                  ),

                // Capa Hover de Visualización
                if (hasImages)
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black54,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Insignia (badge) indicando cantidad de fotos adicionales
                if (hasImages && multipleImages)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "+${widget.imageUrls.length - 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
