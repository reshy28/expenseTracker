import 'package:flutter/material.dart';

/// Centralized icon registry for the app.
///
/// All [IconData] values are `const` compile-time constants, which makes them
/// fully compatible with Flutter's release-build tree-shaker.
///
/// **Usage in models:** store [String] keys (e.g. `'restaurant'`).
/// **Usage in UI:** `Icon(AppIcons.get(iconName))`.
class AppIcons {
  AppIcons._(); // prevent instantiation

  // ── Icon catalogue ──────────────────────────────────────────────────────────
  static const Map<String, IconData> _catalogue = {
    // Food & Drink
    'restaurant': Icons.restaurant,
    'coffee': Icons.coffee,
    'fastfood': Icons.fastfood,
    'local_bar': Icons.local_bar,

    // Transport
    'directions_car': Icons.directions_car,
    'flight': Icons.flight,
    'train': Icons.train,
    'directions_bike': Icons.directions_bike,

    // Shopping
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'redeem': Icons.redeem,

    // Home & Utilities
    'home': Icons.home,
    'bolt': Icons.bolt,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,

    // Health & Fitness
    'fitness_center': Icons.fitness_center,
    'medical_services': Icons.medical_services,
    'local_hospital': Icons.local_hospital,
    'self_improvement': Icons.self_improvement,

    // Education & Work
    'school': Icons.school,
    'work': Icons.work,
    'construction': Icons.construction,

    // Entertainment
    'movie': Icons.movie,
    'music_note': Icons.music_note,
    'sports_esports': Icons.sports_esports,

    // Finance
    'savings': Icons.savings,
    'receipt_long': Icons.receipt_long,
    'pie_chart': Icons.pie_chart,
    'account_balance_wallet': Icons.account_balance_wallet,
    'credit_card': Icons.credit_card,
    'currency_rupee': Icons.currency_rupee,
    'trending_up': Icons.trending_up,

    // Family & Life
    'pets': Icons.pets,
    'stroller': Icons.stroller,
    'child_care': Icons.child_care,
    'people': Icons.people,

    // Other
    'star': Icons.star,
    'category': Icons.category,
    'more_horiz': Icons.more_horiz,
  };

  /// The fallback icon shown when an unknown key is requested.
  static const IconData fallback = Icons.category;

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Returns the [IconData] for the given [name].
  /// Falls back to [fallback] if the key is not found.
  static IconData get(String? name) => _catalogue[name] ?? fallback;

  /// All registered icon names, useful for building icon pickers.
  static List<String> get allNames => _catalogue.keys.toList();

  /// All registered [IconData] values.
  static List<IconData> get allIcons => _catalogue.values.toList();

  // ── Convenience name constants ───────────────────────────────────────────────
  // Use these instead of raw strings to avoid typos.
  static const String restaurant = 'restaurant';
  static const String coffee = 'coffee';
  static const String directionscar = 'directions_car';
  static const String flight = 'flight';
  static const String shoppingbag = 'shopping_bag';
  static const String redeem = 'redeem';
  static const String home = 'home';
  static const String bolt = 'bolt';
  static const String fitnesscenter = 'fitness_center';
  static const String medicalservices = 'medical_services';
  static const String school = 'school';
  static const String movie = 'movie';
  static const String construction = 'construction';
  static const String musicnote = 'music_note';
  static const String savings = 'savings';
  static const String receiptlong = 'receipt_long';
  static const String piechart = 'pie_chart';
  static const String accountbalancewallet = 'account_balance_wallet';
  static const String creditcard = 'credit_card';
  static const String pets = 'pets';
  static const String stroller = 'stroller';
  static const String star = 'star';
  static const String category = 'category';
}
