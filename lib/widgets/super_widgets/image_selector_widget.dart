import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/image_selector_dialog.dart';

/// Un widget premium e interactivo para visualizar y seleccionar imágenes.
///
/// Muestra la imagen actual mediante un [ImageProvider] o un marcador de posición estético.
/// Al tocar el widget, se abre automáticamente el diálogo [showImageSelectorDialog].
/// Si el usuario confirma una acción en el diálogo (agregar, cambiar o eliminar),
/// se propaga a través de la devolución de llamada [onIntent].
class ImageSelectorWidget extends StatefulWidget {
  final ImageProvider? image;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final String placeholderText;
  final void Function(ImageSelectorIntent intent)? onIntent;

  const ImageSelectorWidget({
    super.key,
    this.image,
    this.width = 160,
    this.height = 160,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.placeholderText = "Seleccionar imagen",
    this.onIntent,
  });

  @override
  State<ImageSelectorWidget> createState() => _ImageSelectorWidgetState();
}

class _ImageSelectorWidgetState extends State<ImageSelectorWidget> {
  bool _isHovered = false;

  Future<void> _handleTap() async {
    final intent = await showImageSelectorDialog(
      context: context,
      initialImage: widget.image,
    );

    if (intent != null && widget.onIntent != null) {
      widget.onIntent!(intent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = widget.image != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
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
              color: _isHovered
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Renderizar imagen actual o marcador de posición
                if (hasImage)
                  Image(
                    image: widget.image!,
                    fit: BoxFit.cover,
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: widget.width * 0.25,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          widget.placeholderText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Capa de superposición en hover (solo cuando ya hay una imagen)
                if (hasImage)
                  AnimatedOpacity(
                    opacity: _isHovered ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      color: Colors.black54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Editar imagen",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
