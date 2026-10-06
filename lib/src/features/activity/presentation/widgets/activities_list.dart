import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_borders.dart';
import '../../../../extensions/context_extension.dart';
import '../providers/activity_bloc.dart';

class ActivitiesList extends StatelessWidget {
  final int farmId;
  const ActivitiesList({super.key, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: context.colors.error),
                SizedBox(height: AppSpacing.sm),
                Text(
                  state.errorMessage,
                  style: context.typography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                FilledButton.tonal(
                  onPressed: () => context
                      .read<ActivityBloc>()
                      .add(FetchActivitiesEvent(farmId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state.activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_outline_rounded,
                    size: 48,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No employees yet',
                  style: context.typography.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Add an employee to get started.',
                  style: context.typography.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: state.activities.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final emp = state.activities[index];
            final initial =
                emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?';
            final isDark = context.isDarkMode;
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
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFF2E7D32)
                                        .withOpacity(0.12),
                                    child: Text(
                                      initial,
                                      style: context.typography.titleMedium
                                          ?.copyWith(
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp.name,
                                          style: context.typography.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1A2E1B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              size: 12,
                                              color: context
                                                  .colors.onSurfaceVariant
                                                  .withOpacity(0.7),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                emp.email,
                                                style: context
                                                    .typography.bodySmall
                                                    ?.copyWith(
                                                  color: context
                                                      .colors.onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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

                              // Bottom info row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Grade badge
                                  if (emp.grade != null &&
                                      emp.grade!.trim().isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E7D32)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.badge_outlined,
                                              size: 12,
                                              color: Color(0xFF2E7D32)),
                                          const SizedBox(width: 4),
                                          Text(
                                            emp.grade!,
                                            style: context.typography.labelSmall
                                                ?.copyWith(
                                              color: const Color(0xFF2E7D32),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),

                                  // Date assigned
                                  if (emp.assignedDate != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 12,
                                          color: context.colors.onSurfaceVariant
                                              .withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          emp.assignedDate!.split('T').first,
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

                              // Phone number row if present
                              if (emp.phoneNumber != null &&
                                  emp.phoneNumber!.trim().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      size: 12,
                                      color: context.colors.onSurfaceVariant
                                          .withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      emp.phoneNumber!,
                                      style: context.typography.bodySmall
                                          ?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                        fontSize: 11,
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
}
