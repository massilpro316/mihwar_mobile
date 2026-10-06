import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_bloc.dart';
import 'task_filter_bar.dart';
import 'task_visuals.dart';

/// The employee's own tasks, as a plain vertical list of large cards, with a
/// search box and status buttons on top. Tapping a card opens its own page.
///
/// Used in two places with the same code: inside one farm (`stationId` set, the
/// farm name is already in the app bar so it is not repeated on every card) and
/// across every farm (`stationId` null, where the farm name is the thing that
/// tells two similar tasks apart).
class TasksList extends StatelessWidget {
  const TasksList({super.key, this.stationId, this.showFarmName = false});

  /// Null means "every farm this employee works on".
  final int? stationId;
  final bool showFarmName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        void reload() =>
            context.read<TaskBloc>().add(FetchTasksEvent(stationId: stationId));

        // Loading says what is happening — a bare spinner tells this audience
        // nothing about whether the app is stuck.
        if (state.isLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: AppLoading(message: 'task.loading'.tr()),
            ),
          );
        }

        // Two different problems, two different things to do about them. The
        // underlying `failure.message` is never shown — it can contain a Dio
        // string, and "DioException" means nothing to a farmer.
        //
        // No `onRetry`: the way to try again is the refresh icon in the top
        // corner of the screen, which is on screen in every state, and the
        // body copy points at it.
        if (state.hasError) {
          return AppErrorWidget(
            icon: state.isOffline
                ? Icons.wifi_off_rounded
                : Icons.cloud_off_rounded,
            title: state.isOffline
                ? 'task.error_offline_title'.tr()
                : 'task.error_server_title'.tr(),
            message: state.isOffline
                ? 'task.error_offline_body'.tr()
                : 'task.error_server_body'.tr(),
          );
        }

        if (state.tasks.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_turned_in_outlined,
            title: 'task.empty_title'.tr(),
            subtitle: showFarmName
                ? 'task.empty_body_all'.tr()
                : 'task.empty_body_farm'.tr(),
          );
        }

        final tasks = state.visible;

        // Pull-to-refresh is offered, but never as the only way — the refresh
        // icon in the top corner is the button equivalent, for anyone who does
        // not know that dragging a screen downwards does anything.
        //
        // The search box and status buttons are the first row of the list, so
        // on a small phone they scroll away with it instead of pinning half the
        // screen.
        return RefreshIndicator(
          onRefresh: () async => reload(),
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.ml,
              AppSpacing.md,
              AppSpacing.ml,
              AppSpacing.xxl,
            ),
            itemCount: tasks.isEmpty ? 2 : tasks.length + 1,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              if (i == 0) return const TaskFilterBar();
              if (tasks.isEmpty) return const _NoMatch();
              return _TaskCard(
                task: tasks[i - 1],
                showFarmName: showFarmName,
              );
            },
          ),
        );
      },
    );
  }
}

/// Nothing matches the search or the chosen status — with one button that
/// undoes both, so nobody is stuck looking at an empty screen.
class _NoMatch extends StatelessWidget {
  const _NoMatch();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64.r,
            color: context.colors.primary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'task.no_match_title'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'task.no_match_body'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'task.show_all'.tr(),
            prefixIcon: Icon(Icons.list_alt_rounded, size: 28.r),
            variant: ButtonVariant.outline,
            height: ButtonSize.large,
            isFullWidth: true,
            onPressed: () {
              HapticFeedback.selectionClick();
              context.read<TaskBloc>()
                ..add(const TaskSearchChangedEvent(''))
                ..add(const TaskStatusFilterChangedEvent(null));
            },
          ),
        ],
      ),
    );
  }
}

/// One task. The whole card is one button that opens the task's own page,
/// where it can be completed, cancelled or given a note.
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.showFarmName});

  final TaskEntity task;
  final bool showFarmName;

  Future<void> _open(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final bloc = context.read<TaskBloc>();
    final updated = await context.push<TaskEntity>(
      AppRoutes.taskDetailPath(task.id),
      extra: task,
    );
    if (updated != null) bloc.add(TaskUpdatedEvent(updated));
  }

  @override
  Widget build(BuildContext context) {
    final accent = task.accent(context);
    final radius = BorderRadius.circular(AppSpacing.ml);

    // One spoken sentence for TalkBack, instead of six disconnected fragments.
    final semanticLabel = [
      task.title,
      task.statusLabel,
      if (showFarmName && task.stationName != null) task.stationName,
      if (task.dueDate != null)
        'task.due_on'.tr(args: [formatTaskDate(task.dueDate!)]),
      'task.open_task'.tr(),
    ].join('. ');

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Material(
          color: context.colors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            // Status colour on the border, so it is readable before a single
            // word is — and still spelled out below, because colour alone is
            // not a label.
            side: BorderSide(color: accent.withValues(alpha: 0.6), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            splashColor: accent.withValues(alpha: 0.18),
            onTap: () => _open(context),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.ml),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.ms),
                        ),
                        child: Icon(task.statusIcon, size: 30.r, color: accent),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          task.title,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      _OpenArrow(color: accent),
                    ],
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Status in words, never colour alone.
                  _Line(
                    icon: switch (task.status) {
                      TaskStatus.completed => Icons.check_rounded,
                      TaskStatus.cancelled => Icons.block_rounded,
                      TaskStatus.pending => Icons.hourglass_bottom_rounded,
                    },
                    text: task.statusLabel,
                    color: accent,
                    bold: true,
                  ),

                  SizedBox(height: AppSpacing.sm),
                  _Line(icon: task.typeIcon, text: task.typeLabel),

                  if (showFarmName && (task.stationName ?? '').isNotEmpty) ...[
                    SizedBox(height: AppSpacing.sm),
                    _Line(
                      icon: Icons.agriculture_rounded,
                      text: task.stationName!,
                    ),
                  ],

                  if (task.dueDate != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    _Line(
                      icon: Icons.event_rounded,
                      text: 'task.due_on'
                          .tr(args: [formatTaskDate(task.dueDate!)]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A filled circle around the arrow, so "this opens something" is visible
/// without reading.
class _OpenArrow extends StatelessWidget {
  const _OpenArrow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Icon(
        // Material's arrow icons do not mirror on their own.
        Directionality.of(context) == TextDirection.rtl
            ? Icons.arrow_back_ios_rounded
            : Icons.arrow_forward_ios_rounded,
        size: 20.r,
        color: color,
      ),
    );
  }
}

/// An icon paired with a word — never an icon on its own.
class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.text,
    this.color,
    this.bold = false,
  });

  final IconData icon;
  final String text;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28.r, color: color ?? context.colors.onSurface),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? context.colors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
