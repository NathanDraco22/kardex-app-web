import 'package:flutter/material.dart';

class TransitionController {
  void Function()? _triggerStart;
  void Function()? _triggerClose;

  void start() {
    _triggerStart?.call();
  }

  void close() {
    _triggerClose?.call();
  }
}

class OverlayExpandable extends StatefulWidget {
  const OverlayExpandable({
    super.key,
    required this.transitionController,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.barrierColor = Colors.black54,
    this.barrierDismissible = true,
    this.boxDecoration = const BoxDecoration(
      color: Colors.blue,
    ),
    this.targetBoxDecoration,
    this.size,
    this.targetSize = const Size(100, 100),
    this.targetAlignment = Alignment.center,
    this.child,
    this.padding,
    this.targetChild,
    this.targetPadding,
    this.onTransitionComplete,
    this.onClose,
  });

  final TransitionController transitionController;
  final Duration duration;
  final Curve curve;
  final Color barrierColor;
  final bool barrierDismissible;
  final BoxDecoration boxDecoration;
  final BoxDecoration? targetBoxDecoration;
  final Size? size;
  final Size targetSize;
  final Alignment targetAlignment;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? targetPadding;
  final Widget? targetChild;
  final void Function()? onTransitionComplete;
  final void Function()? onClose;

  @override
  State<OverlayExpandable> createState() => _OverlayExpandableState();
}

class _OverlayExpandableState extends State<OverlayExpandable> with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  ValueNotifier<AnimationStatus?> animationStatus = ValueNotifier(
    AnimationStatus.dismissed,
  );

  GlobalKey originKey = GlobalKey();
  GlobalKey destinationKey = GlobalKey();

  Offset originOffset = const Offset(0, 0);
  Offset destinationOffset = const Offset(0, 0);

  Size originSize = const Size(0, 0);
  Size destinationSize = const Size(0, 0);

  SizeTween sizeTween = SizeTween(
    begin: const Size(0, 0),
    end: const Size(0, 0),
  );

  Tween<Offset> offsetTween = Tween<Offset>(
    begin: const Offset(0, 0),
    end: const Offset(0, 0),
  );
  @override
  void initState() {
    super.initState();

    widget.transitionController._triggerStart = () => startTransition(
      widget: widget,
    );

    widget.transitionController._triggerClose = () => closeTransition();

    animationController = AnimationController(vsync: this);

    animationController.addStatusListener(
      (status) {
        animationStatus.value = status;
        if (status == AnimationStatus.dismissed) {
          _overlayPortalController.hide();
          widget.onClose?.call();
        }

        if (status == AnimationStatus.completed) {
          widget.onTransitionComplete?.call();
        }
      },
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  final OverlayPortalController _overlayPortalController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    final duration = widget.duration;

    animationController.duration = duration;
    BoxDecoration boxDecoration = widget.boxDecoration;

    final initialSize = widget.size;

    final animation = CurvedAnimation(
      parent: animationController,
      curve: widget.curve,
    );

    animationController.duration = duration;
    final barrierColor = widget.barrierColor;
    final barrierDismissible = widget.barrierDismissible;

    BoxDecoration targetBoxDecoration = widget.targetBoxDecoration ?? boxDecoration;

    final targetSize = widget.targetSize;
    final targetAlignment = widget.targetAlignment;

    final decorationTween = DecorationTween(
      begin: boxDecoration,
      end: targetBoxDecoration,
    );

    return ValueListenableBuilder(
      valueListenable: animationStatus,
      builder: (context, value, child) {
        return OverlayPortal(
          controller: _overlayPortalController,
          overlayChildBuilder: (context) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                closeTransition();
              },
              child: Center(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _AnimatedModalBarrier(
                      listenable: animation,
                      barrierDismissible: barrierDismissible,
                      barrierColor: barrierColor,
                      onDismiss: () {
                        closeTransition();
                      },
                    ),

                    Align(
                      alignment: targetAlignment,
                      child: Container(
                        key: destinationKey,
                        width: targetSize.width,
                        height: targetSize.height,
                        color: Colors.transparent,
                      ),
                    ),

                    ValueListenableBuilder(
                      valueListenable: animationStatus,
                      builder: (context, value, child) {
                        if (value == null) return const SizedBox.shrink();
                        if (value == AnimationStatus.dismissed) {
                          return const SizedBox.shrink();
                        }
                        return _AnimatedCarrier(
                          padding: widget.targetPadding,
                          sizeTween: sizeTween,
                          offsetTween: offsetTween,
                          decorationTween: decorationTween,
                          listenable: animation,
                          child: widget.targetChild,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Opacity(
            opacity: value == AnimationStatus.dismissed ? 1 : 0,
            child: Ink(
              key: originKey,
              padding: widget.padding,
              width: initialSize?.width,
              height: initialSize?.height,
              decoration: boxDecoration,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  void startTransition({required OverlayExpandable widget}) {
    if (_overlayPortalController.isShowing) return;
    _overlayPortalController.show();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final destinationRenderBox = destinationKey.currentContext!.findRenderObject() as RenderBox;
      final originRenderBox = originKey.currentContext!.findRenderObject() as RenderBox;

      final destinationScreenPos = destinationRenderBox.localToGlobal(
        Offset.zero,
      );
      final originScreenPos = originRenderBox.localToGlobal(
        Offset.zero,
      );

      originOffset = originScreenPos;
      destinationOffset = destinationScreenPos;

      originSize = originRenderBox.size;
      destinationSize = destinationRenderBox.size;

      sizeTween = SizeTween(begin: originSize, end: destinationSize);
      offsetTween = Tween<Offset>(
        begin: originOffset,
        end: destinationOffset,
      );

      animationController.forward(from: 0);
    });

    return;
  }

  void closeTransition() {
    animationController.reverse();
  }
}

class _AnimatedModalBarrier extends AnimatedWidget {
  const _AnimatedModalBarrier({
    required super.listenable,
    required this.barrierDismissible,
    required this.barrierColor,
    this.onDismiss,
  });

  final void Function()? onDismiss;

  final bool barrierDismissible;
  final Color barrierColor;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;

    final clampledOpacity = animation.value.clamp(0, 1);
    return Opacity(
      opacity: clampledOpacity.toDouble(),
      child: ModalBarrier(
        dismissible: barrierDismissible,
        color: barrierColor,
        onDismiss: onDismiss,
      ),
    );
  }
}

class _AnimatedCarrier extends AnimatedWidget {
  const _AnimatedCarrier({
    required super.listenable,
    required this.sizeTween,
    required this.offsetTween,
    required this.decorationTween,
    this.padding,
    this.child,
  });

  final SizeTween sizeTween;
  final Tween<Offset> offsetTween;
  final DecorationTween decorationTween;
  final Widget? child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;

    final size = sizeTween.evaluate(animation) as Size;
    final offset = offsetTween.evaluate(animation);
    final boxDecoration = decorationTween.evaluate(animation) as BoxDecoration;

    final targetChild = animation.isCompleted ? child : null;

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size.width,
        height: size.height,
        padding: padding,
        decoration: boxDecoration,
        child: targetChild,
      ),
    );
  }
}
