import 'dart:async';
import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart' as esc;
import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart' hide PaperSize;
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:image/image.dart' as img;
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart' hide Printer;

/// Servicio responsable de gestionar el ciclo de vida, descubrimiento,
/// conexión y transmisión de comandos ESC/POS a impresoras térmicas
/// directas (Bluetooth / USB / Red) utilizando [FlutterThermalPrinter].
class ThermalPrinterService {
  final FlutterThermalPrinter _printerPlugin = FlutterThermalPrinter.instance;

  Stream<List<Printer>> get devicesStream => _printerPlugin.devicesStream;

  Printer? _activePrinter;
  Printer? get activePrinter => _activePrinter;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  /// Solicita los permisos necesarios en Android (Bluetooth y Ubicación).
  Future<bool> requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    try {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      final connectGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      final locationGranted = statuses[Permission.location]?.isGranted ?? false;

      // En Android 12+, scan y connect son los mandatorios; en versiones previas location es suficiente
      return scanGranted || connectGranted || locationGranted;
    } catch (e) {
      debugPrint('[ThermalPrinterService] Error al solicitar permisos: $e');
      return false;
    }
  }

  /// Inicia el escaneo de impresoras disponibles (Bluetooth y USB).
  Future<void> startScan() async {
    final hasPerms = await requestPermissions();
    if (!hasPerms) {
      debugPrint('[ThermalPrinterService] Permisos no otorgados para escanear');
      return;
    }

    _isScanning = true;
    try {
      await _printerPlugin.getPrinters(
        connectionTypes: [
          ConnectionType.BLE,
          ConnectionType.USB,
        ],
      );
    } catch (e) {
      debugPrint('[ThermalPrinterService] Error al iniciar escaneo: $e');
      _isScanning = false;
    }
  }

  /// Detiene el escaneo activo de impresoras.
  Future<void> stopScan() async {
    _isScanning = false;
    try {
      await _printerPlugin.stopScan();
    } catch (e) {
      debugPrint('[ThermalPrinterService] Error al detener escaneo: $e');
    }
  }

  /// Conecta con una impresora térmica específica.
  Future<bool> connect(Printer printer) async {
    try {
      final success = await _printerPlugin.connect(printer);
      if (success) {
        _activePrinter = printer;
      }
      return success;
    } catch (e) {
      debugPrint('[ThermalPrinterService] Error al conectar con ${printer.name}: $e');
      return false;
    }
  }

  /// Desconecta la impresora activa si existe.
  Future<void> disconnect([Printer? printer]) async {
    final target = printer ?? _activePrinter;
    if (target != null) {
      try {
        await _printerPlugin.disconnect(target);
        if (_activePrinter?.address == target.address) {
          _activePrinter = null;
        }
      } catch (e) {
        debugPrint('[ThermalPrinterService] Error al desconectar: $e');
      }
    }
  }

  /// Aplana cualquier transparencia de la imagen sobre un lienzo blanco puro.
  /// Esto es crítico porque Printing.raster genera páginas con fondo transparente
  /// (RGBA: 0, 0, 0, 0), lo que provocaría que esc_pos_utils_plus invierta el fondo
  /// negro a blanco activo, quemando toda la bobina en negro.
  img.Image _flattenAlphaOverWhite(img.Image src) {
    final canvas = img.Image(
      width: src.width,
      height: src.height,
      numChannels: 4,
    );
    img.fill(canvas, color: img.ColorRgba8(255, 255, 255, 255));
    img.compositeImage(canvas, src);

    for (final pixel in canvas) {
      if (pixel.a < 255) {
        final alpha = pixel.a / 255.0;
        pixel.r = (pixel.r * alpha + 255 * (1 - alpha)).round();
        pixel.g = (pixel.g * alpha + 255 * (1 - alpha)).round();
        pixel.b = (pixel.b * alpha + 255 * (1 - alpha)).round();
        pixel.a = 255;
      }
    }

    return canvas;
  }

  /// Aplica tramado (dithering) Floyd-Steinberg a una imagen en escala de grises.
  /// Distribuye el error de luminosidad hacia los píxeles adyacentes, permitiendo
  /// que tonos de gris (como logos, fotos y sombreados) se conviertan en una
  /// matriz de puntos térmicos monocromáticos nítida y perfectamente visible.
  img.Image _applyFloydSteinbergDithering(img.Image image) {
    final width = image.width;
    final height = image.height;
    final errors = Float32List(width * height);

    for (var i = 0; i < width * height; i++) {
      final x = i % width;
      final y = i ~/ width;
      errors[i] = image.getPixel(x, y).r.toDouble();
    }

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final idx = y * width + x;
        final oldVal = errors[idx];
        final newVal = oldVal < 128.0 ? 0.0 : 255.0;
        final err = oldVal - newVal;

        final colorVal = newVal.toInt();
        image.setPixelRgb(x, y, colorVal, colorVal, colorVal);

        if (x + 1 < width) {
          errors[idx + 1] += err * (7.0 / 16.0);
        }
        if (y + 1 < height) {
          if (x - 1 >= 0) {
            errors[(y + 1) * width + (x - 1)] += err * (3.0 / 16.0);
          }
          errors[(y + 1) * width + x] += err * (5.0 / 16.0);
          if (x + 1 < width) {
            errors[(y + 1) * width + (x + 1)] += err * (1.0 / 16.0);
          }
        }
      }
    }
    return image;
  }

  /// Imprime un documento PDF convirtiéndolo a mapa de bits rasterizado ESC/POS.
  /// [targetWidth] ajustado a 384 puntos para 58mm y 576 puntos para 80mm (divisibles por 8).
  Future<bool> printPdfBytes(
    Uint8List pdfBytes, {
    required Printer printer,
    required PaperSize paperSize,
    bool autoCut = true,
    bool invertColor = false,
    bool useDithering = true,
  }) async {
    try {
      // 1. Asegurar conexión con la impresora
      final isConnected = printer.isConnected ?? false;
      if (!isConnected) {
        final connected = await connect(printer);
        if (!connected) {
          debugPrint('[ThermalPrinterService] No se pudo establecer conexión con ${printer.name}');
          return false;
        }
      }

      // 2. Cargar perfil de capacidades y generador ESC/POS
      final profile = await esc.CapabilityProfile.load();
      final generator = esc.Generator(
        paperSize == PaperSize.mm58 ? esc.PaperSize.mm58 : esc.PaperSize.mm80,
        profile,
      );

      final targetWidth = paperSize == PaperSize.mm58 ? 384 : 576;
      final rasterPages = Printing.raster(pdfBytes, dpi: 203);
      final rawBytes = <int>[];

      await for (final page in rasterPages) {
        final pngBytes = await page.toPng();
        var decoded = img.decodeImage(pngBytes);
        if (decoded == null) continue;

        // Aplanar el fondo transparente del PDF sobre un lienzo blanco puro
        decoded = _flattenAlphaOverWhite(decoded);

        // Ajustar ancho al límite térmico físico
        if (decoded.width != targetWidth) {
          decoded = img.copyResize(decoded, width: targetWidth);
        }

        // Convertir a escala de grises para mapa de bits térmico
        decoded = img.grayscale(decoded);

        // Tramado Floyd-Steinberg para preservar gradientes y tonos de gris en logos e imágenes
        if (useDithering) {
          decoded = _applyFloydSteinbergDithering(decoded);
        }

        // Si el usuario especificó invertir colores
        if (invertColor) {
          decoded = img.invert(decoded);
        }

        // Procesar en chunks horizontales de 30px para no saturar el buffer de la impresora
        const chunkHeight = 30;
        final totalHeight = decoded.height;
        final totalWidth = decoded.width;
        final chunksCount = (totalHeight / chunkHeight).ceil();

        for (var i = 0; i < chunksCount; i++) {
          final startY = i * chunkHeight;
          final endY = (startY + chunkHeight > totalHeight) ? totalHeight : startY + chunkHeight;
          final actualHeight = endY - startY;

          final cropped = img.copyCrop(
            decoded,
            x: 0,
            y: startY,
            width: totalWidth,
            height: actualHeight,
          );

          rawBytes.addAll(generator.imageRaster(cropped));
        }
      }

      // Salto final y comando de corte de papel
      rawBytes.addAll(generator.feed(2));
      if (autoCut) {
        rawBytes.addAll(generator.cut());
      }

      // 3. Transmitir los bytes ESC/POS en modo de datos extensos
      await _printerPlugin.printData(
        printer,
        rawBytes,
        longData: true,
      );

      return true;
    } catch (e) {
      debugPrint('[ThermalPrinterService] Error en printPdfBytes: $e');
      return false;
    }
  }

  /// Emite un ticket de prueba corto para verificar la conexión física con la impresora.
  Future<bool> printTestTicket({
    required Printer printer,
    required PaperSize paperSize,
    bool autoCut = true,
  }) async {
    try {
      final isConnected = printer.isConnected ?? false;
      if (!isConnected) {
        final connected = await connect(printer);
        if (!connected) return false;
      }

      final profile = await esc.CapabilityProfile.load();
      final generator = esc.Generator(
        paperSize == PaperSize.mm58 ? esc.PaperSize.mm58 : esc.PaperSize.mm80,
        profile,
      );

      final bytes = <int>[];
      bytes.addAll(generator.text(
        'NEPTUNO SYSTEM',
        styles: const esc.PosStyles(
          align: esc.PosAlign.center,
          bold: true,
          height: esc.PosTextSize.size2,
          width: esc.PosTextSize.size2,
        ),
      ));
      bytes.addAll(generator.text(
        'Prueba de Impresora Termica',
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      ));
      bytes.addAll(generator.text(
        '--------------------------------',
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      ));
      bytes.addAll(generator.text(
        'Estado: Conectada exitosamente',
        styles: const esc.PosStyles(bold: true),
      ));
      bytes.addAll(generator.text('Dispositivo: ${printer.name ?? "Desconocido"}'));
      bytes.addAll(generator.text('Direccion: ${printer.address ?? "N/A"}'));
      bytes.addAll(generator.text('Formato: ${paperSize == PaperSize.mm58 ? "58 mm" : "80 mm"}'));
      bytes.addAll(generator.text('Fecha: ${DateTime.now().toString().split(".")[0]}'));
      bytes.addAll(generator.text(
        '--------------------------------',
        styles: const esc.PosStyles(align: esc.PosAlign.center),
      ));
      bytes.addAll(generator.feed(2));
      if (autoCut) {
        bytes.addAll(generator.cut());
      }

      await _printerPlugin.printData(
        printer,
        bytes,
        longData: true,
      );

      return true;
    } catch (e) {
      debugPrint('[ThermalPrinterService] Error al emitir ticket de prueba: $e');
      return false;
    }
  }
}
