import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import 'package:provider/provider.dart';
import '../../cart/provider/cart_provider.dart';
import '../presentation/login_screen.dart';
import '../../home/presentation/dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _checkLoginStatus();
  }

  void _navigateWithSlideUp(String route) {
    print('Navigasi dengan transisi slide up ke $route');
    Widget page;
    if (route == '/home') {
      page = const DashboardPage();
    } else {
      page = const LoginScreen();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1800),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeIn);
          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    if (isLoggedIn) {
      await Provider.of<CartProvider>(context, listen: false).fetchCart();
      if (!mounted) return;
      _navigateWithSlideUp('/home');
    } else {
      _navigateWithSlideUp('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101020),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo_tr.png',
                width: 220,
                height: 220,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 