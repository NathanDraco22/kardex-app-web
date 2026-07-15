import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:croppy/croppy.dart';
import 'package:image/image.dart' as img;

/// Clase base sellada que representa la intención del usuario al salir del diálogo.
sealed class ImageSelectorIntent {}

/// Intención de agregar una nueva imagen (cuando antes no había ninguna).
class NewImageIntent extends ImageSelectorIntent {
  final XFile file;
  final Uint8List bytes;

  NewImageIntent({
    required this.file,
    required this.bytes,
  });
}

/// Intención de cambiar la imagen existente por una nueva.
class ChangeImageIntent extends ImageSelectorIntent {
  final XFile file;
  final Uint8List bytes;

  ChangeImageIntent({
    required this.file,
    required this.bytes,
  });
}

/// Intención de eliminar la imagen existente.
class DeleteImageIntent extends ImageSelectorIntent {
  DeleteImageIntent();
}

/// Muestra el diálogo de selección de imagen y retorna la intención del usuario.
///
/// Si el usuario cancela o cierra el diálogo sin confirmar cambios, retorna `null`.
Future<ImageSelectorIntent?> showImageSelectorDialog({
  required BuildContext context,
  ImageProvider? initialImage,
}) async {
  return await showDialog<ImageSelectorIntent?>(
    context: context,
    barrierDismissible: true,
    builder: (context) => ImageSelectorDialog(initialImage: initialImage),
  );
}

class ImageSelectorDialog extends StatefulWidget {
  final ImageProvider? initialImage;

  const ImageSelectorDialog({
    super.key,
    this.initialImage,
  });

  @override
  State<ImageSelectorDialog> createState() => _ImageSelectorDialogState();
}

class _ImageSelectorDialogState extends State<ImageSelectorDialog> {
  final ImagePicker _picker = ImagePicker();

  ImageProvider? _tempImageProvider;
  XFile? _tempPickedFile;
  Uint8List? _tempBytes;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _tempImageProvider = widget.initialImage;
  }

  /// Verifica si el usuario realizó algún cambio respecto a la imagen inicial.
  bool get _hasChanges {
    if (widget.initialImage != null && _isDeleted) return true;
    if (_tempPickedFile != null) return true;
    return false;
  }

  /// Abre la galería para seleccionar una imagen y luego la recorta en formato cuadrado.
  Future<void> _pickAndCropImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null || !mounted) return;

      // Leemos los bytes del XFile y creamos un MemoryImage
      final bytesBeforeCrop = await pickedFile.readAsBytes();
      if (!mounted) return;
      final imageProvider = MemoryImage(bytesBeforeCrop);

      // Usamos showAdaptiveImageCropper de croppy para mostrar la UI nativa según la plataforma (Material vs Cupertino)
      final result = await showAdaptiveImageCropper(
        context,
        imageProvider: imageProvider,
        allowedAspectRatios: [
          const CropAspectRatio(width: 1, height: 1),
        ],
      );

      if (result == null || !mounted) return;

      // Obtenemos el objeto dart:ui.Image del resultado
      ui.Image uiImage = result.uiImage;

      // Si excede el tamaño máximo (720px), la redimensionamos en memoria usando un Canvas
      const double maxSize = 720.0;
      if (uiImage.width > maxSize || uiImage.height > maxSize) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, maxSize, maxSize));

        paintImage(
          canvas: canvas,
          rect: const Rect.fromLTWH(0, 0, maxSize, maxSize),
          image: uiImage,
          fit: BoxFit.fill,
        );

        final picture = recorder.endRecording();
        uiImage = await picture.toImage(maxSize.toInt(), maxSize.toInt());
      }

      // Obtenemos los bytes de píxeles crudos (RGBA) directamente de la GPU (es instantáneo)
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) return;
      final rawBytes = byteData.buffer.asUint8List();

      // Creamos el objeto Image a partir de los bytes crudos (RGBA) sin decodificación intermedia
      final decodedImage = img.Image.fromBytes(
        width: uiImage.width,
        height: uiImage.height,
        bytes: rawBytes.buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );

      // Convertimos la imagen a un formato JPEG real (RGB) eliminando el canal alfa para el backend
      final bytes = img.encodeJpg(decodedImage, quality: 70);

      setState(() {
        _tempPickedFile = pickedFile;
        _tempBytes = bytes;
        _tempImageProvider = MemoryImage(bytes);
        _isDeleted = false;
      });
    } catch (e) {
      log("Error al seleccionar o recortar imagen: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al procesar la imagen: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// Remueve la imagen seleccionada localmente en el diálogo.
  void _deleteImage() {
    setState(() {
      _tempImageProvider = null;
      _tempPickedFile = null;
      _tempBytes = null;
      _isDeleted = true;
    });
  }

  /// Cierra el diálogo y retorna la intención correspondiente.
  void _confirmAndPop() {
    if (!_hasChanges) {
      Navigator.pop(context, null);
      return;
    }

    if (_isDeleted && widget.initialImage != null) {
      Navigator.pop(context, DeleteImageIntent());
      return;
    }

    if (_tempPickedFile != null && _tempBytes != null) {
      if (widget.initialImage == null) {
        Navigator.pop(
          context,
          NewImageIntent(file: _tempPickedFile!, bytes: _tempBytes!),
        );
      } else {
        Navigator.pop(
          context,
          ChangeImageIntent(file: _tempPickedFile!, bytes: _tempBytes!),
        );
      }
      return;
    }

    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = _tempImageProvider != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado del diálogo
              Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: theme.colorScheme.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Seleccionar Imagen",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Visualizador de Imagen / Placeholder
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: hasImage
                      ? Image(
                          image: _tempImageProvider!,
                          fit: BoxFit.cover,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Sin imagen seleccionada",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Botones de acción intermedia (Agregar, Cambiar, Eliminar)
              if (!hasImage)
                ElevatedButton.icon(
                  onPressed: _pickAndCropImage,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text("Agregar Imagen"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickAndCropImage,
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text("Cambiar"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _deleteImage,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text("Eliminar"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Botones de control del diálogo (Cancelar y Aceptar)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _confirmAndPop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasChanges
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.6),
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: _hasChanges ? 2 : 0,
                    ),
                    child: const Text("Aceptar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
