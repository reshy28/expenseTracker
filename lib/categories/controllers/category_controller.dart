import 'package:flutter/material.dart';
import '../../homescreen/models/category_model.dart';
import '../../homescreen/views/app_colors.dart';

class CategoryController extends ChangeNotifier {
  final List<CategoryModel> _categories = [
    CategoryModel(
      id: 'food',
      name: 'Food',

      icon: Icons.restaurant,
      backgroundColor: AppColors.foodBg,
      iconColor: AppColors.foodIcon,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',

      icon: Icons.directions_car,
      backgroundColor: AppColors.transportBg,
      iconColor: AppColors.transportIcon,
    ),
    CategoryModel(
      id: 'shopping',
      name: 'Shopping',

      icon: Icons.shopping_bag,
      backgroundColor: AppColors.shoppingBg,
      iconColor: AppColors.shoppingIcon,
    ),
    CategoryModel(
      id: 'bills',
      name: 'Bills',

      icon: Icons.bolt,
      backgroundColor: AppColors.billsBg,
      iconColor: AppColors.billsIcon,
    ),
  ];

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  void addCategory(CategoryModel category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(CategoryModel updatedCategory) {
    final index = _categories.indexWhere((cat) => cat.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((cat) => cat.id == id);
    notifyListeners();
  }
}
