import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_detail_bloc.dart';
import 'task_visuals.dart';

/// What the sheet is for.
enum TaskSheetMode { complete, cancel, note }

/// The form behind "Complete task", "Cancel" and "Add note".
///
/// A bottom sheet the employee cannot swipe or tap away by accident — it
/// closes only through its own "Back" button or once the server has saved.
/// Returns true when something was saved.
Future<bool?> showTaskActionSheet(
  BuildContext context, {
  required TaskSheetMode mode,
}) {
  final bloc = context.read<TaskDetailBloc>();

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: context.colors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
    ),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _TaskActionForm(mode: mode),
    ),
  );
}

class _TaskActionForm extends StatefulWidget {
  const _TaskActionForm({required this.mode});

  final TaskSheetMode mode;

  @override
  State<_TaskActionForm> createState() => _TaskActionFormState();
}

class _TaskActionFormState extends State<_TaskActionForm> {
  final _formKey = GlobalKey<FormState>();

  late final TaskEntity _task = context.read<TaskDetailBloc>().state.task;

  // Opening "Complete" after a reopen, or "Edit note", starts from the note
  // already saved rather than an empty box.
  late final _note = TextEditingController(text: _task.note ?? '');
  final _materialType = TextEditingController();
  final _brand = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController();

  /// Null means "today" — the server's own default.
  DateTime? _date;

  /// The sheet only reacts to submissions it started itself.
  bool _submitted = false;

  bool get _isComplete => widget.mode == TaskSheetMode.complete;
  bool get _isCancel => widget.mode == TaskSheetMode.cancel;

  @override
  void dispose() {
    for (final c in [_note, _materialType, _brand, _quantity, _unit]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    HapticFeedback.mediumImpact();
    _submitted = true;
    final bloc = context.read<TaskDetailBloc>();

    switch (widget.mode) {
      case TaskSheetMode.note:
        bloc.add(SaveTaskNoteEvent(_note.text));
      case TaskSheetMode.cancel:
        bloc.add(ChangeTaskStatusEvent(
          status: TaskStatus.cancelled,
          note: _note.text,
        ));
      case TaskSheetMode.complete:
        bloc.add(ChangeTaskStatusEvent(
          status: TaskStatus.completed,
          note: _note.text,
          product: _task.taskType == TaskType.product
              ? TaskProductRecord(
                  materialType: _materialType.text,
                  brand: _brand.text,
                  quantity: _quantity.text,
                  quantityUnit: _unit.text,
                  date: _date,
                )
              : null,
          dose: _task.taskType == TaskType.dose
              ? TaskDoseRecord(quantity: _quantity.text, date: _date)
              : null,
        ));
    }
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  String? _required(String? value, String message) =>
      (value ?? '').trim().isEmpty ? message : null;

  @override
  Widget build(BuildContext context) {
    final (title, icon, color) = switch (widget.mode) {
      TaskSheetMode.complete => (
          'task.complete_title'.tr(),
          Icons.check_circle_rounded,
          context.appColors.success,
        ),
      TaskSheetMode.cancel => (
          'task.cancel_title'.tr(),
          Icons.cancel_rounded,
          context.colors.error,
        ),
      TaskSheetMode.note => (
          'task.note_title'.tr(),
          Icons.edit_note_rounded,
          context.colors.primary,
        ),
    };

    return BlocConsumer<TaskDetailBloc, TaskDetailState>(
      listenWhen: (prev, curr) =>
          _submitted && prev.submission != curr.submission,
      listener: (context, state) {
        if (state.submission == TaskSubmission.success) {
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final busy = state.isSubmitting;
        final failed = _submitted && state.submission == TaskSubmission.failure;

        return PopScope(
          // The system back gesture must not drop a request halfway.
          canPop: !busy,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.ml),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 36.r, color: color),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            title,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // Which task this is about, so nobody completes the wrong
                    // one after switching between screens.
                    Text(
                      _task.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),

                    ..._fields(context),

                    if (failed) ...[
                      SizedBox(height: AppSpacing.md),
                      _ErrorBox(
                        message: state.serverMessage ??
                            (state.isOffline
                                ? 'task.action_error_offline'.tr()
                                : 'task.action_error_server'.tr()),
                      ),
                    ],

                    SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: switch (widget.mode) {
                        TaskSheetMode.complete => 'task.confirm_complete'.tr(),
                        TaskSheetMode.cancel => 'task.confirm_cancel'.tr(),
                        TaskSheetMode.note => 'task.save_note'.tr(),
                      },
                      prefixIcon: Icon(icon, size: 28.r),
                      variant: switch (widget.mode) {
                        TaskSheetMode.complete => ButtonVariant.success,
                        TaskSheetMode.cancel => ButtonVariant.danger,
                        TaskSheetMode.note => ButtonVariant.primary,
                      },
                      height: ButtonSize.large,
                      isFullWidth: true,
                      isLoading: busy,
                      onPressed: _submit,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'task.back'.tr(),
                      prefixIcon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        size: 28.r,
                      ),
                      variant: ButtonVariant.outline,
                      height: ButtonSize.large,
                      isFullWidth: true,
                      onPressed:
                          busy ? null : () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _fields(BuildContext context) {
    final gap = SizedBox(height: AppSpacing.md);
    final fields = <Widget>[];

    if (_isComplete && _task.taskType == TaskType.product) {
      fields.addAll([
        AppTextField(
          controller: _materialType,
          label: 'task.field_material_type'.tr(),
          textInputAction: TextInputAction.next,
          validator: (v) => _required(v, 'task.required_material_type'.tr()),
        ),
        gap,
        AppTextField(
          controller: _brand,
          label: 'task.field_brand'.tr(),
          textInputAction: TextInputAction.next,
          validator: (v) => _required(v, 'task.required_brand'.tr()),
        ),
        gap,
        AppTextField(
          controller: _quantity,
          label: 'task.field_quantity'.tr(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: (v) => _required(v, 'task.required_quantity'.tr()),
        ),
        gap,
        AppTextField(
          controller: _unit,
          label: 'task.field_unit'.tr(),
          hint: 'task.field_unit_hint'.tr(),
          textInputAction: TextInputAction.next,
        ),
        gap,
        _DateButton(date: _date, onPressed: _pickDate),
        gap,
      ]);
    } else if (_isComplete && _task.taskType == TaskType.dose) {
      fields.addAll([
        AppTextField(
          controller: _quantity,
          label: 'task.field_dose_quantity'.tr(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          validator: (v) => _required(v, 'task.required_dose_quantity'.tr()),
        ),
        gap,
        _DateButton(date: _date, onPressed: _pickDate),
        gap,
      ]);
    } else if (_isComplete) {
      fields.addAll([_HelpText('task.complete_other_help'.tr()), gap]);
    } else if (_isCancel) {
      fields.addAll([_HelpText('task.cancel_help'.tr()), gap]);
    }

    fields.add(
      AppTextField(
        controller: _note,
        label: widget.mode == TaskSheetMode.note
            ? 'task.field_note'.tr()
            : 'task.field_note_optional'.tr(),
        hint: _isCancel
            ? 'task.note_hint_cancel'.tr()
            : 'task.note_hint_complete'.tr(),
        minLines: 3,
        maxLines: 6,
        keyboardType: TextInputType.multiline,
      ),
    );

    if (widget.mode == TaskSheetMode.note) {
      fields.addAll([gap, _HelpText('task.note_clear_help'.tr())]);
    }

    return fields;
  }
}

/// "Date: Today — Change". Optional, so it starts on today and a tap opens
/// the calendar only for someone who wants a different day.
class _DateButton extends StatelessWidget {
  const _DateButton({required this.date, required this.onPressed});

  final DateTime? date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final value =
        date == null ? 'task.date_today'.tr() : formatTaskDateTime(date!);

    return Semantics(
      button: true,
      label: '${'task.field_date'.tr()}: $value. ${'task.change_date'.tr()}',
      child: ExcludeSemantics(
        child: Material(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.ms),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.ms),
            onTap: onPressed,
            child: Container(
              constraints: BoxConstraints(minHeight: 64.h),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.ms),
                border: Border.all(color: context.colors.outline, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 28.r,
                    color: context.colors.primary,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${'task.field_date'.tr()}: $value',
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    'task.change_date'.tr(),
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.primary,
                    ),
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

class _HelpText extends StatelessWidget {
  const _HelpText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: context.colors.onSurface,
        height: 1.5,
      ),
    );
  }
}

/// The reason a save did not go through, right above the button that retries
/// it. Red icon, but the words stay in the normal text colour so they are
/// readable.
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.ms),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 28.r,
              color: context.colors.error,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.onErrorContainer,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
