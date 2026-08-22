import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';

/// Abre un diálogo modal a pantalla completa para visualizar una lista de imágenes.
///
/// Permite navegar deslizando horizontalmente entre las imágenes y hacer zoom/deslizar
/// de forma táctil en cada una de ellas.
Future<void> showImageViewerDialog(
  BuildContext context, {
  required List<String> imageUrls,
  int initialIndex = 0,
}) async {
  if (imageUrls.isEmpty) return;

  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (context) => ImageViewerDialog(
      imageUrls: imageUrls,
      initialIndex: initialIndex,
    ),
  );
}

class ImageViewerDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerDialog({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Carrusel de Imágenes con soporte de zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.imageUrls[index];
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white60,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error al cargar la imagen",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Barra Superior Flotante (Indicador y Botón de Cerrar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador de Paginación
                    if (hasMultiple)
                      Text(
                        "${_currentIndex + 1} de ${widget.imageUrls.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // Botón de Cerrar
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: "Cerrar",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
