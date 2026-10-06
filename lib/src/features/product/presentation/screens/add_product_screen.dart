import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/features/product/presentation/providers/product_bloc.dart';
import 'package:mihwar/src/features/product/presentation/widgets/add_product_form.dart';
import 'package:mihwar/src/core/di/injection_container.dart';

class AddProductScreen extends StatelessWidget {
  final int farmId;
  const AddProductScreen({super.key, required this.farmId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A1A0B) : const Color(0xFFF7FAF7);

    return BlocProvider(
      create: (_) => getIt<ProductBloc>(),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          title: Text(
            'Add Product',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A2E1B),
            ),
          ),
        ),
        body: Builder(
          builder: (context) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Intro header card
                    Container(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      margin: EdgeInsets.only(bottom: AppSpacing.lg),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF112513),
                                  const Color(0xFF1A3A1B)
                                ]
                              : [
                                  const Color(0xFFE8F5E9),
                                  const Color(0xFFC8E6C9)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: Color(0xFF2E7D32),
                              size: 32,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Inventory',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A2E1B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Add materials to keep farm tracking accurate.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AddProductForm(
                      farmId: farmId,
                      productBloc: context.read<ProductBloc>(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
