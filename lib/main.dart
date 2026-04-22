import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtracker/auth/views/login_screen.dart';
import 'package:mtracker/root/views/root_screen.dart';
import 'package:provider/provider.dart';

// Controllers
import 'root/controllers/navigation_controller.dart';
import 'homescreen/controllers/home_controller.dart';
import 'transactions/controllers/transactions_controller.dart';
import 'reports/controllers/reports_controller.dart';
import 'accounts/controllers/accounts_controller.dart';
import 'categories/controllers/category_controller.dart';
import 'emis/controllers/emi_controller.dart';
import 'settings/controllers/payment_methods_controller.dart';
import 'settings/controllers/profile_controller.dart';

// Services

import 'root/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize Notifications
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        // SESSION-AWARE PROVIDER TREE
        // Using a ValueKey based on UID ensures that the entire provider tree
        // is disposed and recreated whenever the user auth state changes.
        // This fixes the 'Stale Data' bug after logout/account deletion.
        return MultiProvider(
          key: ValueKey(user?.uid ?? 'logged-out'),
          providers: [
            ChangeNotifierProvider(create: (_) => HomeController()),
            ChangeNotifierProvider(create: (_) => TransactionsController()),
            ChangeNotifierProvider(create: (_) => ReportsController()),
            ChangeNotifierProvider(create: (_) => AccountsController()),
            ChangeNotifierProvider(create: (_) => CategoryController()),
            ChangeNotifierProvider(create: (_) => EmiController()),
            ChangeNotifierProvider(create: (_) => PaymentMethodsController()),
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => NavigationController()),
          ],
          child: MaterialApp(
            title: 'MTracker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              fontFamily: 'Outfit',
            ),
            home: user != null ? const RootScreen() : const LoginScreen(),
          ),
        );
      },
    );
  }
}
