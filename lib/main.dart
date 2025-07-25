import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/cart/provider/cart_provider.dart';
import 'features/payment/provider/payment_provider.dart';
import 'features/complaint/provider/complaint_provider.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/dashboard_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/payment/presentation/checkout_page.dart';
import 'features/order/presentation/order_history_page.dart';
import 'features/cart/presentation/cart_page.dart';
import 'features/address/presentation/address_list_page.dart';
import 'features/address/presentation/address_form_pag.dart';
import 'core/constants.dart';
import 'features/address/provider/address_provider.dart';
import 'features/profile/presentation/profile_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
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
      title: 'Lunneettez',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
      ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
        '/checkout': (context) => const CheckoutPage(),
        '/order-history': (context) => const OrderHistoryPage(),
        '/cart': (context) => const CartPage(),
        '/address': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String;
          return AddressListPage(token: token);
        },
        '/address/add': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String;
          return ChangeNotifierProvider(
            create: (_) => AddressProvider(),
            child: AddressFormPage(token: token),
          );
        },
        '/address/edit': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChangeNotifierProvider(
            create: (_) => AddressProvider(),
            child: AddressFormPage(token: args['token'], address: args['address']),
          );
        },
      },
    );
  }
}
