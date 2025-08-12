part of '../inventory_entry_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 380,
          child: Card(
            margin: EdgeInsets.zero,

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomAutocompleteTextfield<SupplierInDb>(
                    titleBuilder: (value) => value.name,
                    onSearch: (value) async {
                      final res = await context.read<SuppliersRepository>().searchSupplierByKeyword(value);
                      return res;
                    },
                    suggestionBuilder: (value, close) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final supplier = value[index];
                          return ListTile(
                            title: Text(supplier.name),
                            onTap: () {
                              close(supplier);
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Flexible(child: TitleTextField(title: "Documento")),
                      const SizedBox(width: 8),
                      Flexible(
                        child: DateFieldSelector(
                          onSelectedDate: (value) {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        const Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
