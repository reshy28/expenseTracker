import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../../homescreen/views/app_colors.dart';
import 'package:provider/provider.dart';
import '../../accounts/views/my_accounts_screen.dart';
import '../../categories/views/all_categories_screen.dart';
import '../../emis/views/emi_manager_screen.dart';
import '../controllers/profile_controller.dart';
import 'payment_methods_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Provider.of<ProfileController>(context);
    final user = profileController.user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Settings',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Profile Card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppColors.premiumCardDecoration,
                child: Row(
                  children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryPurple.withOpacity(0.1), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.softBorder,
                      backgroundImage: user.avatarUrl.isNotEmpty
                          ? (user.avatarUrl.startsWith('http')
                                  ? NetworkImage(user.avatarUrl)
                                  : FileImage(File(user.avatarUrl)))
                              as ImageProvider
                          : const NetworkImage('https://i.pravatar.cc/150?u=fallback'),
                      onBackgroundImageError: (exception, stackTrace) {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      IconlyLight.arrow_right_2,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            ),
            const SizedBox(height: 32),

            // Menu Items
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAccountsScreen(),
                  ),
                );
              },
              child: _buildMenuItem(
                IconlyLight.wallet,
                'My Accounts',
                AppColors.primaryPurple.withOpacity(0.1),
                AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllCategoriesScreen(),
                  ),
                );
              },
              child: _buildMenuItem(
                Icons.grid_view_rounded,
                'Categories',
                AppColors.shoppingBg.withOpacity(0.5),
                AppColors.shoppingIcon,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmiManagerScreen(),
                  ),
                );
              },
              child: _buildMenuItem(
                IconlyLight.time_circle,
                'EMI Manager',
                AppColors.foodBg.withOpacity(0.5),
                AppColors.foodIcon,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentMethodsScreen(),
                  ),
                );
              },
              child: _buildMenuItem(
                IconlyLight.work,
                'Payment Methods',
                AppColors.primaryPurple.withOpacity(0.1),
                AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              IconlyLight.logout,
              'Logout',
              AppColors.redLight.withOpacity(0.5),
              AppColors.redAlertText,
              isLogout: true,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color bgColor,
    Color iconColor, {
    bool isLogout = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppColors.premiumCardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isLogout ? AppColors.redAlertText : AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            IconlyLight.arrow_right_2,
            color: AppColors.textGray.withOpacity(0.3),
            size: 18,
          ),
        ],
      ),
    );
  }
}
