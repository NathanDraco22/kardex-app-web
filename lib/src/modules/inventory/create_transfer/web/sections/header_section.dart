part of '../create_transfer_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SelectBranchButton(),
                  ],
                ),

                SizedBox(
                  width: 200,
                  child: TitleTextField(
                    title: "Observaciones",
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectBranchButton extends StatelessWidget {
  const _SelectBranchButton();

  @override
  Widget build(BuildContext context) {
    BranchInDb? branch;
    return StatefulBuilder(
      builder: (context, setState) {
        final title = branch?.name ?? "Seleccionar Sucursal";
        return SizedBox(
          width: 200,
          child: InkWell(
            onTap: () async {
              final res = await showBranchSelectionDialog(context, BranchesTool.branches);
              if (res == null) return;
              if (res.id == BranchesTool.getCurrentBranchId()) return;
              branch = res;
              setState(() {});
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sucursal Destino",
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
