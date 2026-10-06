import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../domain/entities/task_entity.dart';
import '../providers/task_bloc.dart';
import 'task_visuals.dart';

/// The search box and the status dropdown above a task list.
///
/// Each status in the dropdown carries its colour, its icon and a count —
/// "Done (4)" — so the choice is readable without opening every option.
class TaskFilterBar extends StatefulWidget {
  const TaskFilterBar({super.key});

  @override
  State<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends State<TaskFilterBar> {
  late final _search =
      TextEditingController(text: context.read<TaskBloc>().state.query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() {
    HapticFeedback.selectionClick();
    _search.clear();
    context.read<TaskBloc>().add(const TaskSearchChangedEvent(''));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      // "Show all tasks" clears the search from outside this box.
      listenWhen: (prev, curr) => prev.query != curr.query,
      listener: (_, state) {
        if (_search.text != state.query) _search.text = state.query;
      },
      buildWhen: (prev, curr) =>
          prev.tasks != curr.tasks ||
          prev.statusFilter != curr.statusFilter ||
          prev.query != curr.query,
      builder: (context, state) {
        void select(TaskStatus? status) {
          HapticFeedback.selectionClick();
          context.read<TaskBloc>().add(TaskStatusFilterChangedEvent(status));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _search,
              label: 'task.search_label'.tr(),
              hint: 'task.search_hint'.tr(),
              textInputAction: TextInputAction.search,
              prefixIcon: Icon(Icons.search_rounded, size: 28.r),
              suffixIcon: state.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'task.search_clear'.tr(),
                      iconSize: 28.r,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _clear,
                    ),
              onChanged: (value) =>
                  context.read<TaskBloc>().add(TaskSearchChangedEvent(value)),
            ),
            SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<TaskStatus?>(
              // Keyed on the value so "Show all tasks" resets what it shows.
              key: ValueKey(state.statusFilter),
              initialValue: state.statusFilter,
              isExpanded: true,
              isDense: true,
              iconSize: 22.r,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'task.filter_label'.tr(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
              ),
              items: [
                DropdownMenuItem<TaskStatus?>(
                  value: null,
                  child: _StatusOption(
                    label:
                        'task.filter_all'.tr(args: ['${state.tasks.length}']),
                    icon: Icons.list_alt_rounded,
                    color: context.colors.primary,
                  ),
                ),
                for (final status in TaskStatus.values)
                  DropdownMenuItem<TaskStatus?>(
                    value: status,
                    child: _StatusOption(
                      label: '${taskStatusLabel(status)} '
                          '(${state.countOf(status)})',
                      icon: switch (status) {
                        TaskStatus.pending => Icons.hourglass_bottom_rounded,
                        TaskStatus.completed => Icons.check_circle_rounded,
                        TaskStatus.cancelled => Icons.cancel_rounded,
                      },
                      color: switch (status) {
                        TaskStatus.pending => context.appColors.warning,
                        TaskStatus.completed => context.appColors.success,
                        TaskStatus.cancelled => context.colors.error,
                      },
                    ),
                  ),
              ],
              onChanged: select,
            ),
          ],
        );
      },
    );
  }
}

/// One line in the status dropdown: coloured icon, then the words.
class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: color),
        SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
