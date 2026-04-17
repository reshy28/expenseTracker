import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homescreen/controllers/home_controller.dart';
import 'transactions/controllers/transactions_controller.dart';
import 'reports/controllers/reports_controller.dart';
import 'accounts/controllers/accounts_controller.dart';
import 'categories/controllers/category_controller.dart';
import 'emis/controllers/emi_controller.dart';
import 'settings/controllers/payment_methods_controller.dart';
import 'settings/controllers/profile_controller.dart';
import 'root/views/root_screen.dart';
import 'root/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Sign in anonymously before running the app to ensure UID is available
  final firestoreService = FirestoreService();
  await firestoreService.signInAnonymously();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeController()),
        ChangeNotifierProvider(create: (context) => TransactionsController()),
        ChangeNotifierProvider(create: (context) => ReportsController()),
        ChangeNotifierProvider(create: (context) => AccountsController()),
        ChangeNotifierProvider(create: (context) => CategoryController()),
        ChangeNotifierProvider(create: (context) => EmiController()),
        ChangeNotifierProvider(create: (context) => PaymentMethodsController()),
        ChangeNotifierProvider(create: (context) => ProfileController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5544FF)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const RootScreen(),
    );
  }
}
