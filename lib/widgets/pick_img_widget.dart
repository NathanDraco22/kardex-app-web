import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImgWidget extends StatefulWidget {
  const PickImgWidget({
    super.key,
    required this.onImageSelected,
    this.initialImage,
  });

  final void Function(XFile? image) onImageSelected;
  final ImageProvider? initialImage;

  @override
  State<PickImgWidget> createState() => _PickImgWidgetState();
}

class _PickImgWidgetState extends State<PickImgWidget> {
  final ImagePicker _picker = ImagePicker();

  ImageProvider? _currentImageProvider;

  @override
  void initState() {
    super.initState();
    _currentImageProvider = widget.initialImage;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        _currentImageProvider = kIsWeb
            ? NetworkImage(pickedFile.path)
            : FileImage(
                File(pickedFile.path),
              );
        setState(() {});
        widget.onImageSelected(pickedFile);
      }
    } catch (e) {
      log("Error al seleccionar la imagen: $e");
    }
  }

  void _clearImage() {
    setState(() {
      _currentImageProvider = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _currentImageProvider == null ? _pickImage : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: _currentImageProvider == null ? _buildPlaceholder() : _buildImagePreview(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text("Seleccionar imagen"),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: _currentImageProvider!,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _clearImage,
              tooltip: 'Borrar imagen',
            ),
          ),
        ),
      ],
    );
  }
}
