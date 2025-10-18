import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/super_widgets/overlay_expandable.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class OverlaySearchAnchor extends StatefulWidget {
  const OverlaySearchAnchor({super.key});

  @override
  State<OverlaySearchAnchor> createState() => _OverlaySearchAnchorState();
}

class _OverlaySearchAnchorState extends State<OverlaySearchAnchor> {
  final transitionController = TransitionController();
  GlobalKey textFieldKey = GlobalKey();

  Size? textFieldSize;
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textfieldRenderBox = textFieldKey.currentContext!.findRenderObject() as RenderBox;
      textFieldSize = textfieldRenderBox.size;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayExpandable(
      duration: const Duration(milliseconds: 200),
      curve: Curves.decelerate,
      transitionController: transitionController,
      size: textFieldSize,
      boxDecoration: const BoxDecoration(
        color: Colors.transparent,
      ),

      targetSize: const Size(450, 210),
      targetAlignment: const Alignment(0.0, -0.3),
      targetBoxDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      targetPadding: const EdgeInsets.all(4),
      onTransitionComplete: () {
        searchFocusNode.requestFocus();
      },
      targetChild: Center(
        child: Column(
          children: [
            SearchFieldDebounced(
              focusNode: searchFocusNode,
            ),
            Container(
              height: 150,
            ),
          ],
        ),
      ),
      child: TextField(
        readOnly: true,
        key: textFieldKey,
        onTap: () => transitionController.start(),
      ),
    );
  }
}
