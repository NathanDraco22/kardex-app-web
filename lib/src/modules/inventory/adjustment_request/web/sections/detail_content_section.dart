part of '../adjustment_request_detail_web_screen.dart';

class _DetailContentSection extends StatelessWidget {
  const _DetailContentSection({required this.request});

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    return AdjustmentRequestItemTable(
      items: request.items,
      entryTotal: request.entryTotal,
      exitTotal: request.exitTotal,
    );
  }
}
