part of '../current_devolutions_web_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Flexible(fit: FlexFit.tight, child: Row()),
            SizedBox(
              height: 70,
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Cliente",
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 6),
                        CustomAutocompleteTextfield<ClientInDb>(
                          titleBuilder: (value) => value.name,
                          onSearch: (value) async {
                            final repo = context.read<ClientsRepository>();
                            try {
                              final res = await repo.searchClientByKeyword(value);
                              return res;
                            } catch (e) {
                              return [];
                            }
                          },
                          suggestionBuilder: (value, close) {
                            return ListView.builder(
                              itemCount: value.length,
                              itemBuilder: (context, index) {
                                final client = value[index];
                                return ListTile(
                                  title: Text(client.name),
                                  onTap: () {
                                    close(client);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
