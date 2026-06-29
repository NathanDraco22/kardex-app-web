import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/widgets/custom_order_list_tile.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class CurrentOrdersWebScreen extends StatelessWidget {
  const CurrentOrdersWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,

          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: _HeaderSection(),
            ),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
