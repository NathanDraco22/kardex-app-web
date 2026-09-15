part of '../home_screen.dart';

class _HomeTabletBody extends StatelessWidget {
  final String firstName;
  final BranchInDb? currentBranch;

  const _HomeTabletBody({
    required this.firstName,
    this.currentBranch,
  });

  @override
  Widget build(BuildContext context) {
    final allowedOptions = getHomeOptions(context, currentBranch).where((opt) {
      return opt.permissions.any(
        (p) => AccessManager().hasCurrentAccess(context, p.name),
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        if (currentBranch != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: currentBranch!.isCommerce
                        ? Colors.amber.shade50
                        : Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: currentBranch!.isCommerce
                          ? Colors.amber.shade200
                          : Colors.blueGrey.shade200,
                    ),
                  ),
                  child: Icon(
                    currentBranch!.isCommerce
                        ? FluentIcons.building_shop_24_filled
                        : Icons.warehouse_rounded,
                    color: currentBranch!.isCommerce
                        ? Colors.amber.shade800
                        : Colors.blueGrey.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentBranch!.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        currentBranch!.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          "Bienvenido/a, $firstName",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Elige una opción para continuar",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allowedOptions.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            mainAxisExtent: 104,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final option = allowedOptions[index];
            return HomeDesktopOptionCard(
              title: option.title,
              subtitle: option.subtitle,
              icon: option.icon,
              accentColor: option.accentColor,
              onTap: option.onTap,
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
