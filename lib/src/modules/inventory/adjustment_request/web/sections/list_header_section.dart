part of '../adjustment_request_list_web_screen.dart';

class _ListHeaderSection extends StatefulWidget {
  const _ListHeaderSection();

  @override
  State<_ListHeaderSection> createState() => _ListHeaderSectionState();
}

class _ListHeaderSectionState extends State<_ListHeaderSection> {
  late final TextEditingController _docNumberController;
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'all';
  UserInDb? _selectedUser;
  int _clearGeneration = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReadAdjustmentRequestsCubit>();
    _startDate = cubit.startDate;
    _endDate = cubit.endDate;
    _status = cubit.status ?? 'all';
    _docNumberController = TextEditingController(text: cubit.docNumber ?? '');
    final (isSeller, sellerUser) = RoleTools.isSeller();
    if (isSeller) _selectedUser = sellerUser;
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final docNumber = _docNumberController.text.trim();
    final (isSeller, sellerUser) = RoleTools.isSeller();
    context.read<ReadAdjustmentRequestsCubit>().applyFilters(
      startDate: _startDate,
      endDate: _endDate,
      status: _status == 'all' ? null : _status,
      createdBy: isSeller ? sellerUser?.id : _selectedUser?.id,
      docNumber: docNumber.isEmpty ? null : docNumber,
    );
  }

  void _clearFilters() {
    final cubit = context.read<ReadAdjustmentRequestsCubit>();
    final today = DateTimeTool.getTodayMidnight();
    final (isSeller, sellerUser) = RoleTools.isSeller();
    _docNumberController.clear();
    setState(() {
      _startDate = today.subtract(const Duration(days: 29));
      _endDate = today;
      _status = 'all';
      _selectedUser = isSeller ? sellerUser : null;
      _clearGeneration++;
    });
    cubit.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final (isSeller, _) = RoleTools.isSeller();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 190,
                  child: DatePickerListTile(
                    key: ValueKey('start_${_startDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                    defaultDate: _startDate,
                    title: 'Fecha inicio',
                    onSelected: (value) => setState(() => _startDate = value),
                  ),
                ),
                SizedBox(
                  width: 190,
                  child: DatePickerListTile(
                    key: ValueKey('end_${_endDate?.millisecondsSinceEpoch}_$_clearGeneration'),
                    defaultDate: _endDate,
                    title: 'Fecha fin',
                    onSelected: (value) => setState(() => _endDate = value),
                  ),
                ),
                if (!isSeller)
                  UserDropdownSelector(
                    width: 230,
                    selectedUser: _selectedUser,
                    onChanged: (user) => setState(() => _selectedUser = user),
                  ),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('status_${_status}_$_clearGeneration'),
                    initialValue: _status,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Todos')),
                      DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                      DropdownMenuItem(value: 'approved', child: Text('Aprobada')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelada')),
                    ],
                    onChanged: (value) => setState(() => _status = value ?? 'all'),
                  ),
                ),
                SizedBox(
                  width: 190,
                  child: TextField(
                    controller: _docNumberController,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      labelText: 'No. solicitud',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onSubmitted: (_) => _applyFilters(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                SecondaryMenuButton(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                  label: const Text('Limpiar'),
                ),
                PrimaryMenuButton(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_alt_rounded, size: 18),
                  label: const Text('Filtrar'),
                ),
                PrimaryMenuButton(
                  backgroundColor: AppThemeTokens.indigo,
                  foregroundColor: Colors.white,
                  onPressed: () => context.pushNamed(RouteNames.adjustmentRequestCreate),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nueva Solicitud'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
