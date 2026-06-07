part of '../home_screen.dart';

class _HomeWebBody extends StatelessWidget {
  final String firstName;
  final BranchInDb? currentBranch;

  const _HomeWebBody({
    required this.firstName,
    this.currentBranch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
        children: [
          if (currentBranch != null) ...[
            Text(
              currentBranch!.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              currentBranch!.address,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 4),
          Text(
            "Bienvenido/a, $firstName",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            "Elige una opcion",
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: getHomeOptions(context).map((option) {
              return RolePermissionGate(
                width: 300,
                height: 120,
                permissions: option.permissions,
                child: HomeOptionCard(
                  title: option.title,
                  icon: option.icon,
                  onTap: option.onTap,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
