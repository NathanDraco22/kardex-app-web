import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_to_submit_button/slide_to_submit_button.dart';

class CustomSlider extends StatelessWidget {
  const CustomSlider({
    super.key,
    required this.hintText,
    required this.hintIcon,
    required this.sliderColor,
    required this.sliderText,
    required this.onSubmit,
  });

  final String hintText;
  final IconData hintIcon;
  final Color sliderColor;
  final String sliderText;

  final void Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: SlideToSubmit.custom(
        hint: Align(
          alignment: Alignment.centerRight,
          child: Shimmer.fromColors(
            baseColor: Colors.grey,
            highlightColor: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  hintText,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Icon(
                  hintIcon,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        slider: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: sliderColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sliderText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
              ),
            ],
          ),
        ),
        backgroundDecoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        sliderWidth: 120,
        height: 60,
        onSubmit: (controller) {
          onSubmit();
        },
        threshold: 0.95,
      ),
    );
  }
}
