// import 'package:flutter/material.dart';
// import 'package:iconly/iconly.dart';
// import 'package:provider/provider.dart';
// import '../controllers/navigation_controller.dart';
// import '../../homescreen/views/app_colors.dart';
// import '../../homescreen/views/home_screen.dart';
// import '../../transactions/views/transactions_screen.dart';
// import '../../transactions/views/widgets/add_transaction_dialog.dart';
// import '../../reports/views/reports_screen.dart';
// import '../../settings/views/settings_screen.dart';

// class RootScreen extends StatefulWidget {
//   const RootScreen({super.key});

//   @override
//   State<RootScreen> createState() => _RootScreenState();
// }

// class _RootScreenState extends State<RootScreen> {
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const TransactionsScreen(),
//     const ReportsScreen(),
//     const SettingsScreen(),
//   ];

//   Widget build(BuildContext context) {
//     final navProvider = Provider.of<NavigationController>(context);
//     final selectedIndex = navProvider.selectedIndex;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: _screens[selectedIndex],
//       // Custom Bottom Navigation Bar
//       extendBody: true,
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: Container(
//         height: 72,
//         width: 72,
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: AppColors.primaryPurple.withOpacity(0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: AppColors.primaryGradient,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.primaryPurple.withOpacity(0.4),
//                 blurRadius: 15,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: FloatingActionButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => const AddTransactionDialog(),
//               );
//             },
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             shape: const CircleBorder(),
//             child: const Icon(Icons.add, color: AppColors.textLight, size: 30),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.textDark.withOpacity(0.08),
//               blurRadius: 30,
//               offset: const Offset(0, -10),
//             ),
//           ],
//         ),
//         child: BottomAppBar(
//           color: AppColors.textLight,
//           shape: const CircularNotchedRectangle(),
//           notchMargin: 12,
//           elevation: 0,
//           padding: EdgeInsets.zero,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildNavItem(
//                   IconlyLight.home,
//                   IconlyBold.home,
//                   'Home',
//                   0,
//                   navProvider,
//                 ),
//                 _buildNavItem(
//                   IconlyLight.swap,
//                   IconlyBold.swap,
//                   'History',
//                   1,
//                   navProvider,
//                 ),
//                 const SizedBox(width: 80), // Space for FAB
//                 _buildNavItem(
//                   IconlyLight.chart,
//                   IconlyBold.chart,
//                   'Insight',
//                   2,
//                   navProvider,
//                 ),
//                 _buildNavItem(
//                   IconlyLight.setting,
//                   IconlyBold.setting,
//                   'Access',
//                   3,
//                   navProvider,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(
//     IconData outlineIcon,
//     IconData filledIcon,
//     String label,
//     int index,
//     NavigationController navProvider,
//   ) {
//     bool isSelected = navProvider.selectedIndex == index;
//     return GestureDetector(
//       onTap: () {
//         navProvider.setIndex(index);
//       },
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         width: 60,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isSelected ? filledIcon : outlineIcon,
//               color: isSelected
//                   ? AppColors.primaryPurple
//                   : AppColors.textGray.withOpacity(0.4),
//               size: 24,
//             ),
//             const SizedBox(height: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected
//                     ? AppColors.primaryPurple
//                     : AppColors.textGray.withOpacity(0.4),
//                 fontSize: 9,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/////

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../controllers/navigation_controller.dart';
import '../../homescreen/views/app_colors.dart';
import '../../homescreen/views/home_screen.dart';
import '../../transactions/views/transactions_screen.dart';
import '../../transactions/views/widgets/add_transaction_dialog.dart';
import '../../reports/views/reports_screen.dart';
import '../../settings/views/settings_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationController>(context);
    final selectedIndex = navProvider.selectedIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[selectedIndex],
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 72,
        width: 72,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddTransactionDialog(),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: AppColors.textLight, size: 30),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: BottomAppBar(
          color: AppColors.textLight,
          shape: const CircularNotchedRectangle(),
          notchMargin: 12,
          elevation: 0,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  IconlyLight.home,
                  IconlyBold.home,
                  'Home',
                  0,
                  navProvider,
                ),
                _buildNavItem(
                  IconlyLight.swap,
                  IconlyBold.swap,
                  'History',
                  1,
                  navProvider,
                ),
                const SizedBox(width: 80),
                _buildNavItem(
                  IconlyLight.chart,
                  IconlyBold.chart,
                  'Insight',
                  2,
                  navProvider,
                ),
                _buildNavItem(
                  IconlyLight.setting,
                  IconlyBold.setting,
                  'Access',
                  3,
                  navProvider,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    int index,
    NavigationController navProvider,
  ) {
    bool isSelected = navProvider.selectedIndex == index;
    return GestureDetector(
      onTap: () {
        navProvider.setIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected
                  ? AppColors.primaryPurple
                  : AppColors.textGray.withOpacity(0.4),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.textGray.withOpacity(0.4),
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
