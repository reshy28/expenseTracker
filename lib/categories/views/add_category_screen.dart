import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../homescreen/views/app_colors.dart';
import '../../homescreen/models/category_model.dart';
import '../controllers/category_controller.dart';

class AddCategoryScreen extends StatefulWidget {
  final CategoryModel? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Map<String, Color> _selectedColors;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.bolt,
    Icons.home,
    Icons.movie,
    Icons.fitness_center,
    Icons.medical_services,
    Icons.school,
    Icons.flight,
    Icons.receipt_long,
    Icons.savings,
    Icons.pets,
    Icons.coffee,
    Icons.redeem,
    Icons.construction,
    Icons.stroller,
    Icons.music_note,
  ];

  final List<Map<String, Color>> _colorPresets = [
    {'bg': AppColors.foodBg, 'icon': AppColors.foodIcon},
    {'bg': AppColors.transportBg, 'icon': AppColors.transportIcon},
    {'bg': AppColors.shoppingBg, 'icon': AppColors.shoppingIcon},
    {'bg': AppColors.billsBg, 'icon': AppColors.billsIcon},
    {'bg': AppColors.rentBg, 'icon': AppColors.rentIcon},
    {'bg': AppColors.gymBg, 'icon': AppColors.gymIcon},
    {'bg': AppColors.greenLight, 'icon': AppColors.greenDark},
    {'bg': AppColors.primaryPurpleLight, 'icon': AppColors.primaryPurple},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? Icons.restaurant;

    if (widget.category != null) {
      _selectedColors = {
        'bg': widget.category!.backgroundColor,
        'icon': widget.category!.iconColor,
      };
    } else {
      _selectedColors = _colorPresets[0];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.category != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.textDark.withOpacity(0.05),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isEditing ? 'Edit Category' : 'Add Category',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.textDark.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CATEGORY NAME'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _nameController,
                        hint: 'e.g. EntertainMent',
                      ),

                      const SizedBox(height: 32),
                      _buildLabel('SELECT ICON'),
                      const SizedBox(height: 16),
                      _buildIconPicker(),
                      const SizedBox(height: 32),

                      _buildLabel('THEMe COLOR'),
                      const SizedBox(height: 16),
                      _buildColorPicker(),

                      const SizedBox(height: 48),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_nameController.text.isEmpty) return;

                            if (isEditing) {
                              final updatedCategory = CategoryModel(
                                id: widget.category!.id,
                                name: _nameController.text,

                                icon: _selectedIcon,
                                backgroundColor: _selectedColors['bg']!,
                                iconColor: _selectedColors['icon']!,
                              );
                              Provider.of<CategoryController>(
                                context,
                                listen: false,
                              ).updateCategory(updatedCategory);
                            } else {
                              final newCategory = CategoryModel(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                name: _nameController.text,

                                icon: _selectedIcon,
                                backgroundColor: _selectedColors['bg']!,
                                iconColor: _selectedColors['icon']!,
                              );
                              Provider.of<CategoryController>(
                                context,
                                listen: false,
                              ).addCategory(newCategory);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isEditing ? 'Update Category' : 'Save Category',
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textGray.withOpacity(0.6),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textGray.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          final icon = _availableIcons[index];
          final isSelected = icon == _selectedIcon;
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryPurple
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.textLight
                    : AppColors.textGray.withOpacity(0.6),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colorPresets.map((preset) {
        final isSelected = _selectedColors == preset;
        return GestureDetector(
          onTap: () => setState(() => _selectedColors = preset),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: preset['bg'],
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.primaryPurple, width: 2)
                  : null,
            ),
            child: Icon(
              Icons.check,
              color: isSelected ? preset['icon'] : Colors.transparent,
              size: 20,
            ),
          ),
        );
      }).toList(),
    );
  }
}
