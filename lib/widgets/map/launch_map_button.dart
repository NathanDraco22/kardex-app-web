import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchMapButton extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String label;

  const LaunchMapButton({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label = 'Mapa',
  });

  Future<void> _launchMap() async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryMenuButton(
      onPressed: _launchMap,
      icon: const Icon(Icons.location_on_outlined),
      label: Text(label),
    );
  }
}
