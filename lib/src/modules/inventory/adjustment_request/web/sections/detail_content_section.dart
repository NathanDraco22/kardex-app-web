part of '../adjustment_request_detail_web_screen.dart';

class _DetailContentSection extends StatelessWidget {
  const _DetailContentSection({required this.request});

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: AdjustmentRequestItemTable(items: request.items),
    );
  }
}
