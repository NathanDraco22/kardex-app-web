import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

class ProviderContainer extends StatelessWidget {
  const ProviderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clientDataSource = ClientsDataSource();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) {
            return ClientsRepository(clientDataSource);
          },
        ),
      ],
      child: child,
    );
  }
}
