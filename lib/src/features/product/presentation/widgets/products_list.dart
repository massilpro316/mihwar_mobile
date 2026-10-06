import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mihwar/src/imports/core_imports.dart';
import '../providers/product_bloc.dart';
import '../widgets/add_product_form.dart';

class ProductsList extends StatelessWidget {
  final int farmId;
  const ProductsList({super.key, required this.farmId});

  /// Opens the "add a product" sheet.
  ///
  /// It fills most of the screen and carries its own title, so it reads as a
  /// page rather than a panel that might slide away. A drag handle is not
  /// enough of an exit on its own — the form ends with a labelled Close button.
  static void showAddProductBottomSheet(BuildContext context, int farmId) {
    final productBloc = context.read<ProductBloc>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Tapping the dim area outside would silently discard a half-filled
      // form, so it does nothing.
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.96,
          expand: false,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: ctx.colors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.lg),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _SheetHeader(onClose: () => Navigator.of(ctx).pop()),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: AppSpacing.ml,
                      right: AppSpacing.ml,
                      top: AppSpacing.ml,
                      bottom:
                          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
                    ),
                    child: AddProductForm(
                      farmId: farmId,
                      productBloc: productBloc,
                      onSuccess: () {
                        // Refreshes products list upon creation
                        productBloc.add(FetchProductsEvent(farmId));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final accentGreen =
        isDark ? const Color(0xFF43A047) : const Color(0xFF2E7D32);

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: context.colors.error),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    state.errorMessage,
                    style: context.typography.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  FilledButton.tonal(
                    onPressed: () => context
                        .read<ProductBloc>()
                        .add(FetchProductsEvent(farmId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state.products.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3320)
                          : context.colors.primaryContainer.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: accentGreen,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No products yet',
                    style: context.typography.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add a product to keep track of farm stock.',
                    style: context.typography.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // AppButton(
                  //   label: 'Add First Product',
                  //   onPressed: () => showAddProductBottomSheet(context, farmId),
                  // ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: state.products.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final product = state.products[index];
            final cardBg = isDark ? const Color(0xFF1E3220) : Colors.white;
            final borderColor = isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05);

            return Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Accent indicator bar
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [accentGreen, accentGreen.withOpacity(0.5)],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Brand + Material section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: accentGreen.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.eco_rounded,
                                      color: accentGreen,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.brand,
                                          style: context.typography.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1A2E1B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          product.materialType,
                                          style: context.typography.bodySmall
                                              ?.copyWith(
                                            color:
                                                context.colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // IconButton(
                                  //   icon: Icon(
                                  //     Icons.delete_outline_rounded,
                                  //     color: context.colors.error
                                  //         .withOpacity(0.8),
                                  //     size: 20,
                                  //   ),
                                  //   onPressed: () =>
                                  //       _confirmDelete(context, product.id),
                                  // ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.md),
                              Divider(
                                height: 1,
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.05),
                              ),
                              SizedBox(height: AppSpacing.md),

                              // Detailed attributes grid
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Quantity pill badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: accentGreen.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.inventory_2_outlined,
                                            size: 13, color: accentGreen),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${product.quantity} ${product.quantityUnit ?? ''}',
                                          style: context.typography.labelMedium
                                              ?.copyWith(
                                            color: accentGreen,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Date metadata
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: context.colors.onSurfaceVariant
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(product.creationDate),
                                        style: context.typography.bodySmall
                                            ?.copyWith(
                                          color:
                                              context.colors.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              if (product.employeeName != null &&
                                  product.employeeName!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline_rounded,
                                      size: 13,
                                      color: context.colors.onSurfaceVariant
                                          .withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Added by: ${product.employeeName}',
                                      style: context.typography.bodySmall
                                          ?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int productId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_outline_rounded,
            color: Theme.of(ctx).colorScheme.error),
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductBloc>().add(
                    RemoveProductEvent(context: context, id: productId),
                  );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Add-product sheet header ─────────────────────────────────────────────────

/// The sheet's own title bar: a big icon, the title, a one-line explanation of
/// what the form is for, and a close button that is a labelled 48 dp target
/// rather than a bare ✕.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.ml,
        AppSpacing.ml,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant, width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.onPrimaryContainer.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.ms),
            ),
            child: Icon(
              Icons.add_box_rounded,
              size: 32,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'product.add_title'.tr(),
                  style: context.typography.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onPrimaryContainer,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'product.add_subtitle'.tr(),
                  style: context.typography.bodyLarge?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'product.close'.tr(),
            child: IconButton(
              iconSize: 32,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              tooltip: 'product.close'.tr(),
              onPressed: () {
                HapticFeedback.selectionClick();
                onClose();
              },
              icon: Icon(
                Icons.close_rounded,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
