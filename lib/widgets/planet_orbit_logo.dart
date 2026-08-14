import 'dart:math' as math;
import 'package:flutter/material.dart';

class PlanetOrbitLogo extends StatefulWidget {
  final double size;
  final Gradient? planetGradient;

  const PlanetOrbitLogo({
    super.key,
    this.size = 140,
    this.planetGradient,
  });

  @override
  State<PlanetOrbitLogo> createState() => _PlanetOrbitLogoState();
}

class _PlanetOrbitLogoState extends State<PlanetOrbitLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PlanetOrbitPainter(
            orbitProgress: _controller.value,
            planetGradient: widget.planetGradient,
          ),
        );
      },
    );
  }
}

class _PlanetOrbitPainter extends CustomPainter {
  final double orbitProgress; // 0.0 a 1.0 (ciclo de 6 segundos)
  final Gradient? planetGradient;

  _PlanetOrbitPainter({
    required this.orbitProgress,
    this.planetGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Escalar sistema de coordenadas a la referencia 800 x 800
    final scale = size.width / 800.0;
    canvas.save();
    canvas.scale(scale, scale);

    const center = Offset(400, 400);
    const orbitTilt = -25.0 * (math.pi / 180.0);

    // Rotar todo el sistema de órbita y planeta a -25 grados
    canvas.translate(center.dx, center.dy);
    canvas.rotate(orbitTilt);
    canvas.translate(-center.dx, -center.dy);

    // Parámetros de la elipse orbital
    const rx = 320.0;
    const ry = 110.0;

    final angle = orbitProgress * 2 * math.pi;
    final isBehind = orbitProgress < 0.5;

    // 1. DIBUJAR ARCO TRASERO DE LA ÓRBITA (detrás del planeta)
    _drawBackOrbit(canvas, center, rx, ry);

    // 2. SI EL SATÉLITE ESTÁ ATRÁS, DIBUJARLO DETRÁS DEL PLANETA
    if (isBehind) {
      _drawSatellite(canvas, center, rx, ry, angle, isBehind: true);
    }

    // 3. DIBUJAR LA ESFERA DEL PLANETA CON GRADIENTE SUAVE LIMPIO
    _drawPlanet(canvas, center);

    // 4. DIBUJAR ARCO FRONTAL DE LA ÓRBITA (al frente del planeta)
    _drawFrontOrbit(canvas, center, rx, ry);

    // 5. SI EL SATÉLITE ESTÁ AL FRENTE, DIBUJARLO AL FRENTE DEL PLANETA
    if (!isBehind) {
      _drawSatellite(canvas, center, rx, ry, angle, isBehind: false);
    }

    canvas.restore();
  }

  void _drawBackOrbit(Canvas canvas, Offset center, double rx, double ry) {
    final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF9D00), Color(0xFFFF5500)],
      ).createShader(rect)
      ..color = const Color(0xFFFF9D00).withValues(alpha: 0.4);

    final path = Path()..addArc(rect, 0, -math.pi);
    canvas.drawPath(path, paint);
  }

  void _drawFrontOrbit(Canvas canvas, Offset center, double rx, double ry) {
    final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF9D00), Color(0xFFFF5500)],
      ).createShader(rect);

    final path = Path()..addArc(rect, -math.pi, -math.pi);
    canvas.drawPath(path, paint);
  }

  void _drawPlanet(Canvas canvas, Offset center) {
    const radius = 200.0;
    final planetRect = Rect.fromCircle(center: center, radius: radius);

    final effectiveGradient = planetGradient ??
        const LinearGradient(
          begin: Alignment(0.85, -0.85), // Arriba a la derecha (cian brillante)
          end: Alignment(-0.85, 0.85),   // Abajo a la izquierda (índigo profundo)
          colors: [
            Color(0xFF00A6E8), // Azul cian brillante
            Color(0xFF0258B8), // Azul real medio
            Color(0xFF221666), // Índigo oscuro profundo
          ],
          stops: [0.0, 0.45, 1.0],
        );

    final planetPaint = Paint()
      ..shader = effectiveGradient.createShader(planetRect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, planetPaint);
  }

  void _drawSatellite(
    Canvas canvas,
    Offset center,
    double rx,
    double ry,
    double angle, {
    required bool isBehind,
  }) {
    final satX = center.dx + rx * math.cos(angle);
    final satY = center.dy - ry * math.sin(angle);

    final double satScale;
    final double satOpacity;

    if (isBehind) {
      final t = orbitProgress / 0.5;
      final curve = math.sin(t * math.pi);
      satScale = 1.0 - 0.4 * curve; // min 0.6
      satOpacity = 1.0 - 0.4 * curve; // min 0.6
    } else {
      final t = (orbitProgress - 0.5) / 0.5;
      final curve = math.sin(t * math.pi);
      satScale = 1.0 + 0.4 * curve; // max 1.4
      satOpacity = 1.0;
    }

    final tangentAngle = math.atan2(
      -ry * math.cos(angle),
      -rx * math.sin(angle),
    );

    canvas.save();
    canvas.translate(satX, satY);
    canvas.rotate(tangentAngle);
    canvas.scale(satScale, satScale);

    // 1. Polígono exterior traslúcido
    final outerHex = _createPolygon(const [
      Offset(0, -22),
      Offset(19, -11),
      Offset(19, 11),
      Offset(0, 22),
      Offset(-19, 11),
      Offset(-19, -11),
    ], scale: 1.3);

    canvas.drawPath(
      outerHex,
      Paint()
        ..color = const Color(0xFFFF7700).withValues(alpha: 0.3 * satOpacity),
    );

    // 2. Polígono intermedio con borde
    final midHex = _createPolygon(const [
      Offset(0, -18),
      Offset(15.6, -9),
      Offset(15.6, 9),
      Offset(0, 18),
      Offset(-15.6, 9),
      Offset(-15.6, -9),
    ]);

    canvas.drawPath(
      midHex,
      Paint()..color = const Color(0xFFFF9100).withValues(alpha: satOpacity),
    );
    canvas.drawPath(
      midHex,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFEA00).withValues(alpha: satOpacity),
    );

    // 3. Polígono central brillante
    final innerHex = _createPolygon(const [
      Offset(0, -8),
      Offset(6.9, -4),
      Offset(6.9, 4),
      Offset(0, 8),
      Offset(-6.9, 4),
      Offset(-6.9, -4),
    ]);

    canvas.drawPath(
      innerHex,
      Paint()..color = const Color(0xFFFFEA00).withValues(alpha: satOpacity),
    );

    canvas.restore();
  }

  Path _createPolygon(List<Offset> points, {double scale = 1.0}) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points[0].dx * scale, points[0].dy * scale);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * scale, points[i].dy * scale);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _PlanetOrbitPainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.planetGradient != planetGradient;
  }
}
