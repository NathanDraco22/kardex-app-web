import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_actions.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_item_table.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_status_chip.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adjust_entry_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adjust_exit_viewer.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';
import 'package:kardex_business/kardex_business.dart';

part 'sections/detail_header_section.dart';
part 'sections/detail_content_section.dart';

class AdjustmentRequestDetailWebScreen extends StatelessWidget {
  const AdjustmentRequestDetailWebScreen({
    super.key,
    required this.request,
  });

  final AdjustmentRequestInDb request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitud ${request.docNumber}'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 172,
                child: _DetailHeaderSection(request: request),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _DetailContentSection(request: request),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
