import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import 'package:mihwar/src/features/product/domain/entities/product_entity.dart';
import 'package:mihwar/src/features/product/presentation/providers/product_bloc.dart';

/// The "add a product" form used inside the bottom sheet.
///
/// Every field asks a plain question ("What is this product?") instead of
/// naming a database column, every rule is explained in words rather than a
/// red asterisk, and both buttons are full width and 56 dp tall.
class AddProductForm extends StatefulWidget {
  final int farmId;
  final ProductBloc productBloc;
  final VoidCallback? onSuccess;

  const AddProductForm({
    super.key,
    required this.farmId,
    required this.productBloc,
    this.onSuccess,
  });

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _materialController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _materialController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submit() {
    // Show every problem at once, next to the field that caused it.
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    widget.productBloc.add(
      AddProductEvent(
        context: context,
        params: CreateProductParams(
          stationId: widget.farmId,
          brand: _brandController.text.trim(),
          quantity: double.parse(_quantityController.text.trim()),
          materialType: _materialController.text.trim(),
          quantityUnit: _unitController.text.trim().isEmpty
              ? null
              : _unitController.text.trim(),
        ),
      ),
    );
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      bloc: widget.productBloc,
      builder: (context, state) {
        return Form(
          key: _formKey,
          // Show errors as soon as a field is touched, not only on submit.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FieldLabel(
                step: 1,
                text: 'product.material'.tr(),
              ),
              AppTextField(
                controller: _materialController,
                label: 'product.material'.tr(),
                hint: 'product.material_hint'.tr(),
                prefixIcon: const Icon(Icons.category_outlined),
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'product.material_required'.tr()
                    : null,
              ),
              SizedBox(height: AppSpacing.ml),

              _FieldLabel(
                step: 2,
                text: 'product.brand'.tr(),
              ),
              AppTextField(
                controller: _brandController,
                label: 'product.brand'.tr(),
                hint: 'product.brand_hint'.tr(),
                prefixIcon: const Icon(Icons.sell_outlined),
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'product.brand_required'.tr()
                    : null,
              ),
              SizedBox(height: AppSpacing.ml),

              _FieldLabel(
                step: 3,
                text: 'product.quantity'.tr(),
              ),
              // One field per line — side-by-side fields halve the touch target
              // and push the error text into two cramped columns.
              AppTextField(
                controller: _quantityController,
                label: 'product.quantity'.tr(),
                hint: 'product.quantity_hint'.tr(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.numbers_rounded),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'product.quantity_required'.tr();
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'product.quantity_invalid'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _unitController,
                label: 'product.unit'.tr(),
                hint: 'product.unit_hint'.tr(),
                prefixIcon: const Icon(Icons.scale_outlined),
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'product.optional'.tr(),
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),

              SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'product.save'.tr(),
                prefixIcon: Icon(Icons.check_rounded, size: 28.r),
                isLoading: state.isSubmitting,
                isFullWidth: true,
                height: ButtonSize.large,
                onPressed: state.isSubmitting ? null : _submit,
              ),
              SizedBox(height: AppSpacing.ms),
              AppButton(
                label: 'product.close'.tr(),
                variant: ButtonVariant.outline,
                isFullWidth: true,
                height: ButtonSize.large,
                onPressed: state.isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A numbered question above each field.
///
/// The numbers turn a form into a sequence of small steps, which is far less
/// intimidating than four boxes appearing at once.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.step, required this.text});

  final int step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
