import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../../attendance/presentation/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nipController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authNotifierProvider.notifier).login(
            _nipController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  void _handleDemoLogin(String nip, String name, String role) async {
    await ref.read(authNotifierProvider.notifier).demoLogin(
          nip: nip,
          name: name,
          role: role,
        );
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : AppColors.slateNavy;
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.mutedText;
    final labelTextColor = isDark ? const Color(0xFFF1F5F9) : AppColors.deepCharcoal;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Identitas BNPB
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 36,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.appTagline,
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (authState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.statusDanger),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.statusDanger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.statusDanger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Field NIP
                  Text(
                    AppStrings.nipLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: labelTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nipController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: AppStrings.nipHint,
                      prefixIcon: Icon(Icons.badge_outlined, color: AppColors.mutedText),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Silakan masukkan NIP resmi Anda';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field Kata Sandi
                  Text(
                    AppStrings.passwordLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: labelTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: AppStrings.passwordHint,
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.mutedText),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan masukkan kata sandi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tombol Masuk
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.loginAction),
                  ),

                  const SizedBox(height: 28),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 16),

                  // Tombol Cepat Uji Lapangan TRC dan Pegawai
                  const Text(
                    'Mode Uji Lapangan dan Darurat:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.emergency_outlined, size: 18),
                    label: const Text('Masuk sebagai Tim Reaksi Cepat (TRC)'),
                    onPressed: () => _handleDemoLogin(
                      '199208142018011003',
                      'Rizki Pratama (TRC Bencana)',
                      'field_trc',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.business_outlined, size: 18),
                    label: const Text('Masuk sebagai Staf Kantor Pusat (WFO)'),
                    onPressed: () => _handleDemoLogin(
                      '198705202010121002',
                      'Budi Santoso (Pusdalops WFO)',
                      'staff_wfo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
