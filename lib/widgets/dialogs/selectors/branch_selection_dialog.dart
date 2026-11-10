import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

Future<BranchInDb?> showBranchSelectionDialog(
  BuildContext context,
  List<BranchInDb> branches, {
  String? currentBranchId,
}) async {
  return showDialog<BranchInDb?>(
    context: context,
    builder: (context) => BranchSelectionDialog(
      branches: branches,
      currentBranchId: currentBranchId,
    ),
  );
}

class BranchSelectionDialog extends StatelessWidget {
  const BranchSelectionDialog({
    super.key,
    required this.branches,
    this.currentBranchId,
  });

  final List<BranchInDb> branches;
  final String? currentBranchId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(
              isMultiBranch: branches.length > 1,
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: AppThemeTokens.borderLight),
            if (branches.isEmpty)
              const _EmptyState()
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: branches.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    return _BranchOptionTile(
                      branch: branch,
                      isCurrent: branch.id == currentBranchId,
                      onTap: () => Navigator.of(context).pop(branch),
                    );
                  },
                ),
              ),
            _DialogFooter(onCancel: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.isMultiBranch,
    required this.onClose,
  });

  final bool isMultiBranch;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppThemeTokens.indigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppThemeTokens.indigo.withValues(alpha: 0.14),
              ),
            ),
            child: Icon(
              isMultiBranch
                  ? Icons.swap_horiz_rounded
                  : Icons.storefront_rounded,
              color: AppThemeTokens.indigo,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Seleccionar sucursal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Elige la sucursal con la que quieres trabajar.",
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.3,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: "Cerrar",
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 20),
            color: Colors.grey.shade500,
            splashRadius: 20,
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchOptionTile extends StatefulWidget {
  const _BranchOptionTile({
    required this.branch,
    required this.isCurrent,
    required this.onTap,
  });

  final BranchInDb branch;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  State<_BranchOptionTile> createState() => _BranchOptionTileState();
}

class _BranchOptionTileState extends State<_BranchOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;
    final accent = branch.isCommerce
        ? const Color(0xFFD97706)
        : const Color(0xFF475569);
    final borderColor = widget.isCurrent
        ? AppThemeTokens.teal.withValues(alpha: 0.35)
        : _isHovered
        ? accent.withValues(alpha: 0.30)
        : AppThemeTokens.borderLight;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: widget.isCurrent ? 1.4 : 1.0,
          ),
          boxShadow: _isHovered
              ? AppThemeTokens.hoverCardShadow(accent: accent)
              : AppThemeTokens.subtleCardShadow(),
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: accent.withValues(alpha: 0.08),
            highlightColor: accent.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  BranchAvatar(branch: branch),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                branch.name.trim().isEmpty
                                    ? "Sucursal"
                                    : branch.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (widget.isCurrent) ...[
                              const SizedBox(width: 6),
                              const _CurrentBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branch.address.trim().isEmpty
                              ? "Sin dirección registrada"
                              : branch.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _BranchTypeBadge(
                          isCommerce: branch.isCommerce,
                          color: accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _isHovered ? accent : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchTypeBadge extends StatelessWidget {
  const _BranchTypeBadge({
    required this.isCommerce,
    required this.color,
  });

  final bool isCommerce;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppThemeTokens.borderRadiusFull,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCommerce ? Icons.storefront_rounded : Icons.warehouse_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isCommerce ? "Comercio" : "Almacén",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: AppThemeTokens.borderRadiusFull,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 11,
            color: AppThemeTokens.teal,
          ),
          SizedBox(width: 3),
          Text(
            "Actual",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppThemeTokens.teal,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: AppThemeTokens.borderLight),
            ),
            child: Icon(
              Icons.store_mall_directory_outlined,
              size: 26,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "No hay sucursales disponibles",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppThemeTokens.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }
}
