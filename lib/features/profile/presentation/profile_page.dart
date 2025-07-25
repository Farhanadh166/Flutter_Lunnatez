import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../../auth/data/auth_service.dart';
import '../../cart/provider/cart_provider.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..fetchProfile(context),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 2,
              title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF22223B))),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            body: SafeArea(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5F6FA), Color(0xFFE9D8FD)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Card Profil
                    Container(
                      margin: const EdgeInsets.only(top: 0),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFF7C3AED), width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 44,
                              backgroundImage: provider.photoUrl.isNotEmpty
                                  ? NetworkImage(provider.photoUrl)
                                  : const AssetImage('assets/logo_placeholder.png') as ImageProvider,
                              backgroundColor: Colors.blue[50],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                provider.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF22223B)),
                              ),
                              const SizedBox(width: 8),
                              if (provider.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Terverifikasi', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.email,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.alamat,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                          ),
                          // Info gabung dan pesanan dihapus
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card Menu Aksi
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _ProfileMenuItem(
                            icon: Icons.edit,
                            iconBg: const Color(0xFF38BDF8),
                            title: 'Edit Profil',
                            onTap: () {
                              final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider.value(
                                    value: profileProvider,
                                    child: const EditProfilePage(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.location_on_outlined,
                            iconBg: const Color(0xFF7C3AED),
                            title: 'Alamat Saya',
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              if (token != null && context.mounted) {
                                Navigator.pushNamed(context, '/address', arguments: token);
                              }
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.history,
                            iconBg: const Color(0xFFE9D8FD),
                            iconColor: const Color(0xFF7C3AED),
                            title: 'Riwayat Pesanan',
                            onTap: () {
                              Navigator.pushNamed(context, '/order-history');
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.lock_outline,
                            iconBg: const Color(0xFFF5F6FA),
                            iconColor: const Color(0xFF7C3AED),
                            title: 'Ganti Password',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordPage(),
                                ),
                              );
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.help_outline,
                            iconBg: const Color(0xFF38BDF8),
                            title: 'Bantuan / FAQ',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Fitur Bantuan/FAQ coming soon!'), backgroundColor: Color(0xFF38BDF8)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Logout
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _ProfileMenuItem(
                        icon: Icons.logout,
                        iconBg: const Color(0xFFEF4444),
                        iconColor: Colors.white,
                        title: 'Logout',
                        titleColor: const Color(0xFFEF4444),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Yakin ingin logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await AuthService.removeToken();
                            if (context.mounted) {
                              Provider.of<CartProvider>(context, listen: false).clearState();
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color? iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.iconBg,
    this.iconColor,
    required this.title,
    this.titleColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: titleColor ?? const Color(0xFF22223B),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
} 