import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../domain/entities/farm_entity.dart';
import '../providers/farm_bloc.dart';
import '../widgets/farm_card.dart';

class FarmsScreen extends StatefulWidget {
  const FarmsScreen({super.key});

  @override
  State<FarmsScreen> createState() => _FarmsScreenState();
}

class _FarmsScreenState extends State<FarmsScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setQuery(String value) => setState(() => _query = value);

  void _clearSearch() {
    HapticFeedback.selectionClick();
    _search.clear();
    _setQuery('');
  }

  /// Matches the name, the place and the crop — the three things someone is
  /// likely to remember about a farm.
  List<FarmEntity> _filter(List<FarmEntity> farms) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return farms;
    return farms
        .where((f) => [f.name, f.localisation, f.crop]
            .any((field) => (field ?? '').toLowerCase().contains(q)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FarmBloc, FarmState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'مزارعي',
              style: context.typography.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: IconButton.outlined(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () =>
                      context.read<FarmBloc>().add(const FetchFarmsEvent()),
                ),
              ),
            ],
          ),
          body: state.hasError
              ? _ErrorView(message: state.errorMessage)
              : state.farms.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () async =>
                          context.read<FarmBloc>().add(const FetchFarmsEvent()),
                      child: Builder(builder: (context) {
                        final farms = _filter(state.farms);
                        // The search box is the first row, so it scrolls
                        // away with the list on a small phone.
                        return ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.all(AppSpacing.md),
                          itemCount: farms.isEmpty ? 2 : farms.length + 1,
                          separatorBuilder: (_, __) =>
                              SizedBox(height: AppSpacing.sm),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.xs),
                                child: AppTextField(
                                  controller: _search,
                                  label: 'farm.search_label'.tr(),
                                  hint: 'farm.search_hint'.tr(),
                                  textInputAction: TextInputAction.search,
                                  prefixIcon:
                                      Icon(Icons.search_rounded, size: 28.r),
                                  suffixIcon: _query.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: 'farm.search_clear'.tr(),
                                          iconSize: 28.r,
                                          icon: const Icon(Icons.close_rounded),
                                          onPressed: _clearSearch,
                                        ),
                                  onChanged: _setQuery,
                                ),
                              );
                            }
                            if (farms.isEmpty) {
                              return _NoMatchView(onShowAll: _clearSearch);
                            }
                            return FarmCard(farm: farms[i - 1]);
                          },
                        );
                      }),
                    ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: context.colors.error,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: context.typography.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.typography.bodyMedium
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () =>
                  context.read<FarmBloc>().add(const FetchFarmsEvent()),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: 64,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'No Farms Found',
            style: context.typography.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            "You haven't been assigned to any farms yet.",
            textAlign: TextAlign.center,
            style: context.typography.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// The search found nothing — one button puts every farm back.
class _NoMatchView extends StatelessWidget {
  const _NoMatchView({required this.onShowAll});

  final VoidCallback onShowAll;

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
            'farm.no_match_title'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'farm.no_match_body'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colors.onSurface,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'farm.show_all'.tr(),
            prefixIcon: Icon(Icons.list_alt_rounded, size: 28.r),
            variant: ButtonVariant.outline,
            height: ButtonSize.large,
            isFullWidth: true,
            onPressed: onShowAll,
          ),
        ],
      ),
    );
  }
}
