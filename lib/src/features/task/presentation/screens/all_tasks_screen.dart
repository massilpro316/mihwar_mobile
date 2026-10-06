import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../../../core/di/injection_container.dart';
import '../providers/task_bloc.dart';
import '../widgets/tasks_list.dart';

/// Every task the employee has, across every farm they work on.
///
/// A bottom-nav destination, so it has no back arrow — the nav bar is the way
/// out. The farm name is shown on each card here, because the same job ("water
/// the rows") can be waiting on more than one farm.
class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskBloc>()..add(const FetchTasksEvent()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: context.colors.surface,
          title: Text(
            'task.all_tasks_title'.tr(),
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          // Same corner as inside a farm, so reloading tasks is in one place
          // wherever the list is being read. `actions` sits on the left in
          // Arabic; the Builder is what reaches the TaskBloc created above.
          actions: [
            Builder(
              builder: (innerContext) => RetryIconButton(
                onPressed: () =>
                    innerContext.read<TaskBloc>().add(const FetchTasksEvent()),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const _PendingSummary(),
              const Expanded(
                child: TasksList(showFarmName: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plain sentence saying how much is still waiting, so the employee knows
/// where they stand without counting the cards themselves.
class _PendingSummary extends StatelessWidget {
  const _PendingSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state.isLoading || state.hasError || state.tasks.isEmpty) {
          return const SizedBox.shrink();
        }

        final pending = state.pendingCount;
        final allDone = pending == 0;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(
            AppSpacing.ml,
            AppSpacing.md,
            AppSpacing.ml,
            0,
          ),
          padding: EdgeInsets.all(AppSpacing.ml),
          decoration: BoxDecoration(
            color: allDone
                ? context.appColors.success.withOpacity(0.12)
                : context.colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.ml),
          ),
          child: Row(
            children: [
              Icon(
                allDone
                    ? Icons.celebration_rounded
                    : Icons.pending_actions_rounded,
                size: 34.r,
                color: allDone
                    ? context.appColors.success
                    : context.colors.onPrimaryContainer,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  allDone
                      ? 'task.all_done'.tr()
                      : 'task.pending_count'.tr(args: ['$pending']),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: allDone
                        ? context.colors.onSurface
                        : context.colors.onPrimaryContainer,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
