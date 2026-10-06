import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../../farm/presentation/providers/farm_bloc.dart';
import '../../../farm/presentation/screens/farms_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../task/presentation/screens/all_tasks_screen.dart';
import '../../../../core/di/injection_container.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.initialTab = HomeTab.farms});

  /// Which tab to open on. Lets a home choice tile land the user where they
  /// asked to go rather than on the default tab.
  final HomeTab initialTab;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex = widget.initialTab.index;

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Navigating here again with a different tab should move the selection.
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() => _selectedIndex = widget.initialTab.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FarmBloc>()..add(const FetchFarmsEvent()),
      child: Scaffold(
        // Order must match `HomeTab` — the enum's index selects the tab.
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            FarmsScreen(),
            AllTasksScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          // Taller than the M3 default, and labels never hide — an icon alone
          // is not a destination this audience can name.
          height: 88.h,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) {
            HapticFeedback.selectionClick();
            setState(() => _selectedIndex = i);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.agriculture_outlined, size: 30.r),
              selectedIcon: Icon(Icons.agriculture_rounded, size: 30.r),
              label: 'home.my_farms'.tr(),
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined, size: 30.r),
              selectedIcon: Icon(Icons.assignment_rounded, size: 30.r),
              label: 'task.my_tasks'.tr(),
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, size: 30.r),
              selectedIcon: Icon(Icons.person_rounded, size: 30.r),
              label: 'home.my_profile'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
