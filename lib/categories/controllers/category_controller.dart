import 'package:flutter/material.dart';
import '../../homescreen/models/category_model.dart';
import '../../homescreen/views/app_colors.dart';
import '../../root/services/firebase_service.dart';
import '../../root/utils/app_icons.dart';

class CategoryController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<CategoryModel> _categories = [];

  CategoryController() {
    _init();
  }

  void _init() {
    _firestoreService.getCategories().listen((categories) {
      if (categories.isEmpty) {
        // Seed default categories if none exist
        _seedDefaultCategories();
      } else {
        _categories = categories;
        notifyListeners();
      }
    });
  }

  void _seedDefaultCategories() {
    final defaults = [
      CategoryModel(
        id: 'food',
        name: 'Food',
        iconName: AppIcons.restaurant,
        backgroundColor: AppColors.foodBg,
        iconColor: AppColors.foodIcon,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transport',
        iconName: AppIcons.directionscar,
        backgroundColor: AppColors.transportBg,
        iconColor: AppColors.transportIcon,
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Shopping',
        iconName: AppIcons.shoppingbag,
        backgroundColor: AppColors.shoppingBg,
        iconColor: AppColors.shoppingIcon,
      ),
      CategoryModel(
        id: 'bills',
        name: 'Bills',
        iconName: AppIcons.bolt,
        backgroundColor: AppColors.billsBg,
        iconColor: AppColors.billsIcon,
      ),
    ];
    for (var cat in defaults) {
      saveCategory(cat);
    }
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  Future<void> saveCategory(CategoryModel category) async {
    await _firestoreService.saveCategory(category);
  }

  Future<void> updateCategory(CategoryModel updatedCategory) async {
    await _firestoreService.saveCategory(updatedCategory);
  }

  Future<void> deleteCategory(String id) async {
    await _firestoreService.deleteCategory(id);
  }
}
