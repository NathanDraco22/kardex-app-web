part of '../daily_invoices_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;

  @override
  Widget build(BuildContext context) {
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    if (isSellerRole) {
      currentSelectedUser = userInDb;
    }

    final readCubit = context.read<ReadDailyAnonInvoicesCubit>();
    return Card(
      key: ValueKey(readCubit.state),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 70,
              width: 300,
              child: Row(
                children: [
                  Flexible(
                    child: DatePickerButton(
                      key: ValueKey(readCubit.startDate),
                      defaultDate: readCubit.startDate,
                      title: "Fecha",
                      onSelected: (value) {
                        readCubit.loadDailyPaidAnonInvoices(getIt<AuthCubit>().currentBranchId, startDate: value);
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  TextButton.icon(
                    onPressed: () {
                      readCubit.clearFilters();
                      if (!isSellerRole) {
                        currentSelectedUser = null;
                      }
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar"),
                  ),
                ],
              ),
            ),
            if (!isSellerRole) ...[
              const SizedBox(height: 8),
              UserDropdownSelector(
                width: 280,
                selectedUser: currentSelectedUser,
                onChanged: (user) {
                  currentSelectedUser = user;
                  readCubit.loadDailyPaidAnonInvoices(
                    getIt<AuthCubit>().currentBranchId,
                    userCreatorId: user?.id,
                  );
                  setState(() {});
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
