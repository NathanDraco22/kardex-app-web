part of '../home_screen.dart';

class _HomeDesktopBody extends StatelessWidget {
  final String firstName;
  final BranchInDb? currentBranch;

  const _HomeDesktopBody({
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            const Text(
              "Módulos del Sistema",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allowedOptions.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisExtent: 108,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeader = constraints.maxWidth < 680;

        final greetingWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  "Bienvenido/a, $firstName",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Text("👋", style: TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Selecciona un módulo para gestionar las operaciones de tu negocio.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );

        if (currentBranch == null) {
          return greetingWidget;
        }

        final branchWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: currentBranch!.isCommerce
                      ? Colors.amber.shade50
                      : Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(12),
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
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentBranch!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentBranch!.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );

        if (isCompactHeader) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              greetingWidget,
              const SizedBox(height: 16),
              branchWidget,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: greetingWidget),
            const SizedBox(width: 20),
            branchWidget,
          ],
        );
      },
    );
  }
}
