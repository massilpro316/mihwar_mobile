import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../domain/entities/farm_entity.dart';
import '../../../product/presentation/providers/product_bloc.dart';
import '../../../product/presentation/widgets/products_list.dart';
import '../../../task/presentation/providers/task_bloc.dart';
import '../../../task/presentation/widgets/tasks_list.dart';
import '../../../../core/di/injection_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WORKERS / EMPLOYEES SECTION — still disabled.
//
// The section picker below was written for workers-vs-products and is now used
// for products-vs-tasks. To bring the workers list back, add a third value to
// `_FarmSection` and a third `_SectionButton` — but note the picker is a Row of
// equal-width buttons, so three of them will need to become a Wrap to survive a
// 200% font scale.
// ─────────────────────────────────────────────────────────────────────────────

/// Which list the farm screen is currently showing.
enum _FarmSection { products, tasks }

/// One farm: the products stored on it, and the tasks assigned to the
/// signed-in employee for it.
class FirmDetailScreen extends StatefulWidget {
  final FarmEntity farm;
  const FirmDetailScreen({super.key, required this.farm});

  @override
  State<FirmDetailScreen> createState() => _FirmDetailScreenState();
}

class _FirmDetailScreenState extends State<FirmDetailScreen> {
  _FarmSection _section = _FarmSection.products;

  void _select(_FarmSection section) {
    if (_section == section) return;
    HapticFeedback.selectionClick();
    setState(() => _section = section);
  }

  @override
  Widget build(BuildContext context) {
    final isTasks = _section == _FarmSection.tasks;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<ProductBloc>()..add(FetchProductsEvent(widget.farm.id)),
        ),
        // Scoped to this farm: the tasks endpoint already limits an Agriculture
        // session to its own assignments, so this is "my tasks, here".
        BlocProvider(
          create: (_) => getIt<TaskBloc>()
            ..add(FetchTasksEvent(stationId: widget.farm.id)),
        ),
      ],
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppTopBar(
          title: widget.farm.name,
          // Reloading belongs to the tasks list, which is the only thing on
          // this screen that can fail to arrive. `actions` is mirrored to the
          // left edge in Arabic, so it lands in the corner opposite the back
          // arrow. The Builder is what reaches the TaskBloc created below.
          actions: isTasks
              ? [
                  Builder(
                    builder: (innerContext) => RetryIconButton(
                      onPressed: () => innerContext.read<TaskBloc>().add(
                            FetchTasksEvent(stationId: widget.farm.id),
                          ),
                    ),
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _SectionPicker(section: _section, onSelect: _select),

              // Names what is on screen, so the list is never just an unlabelled
              // pile of rows under the farm's name.
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.ml,
                  AppSpacing.md,
                  AppSpacing.ml,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      isTasks
                          ? Icons.assignment_rounded
                          : Icons.inventory_2_rounded,
                      size: 30.r,
                      color: context.colors.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isTasks
                            ? 'task.my_tasks_here'.tr()
                            : 'farm.products_tab'.tr(),
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: isTasks
                    ? TasksList(stationId: widget.farm.id)
                    : ProductsList(farmId: widget.farm.id),
              ),
            ],
          ),
        ),

        // Adding a product is the one action on this screen, and it belongs to
        // the products list — on the tasks list it would be an unrelated button
        // sitting under someone else's content, so it is hidden there.
        bottomNavigationBar: isTasks
            ? null
            : SafeArea(
                minimum: EdgeInsets.all(AppSpacing.ml),
                child: Builder(
                  builder: (innerContext) => AppButton(
                    label: 'farm.add_product'.tr(),
                    prefixIcon: Icon(Icons.add_rounded, size: 30.r),
                    height: ButtonSize.large,
                    isFullWidth: true,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ProductsList.showAddProductBottomSheet(
                        innerContext,
                        widget.farm.id,
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Section picker ───────────────────────────────────────────────────────────
//
// Two big, always-labelled buttons. The selected one is filled and stated in
// its semantics, so it is obvious which list is showing. Deliberately not a
// TabBar: tabs are swiped, and swiping is not a gesture this audience can rely
// on.

class _SectionPicker extends StatelessWidget {
  const _SectionPicker({required this.section, required this.onSelect});

  final _FarmSection section;
  final ValueChanged<_FarmSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ml,
        AppSpacing.md,
        AppSpacing.ml,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SectionButton(
              icon: Icons.inventory_2_rounded,
              label: 'farm.products_tab'.tr(),
              isSelected: section == _FarmSection.products,
              onTap: () => onSelect(_FarmSection.products),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _SectionButton(
              icon: Icons.assignment_rounded,
              label: 'task.tasks_tab'.tr(),
              isSelected: section == _FarmSection.tasks,
              onTap: () => onSelect(_FarmSection.tasks),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isSelected
        ? context.colors.primary
        : context.colors.surfaceContainerLow;
    final foreground =
        isSelected ? context.colors.onPrimary : context.colors.onSurface;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.ms),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.ms),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 64.h),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.ms,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.ms),
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.outline,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28.r, color: foreground),
                SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    label,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
