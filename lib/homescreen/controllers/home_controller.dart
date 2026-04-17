import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/bill_model.dart';
import '../models/transaction_model.dart';
import '../views/app_colors.dart';

class HomeController extends ChangeNotifier {
  final UserModel user = UserModel(
    name: 'Alex Johnson',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
  );

  final double budgetSpent = 42000;
  final double budgetTotal = 60000;

  final List<CategoryModel> categories = [
    CategoryModel(
      name: 'Food',

      icon: Icons.restaurant,
      backgroundColor: AppColors.foodBg,
      iconColor: AppColors.foodIcon,
      id: '',
    ),
    CategoryModel(
      name: 'Transport',

      icon: Icons.directions_car,
      backgroundColor: AppColors.transportBg,
      iconColor: AppColors.transportIcon,
      id: '',
    ),
    CategoryModel(
      name: 'Shopping',

      icon: Icons.shopping_bag,
      backgroundColor: AppColors.shoppingBg,
      iconColor: AppColors.shoppingIcon,
      id: '',
    ),
    CategoryModel(
      name: 'Bills',

      icon: Icons.bolt,
      backgroundColor: AppColors.billsBg,
      iconColor: AppColors.billsIcon,
      id: '',
    ),
  ];

  final List<BillModel> bills = [
    BillModel(
      title: 'Rent Payment',
      amount: 15000,
      dueDate: 'Due on Apr 20',
      dueInDays: 'Due in 4 days',
      icon: Icons.home,
      backgroundColor: AppColors.rentBg,
      iconColor: AppColors.rentIcon,
    ),
    BillModel(
      title: 'Gym Membership',
      amount: 1200,
      dueDate: 'Due on Apr 22',
      dueInDays: 'Due in 6 days',
      icon: Icons.trending_up,
      backgroundColor: AppColors.gymBg,
      iconColor: AppColors.gymIcon,
    ),
    BillModel(
      title: 'Internet Bill',
      amount: 999,
      dueDate: 'Due on Apr 18',
      dueInDays: 'Due in 2 days',
      icon: Icons.bolt,
      backgroundColor: AppColors.internetBg,
      iconColor: AppColors.internetIcon,
    ),
  ];

  final List<TransactionModel> transactions = [
    TransactionModel(
      title: 'Starbucks Coffee',
      dateSubtitle: 'Today, 09:45 AM',
      date: DateTime.now(),
      amount: 350,
      icon: Icons.local_dining,
      iconBackgroundColor: AppColors.foodBg,
      iconColor: AppColors.foodIcon,
    ),
    TransactionModel(
      title: 'Uber Ride',
      dateSubtitle: 'Yesterday, 06:20 PM',
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 180,
      icon: Icons.directions_car,
      iconBackgroundColor: AppColors.transportBg,
      iconColor: AppColors.transportIcon,
    ),
    TransactionModel(
      title: 'Grocery Store',
      dateSubtitle: '14 April, 02:30 PM',
      date: DateTime(DateTime.now().year, 4, 14),
      amount: 1200,
      icon: Icons.shopping_basket,
      iconBackgroundColor: AppColors.shoppingBg,
      iconColor: AppColors.shoppingIcon,
    ),
  ];
}
