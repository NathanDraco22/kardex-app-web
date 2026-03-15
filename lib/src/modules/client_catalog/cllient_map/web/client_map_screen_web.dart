import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_list/cubit/client_read_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/map/map_nic_widget.dart';
import 'package:kardex_app_front/widgets/map/marker_point.dart';
import 'package:latlong2/latlong.dart';

import '../../../../domain/repositories/repositories.dart';

class ClientMapScreenWeb extends StatelessWidget {
  const ClientMapScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final clientRepo = context.read<ClientsRepository>();
    final clientGroupRepo = context.read<ClientGroupsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadClientCubit(clientRepo, clientGroupRepo)..loadAllClients()),
      ],
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de clientes"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final readClientCubit = context.watch<ReadClientCubit>();
    final state = readClientCubit.state;

    if (state is ReadClientLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is! ReadClientSuccess) {
      return Center(child: Text("Unexpected state: $state"));
    }

    return const Center(
      child: _Map(),
    );
  }
}

class _Map extends StatelessWidget {
  const _Map();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    if (authState is! Authenticated) {
      return const Center(child: Text("No autorizado"));
    }

    final currentBranch = authState.branch;

    final branchCoords = currentBranch.coordinates;

    final readClientCubit = context.watch<ReadClientCubit>();
    final state = readClientCubit.state as ReadClientSuccess;

    final clientMarkers = _buildMarkers(context, state.clients);

    LatLng? initCenter;
    if (branchCoords != null) {
      initCenter = LatLng(branchCoords.latitude, branchCoords.longitude);
    }

    return MapNicWidget(
      initialCenter: initCenter,
      markers: [...clientMarkers],
      showCenterPin: false,
    );
  }

  Iterable<Marker> _buildMarkers(BuildContext context, List<ClientInDb> clients) sync* {
    for (var client in clients) {
      if (client.coordinates != null) {
        yield Marker(
          point: LatLng(client.coordinates!.latitude, client.coordinates!.longitude),
          child: MarkerPoint(
            title: client.name,
            onTap: () => showClientFullDetailsDialog(context, client: client),
          ),
        );
      }
    }
  }
}
