import 'package:mihwar/src/imports/core_imports.dart';

import '../../domain/entities/task_entity.dart';

/// How a task's status looks and reads, shared by the list card and the task
/// page so a status never looks one way in one place and another way elsewhere.
///
/// Colour follows the employee guide — yellow still to do, green done, red
/// cancelled — and is always paired with words and an icon.
extension TaskVisuals on TaskEntity {
  Color accent(BuildContext context) => switch (status) {
        TaskStatus.completed => context.appColors.success,
        TaskStatus.cancelled => context.colors.error,
        TaskStatus.pending => context.appColors.warning,
      };

  IconData get statusIcon => switch (status) {
        TaskStatus.completed => Icons.check_circle_rounded,
        TaskStatus.cancelled => Icons.cancel_rounded,
        TaskStatus.pending => Icons.pending_actions_rounded,
      };

  String get statusLabel =>
      isStoppedByStation ? 'task.status_stopped'.tr() : taskStatusLabel(status);

  String get typeLabel => switch (taskType) {
        TaskType.product => 'task.type_product'.tr(),
        TaskType.dose => 'task.type_dose'.tr(),
        TaskType.other => 'task.type_other'.tr(),
      };

  IconData get typeIcon => switch (taskType) {
        TaskType.product => Icons.inventory_2_rounded,
        TaskType.dose => Icons.water_drop_rounded,
        TaskType.other => Icons.category_rounded,
      };

  /// "Ahmed stopped this task — no need to do it."
  String get stoppedMessage => (cancelledByName ?? '').trim().isNotEmpty
      ? 'task.stopped_by'.tr(args: [cancelledByName!.trim()])
      : 'task.stopped_by_station'.tr();
}

/// "Ahmed marked this task as done for you."
extension TaskCompletedByVisuals on TaskEntity {
  String get completedByMessage {
    if (!doneByEmployee) return 'task.done_by_station_only'.tr();
    final by = (completedByName ?? '').trim();
    if (doneByStation) {
      return by.isNotEmpty
          ? 'task.completed_with_station_by'.tr(args: [by])
          : 'task.completed_with_station'.tr();
    }
    return by.isNotEmpty
        ? 'task.completed_by'.tr(args: [by])
        : 'task.completed_by_station'.tr();
  }
}

String taskStatusLabel(TaskStatus status) => switch (status) {
      TaskStatus.completed => 'task.status_completed'.tr(),
      TaskStatus.cancelled => 'task.status_cancelled'.tr(),
      TaskStatus.pending => 'task.status_pending'.tr(),
    };

/// `2026-09-14T00:00:00Z` → `2026-09-14`. Never throws: an unparseable value
/// is shown as-is rather than crashing the screen.
String formatTaskDate(String raw) {
  try {
    return formatTaskDateTime(DateTime.parse(raw));
  } catch (_) {
    return raw.split('T').first;
  }
}

String formatTaskDateTime(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
