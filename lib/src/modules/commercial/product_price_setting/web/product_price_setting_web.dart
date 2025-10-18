import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/modules/commercial/product_price_setting/web/product_price_detail.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

import '../cubit/read_product_sale_profile_cubit.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class ProductPriceSettingWeb extends StatelessWidget {
  const ProductPriceSettingWeb({super.key});

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
    final readCubit = context.watch<ReadProductSaleProfileCubit>();
    final state = readCubit.state;

    if (state is ReadProductSaleProfileLoading || state is ReadProductSaleProfileInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReadProductSaleProfileError) {
      return Center(child: Text(state.message));
    }

    state as ReadProductSaleProfileSuccess;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      flex: 2,
                      child: SearchFieldDebounced(
                        onSearch: (value) {
                          readCubit.searchProfile(value);
                        },
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const Expanded(
                child: _ContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
