import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_detail_bloc.dart';
import '../widgets/task_action_sheet.dart';
import '../widgets/task_visuals.dart';

/// One task on a page of its own: everything about it, in plain labelled
/// lines, with the two things the employee can do at the bottom.
///
/// Pops with the updated [TaskEntity] when something was saved, so the list
/// behind it can swap the card in place.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskDetailBloc>(param1: task),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  const _TaskDetailView();

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
  /// A reopen has no sheet of its own to show an error in, so its failure is
  /// reported on this screen instead.
  bool _reopening = false;

  Future<void> _openSheet(TaskSheetMode mode) async {
    HapticFeedback.mediumImpact();
    await showTaskActionSheet(context, mode: mode);
  }

  Future<void> _confirmReopen() async {
    HapticFeedback.mediumImpact();
    final bloc = context.read<TaskDetailBloc>();

    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.replay_rounded,
          size: 40.r,
          color: ctx.colors.primary,
        ),
        title: Text(
          'task.reopen_title'.tr(),
          style: ctx.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        // Buttons live in the body, stacked full width, rather than in
        // `actions`, which squeezes them side by side at a small font size.
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'task.reopen_body'.tr(),
                style: ctx.textTheme.bodyLarge?.copyWith(
                  color: ctx.colors.onSurface,
                  height: 1.5,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'task.reopen_confirm'.tr(),
                prefixIcon: Icon(Icons.replay_rounded, size: 28.r),
                height: ButtonSize.large,
                isFullWidth: true,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'task.reopen_keep'.tr(),
                variant: ButtonVariant.outline,
                height: ButtonSize.large,
                isFullWidth: true,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
        ),
      ),
    );

    if (yes != true || !mounted) return;

    _reopening = true;
    // The note is sent back as it is: the server replaces the note on every
    // status change, and reopening should not quietly erase it.
    bloc.add(ChangeTaskStatusEvent(
      status: TaskStatus.pending,
      note: bloc.state.task.note,
    ));
  }

  void _onSubmissionChanged(BuildContext context, TaskDetailState state) {
    if (state.submission == TaskSubmission.success) {
      _reopening = false;
      final message = switch (state.lastAction) {
        TaskAction.completed => 'task.done_completed'.tr(),
        TaskAction.cancelled => 'task.done_cancelled'.tr(),
        TaskAction.reopened => 'task.done_reopened'.tr(),
        TaskAction.noteSaved => 'task.done_note'.tr(),
        null => null,
      };
      if (message != null) {
        context.showTypedSnackBar(
          message,
          type: SnackBarType.success,
          duration: const Duration(seconds: 6),
        );
      }
    } else if (state.submission == TaskSubmission.failure && _reopening) {
      _reopening = false;
      context.showTypedSnackBar(
        state.serverMessage ??
            (state.isOffline
                ? 'task.action_error_offline'.tr()
                : 'task.action_error_server'.tr()),
        type: SnackBarType.error,
        duration: const Duration(seconds: 8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailBloc, TaskDetailState>(
      listenWhen: (prev, curr) => prev.submission != curr.submission,
      listener: _onSubmissionChanged,
      builder: (context, state) {
        final task = state.task;

        // Hands the updated task back to the list on the way out — from the
        // top-bar arrow and from the system back gesture alike.
        return PopScope(
          canPop: !state.changed,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) Navigator.of(context).pop(state.task);
          },
          child: Scaffold(
            backgroundColor: context.colors.surface,
            appBar: AppTopBar(
              title: 'task.detail_title'.tr(),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.ml),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusBanner(task: task),
                    if (task.isStoppedByStation) ...[
                      SizedBox(height: AppSpacing.md),
                      _StoppedNotice(task: task),
                    ],
                    if (task.isCompletedByStation) ...[
                      SizedBox(height: AppSpacing.md),
                      _CompletedByNotice(task: task),
                    ],
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      task.title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.colors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    _Section(
                      icon: Icons.description_rounded,
                      title: 'task.what_to_do'.tr(),
                      child: _BodyText(
                        (task.description ?? '').trim().isNotEmpty
                            ? task.description!.trim()
                            : 'task.no_description'.tr(),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _Section(
                      icon: Icons.info_outline_rounded,
                      title: 'task.details'.tr(),
                      child: Column(
                        children: [
                          _Fact(
                            icon: task.typeIcon,
                            label: 'task.label_type'.tr(),
                            value: task.typeLabel,
                          ),
                          if ((task.stationName ?? '').trim().isNotEmpty)
                            _Fact(
                              icon: Icons.agriculture_rounded,
                              label: 'task.label_farm'.tr(),
                              value: task.stationName!,
                            ),
                          if (task.dueDate != null)
                            _Fact(
                              icon: Icons.event_rounded,
                              label: 'task.label_due'.tr(),
                              value: formatTaskDate(task.dueDate!),
                            ),
                          if ((task.createdByName ?? '').trim().isNotEmpty)
                            _Fact(
                              icon: Icons.person_rounded,
                              label: 'task.label_sent_by'.tr(),
                              value: task.createdByName!,
                            ),
                          if (task.createdAt != null)
                            _Fact(
                              icon: Icons.schedule_send_rounded,
                              label: 'task.label_sent_on'.tr(),
                              value: formatTaskDate(task.createdAt!),
                            ),
                          if (task.isDone && task.completedAt != null)
                            _Fact(
                              icon: Icons.task_alt_rounded,
                              label: 'task.label_done_on'.tr(),
                              value: formatTaskDate(task.completedAt!),
                            ),
                        ],
                      ),
                    ),
                    // Only on a completed task: a record left behind by a
                    // reopen is not what the task currently says was done.
                    if (task.isDone &&
                        (task.recordedProduct != null ||
                            task.recordedDose != null)) ...[
                      SizedBox(height: AppSpacing.md),
                      _Section(
                        icon: Icons.fact_check_rounded,
                        title: 'task.recorded_title'.tr(),
                        child: _RecordedFacts(task: task),
                      ),
                    ],
                    SizedBox(height: AppSpacing.md),
                    _Section(
                      icon: Icons.sticky_note_2_rounded,
                      title: 'task.your_note'.tr(),
                      child: _BodyText(
                        task.hasNote ? task.note!.trim() : 'task.no_note'.tr(),
                        muted: !task.hasNote,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: EdgeInsets.all(AppSpacing.ml),
              child: _Actions(
                task: task,
                busy: state.isSubmitting,
                onComplete: () => _openSheet(TaskSheetMode.complete),
                onCancel: () => _openSheet(TaskSheetMode.cancel),
                onNote: () => _openSheet(TaskSheetMode.note),
                onReopen: _confirmReopen,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Pieces ───────────────────────────────────────────────────────────────────

/// The status, big and in words, in the colour from the employee guide.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final accent = task.accent(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.ml),
        border: Border.all(color: accent, width: 2),
      ),
      child: Row(
        children: [
          Icon(task.statusIcon, size: 40.r, color: accent),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              task.statusLabel,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Ahmed stopped this task — no need to do it. Reason: …"
/// The station marked this task done for the employee.
class _CompletedByNotice extends StatelessWidget {
  const _CompletedByNotice({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.ms),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 32.r,
            color: context.appColors.success,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.completedByMessage,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                    height: 1.4,
                  ),
                ),
                if ((task.completionNote ?? '').trim().isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'task.completion_note'
                        .tr(args: [task.completionNote!.trim()]),
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.onSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoppedNotice extends StatelessWidget {
  const _StoppedNotice({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final reason = (task.cancelReason ?? '').trim();

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.ms),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.pan_tool_rounded, size: 32.r, color: context.colors.error),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.stoppedMessage,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onErrorContainer,
                    height: 1.4,
                  ),
                ),
                if (reason.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'task.stopped_reason'.tr(args: [reason]),
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.onErrorContainer,
                      height: 1.4,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.xs),
                Text(
                  'task.stopped_help'.tr(),
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.colors.onErrorContainer,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.ml),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 28.r, color: context.colors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          const AppDivider(),
          SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text, {this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color:
            muted ? context.colors.onSurfaceVariant : context.colors.onSurface,
        height: 1.5,
      ),
    );
  }
}

/// "Farm: Oasis farm" — a word before every value.
class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28.r, color: context.colors.primary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// What completing the task wrote to the farm: "Quantity: 20 kg".
class _RecordedFacts extends StatelessWidget {
  const _RecordedFacts({required this.task});

  final TaskEntity task;

  static String _withUnit(String quantity, String? unit) {
    final u = (unit ?? '').trim();
    return u.isEmpty ? quantity : '$quantity $u';
  }

  @override
  Widget build(BuildContext context) {
    final product = task.recordedProduct;
    final dose = task.recordedDose;

    return Column(
      children: [
        if (product != null) ...[
          if (product.materialType.trim().isNotEmpty)
            _Fact(
              icon: Icons.inventory_2_rounded,
              label: 'task.field_material_type'.tr(),
              value: product.materialType,
            ),
          if (product.brand.trim().isNotEmpty)
            _Fact(
              icon: Icons.sell_rounded,
              label: 'task.field_brand'.tr(),
              value: product.brand,
            ),
          _Fact(
            icon: Icons.scale_rounded,
            label: 'task.field_quantity'.tr(),
            value: _withUnit(product.quantity, product.quantityUnit),
          ),
          if (product.date != null)
            _Fact(
              icon: Icons.event_available_rounded,
              label: 'task.field_date'.tr(),
              value: formatTaskDateTime(product.date!.toLocal()),
            ),
        ],
        if (dose != null) ...[
          _Fact(
            icon: Icons.water_drop_rounded,
            label: 'task.field_dose_quantity'.tr(),
            value: dose.quantity,
          ),
          if (dose.date != null)
            _Fact(
              icon: Icons.event_available_rounded,
              label: 'task.field_date'.tr(),
              value: formatTaskDateTime(dose.date!.toLocal()),
            ),
        ],
      ],
    );
  }
}

/// The buttons at the bottom. Never more than two, and stacked rather than
/// side by side, so long Arabic or French labels and a large font never get
/// squeezed.
///
/// - Still to do → **Complete task** / **Cancel**
/// - Closed by the employee → **Add note** / **Reopen**
/// - Stopped by the station → **Add note** only
class _Actions extends StatelessWidget {
  const _Actions({
    required this.task,
    required this.busy,
    required this.onComplete,
    required this.onCancel,
    required this.onNote,
    required this.onReopen,
  });

  final TaskEntity task;
  final bool busy;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onNote;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: AppSpacing.md);

    if (task.status == TaskStatus.pending) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: 'task.action_complete'.tr(),
            prefixIcon: Icon(Icons.check_circle_rounded, size: 28.r),
            variant: ButtonVariant.success,
            height: ButtonSize.large,
            isFullWidth: true,
            onPressed: busy ? null : onComplete,
          ),
          gap,
          AppButton(
            label: 'task.action_cancel'.tr(),
            prefixIcon: Icon(
              Icons.cancel_rounded,
              size: 28.r,
              color: context.colors.error,
            ),
            variant: ButtonVariant.outline,
            textColor: context.colors.error,
            height: ButtonSize.large,
            isFullWidth: true,
            onPressed: busy ? null : onCancel,
          ),
        ],
      );
    }

    final noteButton = AppButton(
      label: task.hasNote
          ? 'task.action_edit_note'.tr()
          : 'task.action_add_note'.tr(),
      prefixIcon: Icon(Icons.edit_note_rounded, size: 28.r),
      height: ButtonSize.large,
      isFullWidth: true,
      onPressed: busy ? null : onNote,
    );

    // Stopped or completed by the station: the server refuses a reopen.
    if (task.isStoppedByStation || task.isCompletedByStation) return noteButton;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        noteButton,
        gap,
        AppButton(
          label: 'task.action_reopen'.tr(),
          prefixIcon: Icon(Icons.replay_rounded, size: 28.r),
          variant: ButtonVariant.outline,
          height: ButtonSize.large,
          isFullWidth: true,
          isLoading: busy,
          onPressed: onReopen,
        ),
      ],
    );
  }
}
