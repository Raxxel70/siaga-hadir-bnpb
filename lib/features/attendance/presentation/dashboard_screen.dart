import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import 'attendance_form_screen.dart';
import 'history_screen.dart';
import 'sync_queue_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(attendanceNotifierProvider.notifier).checkLocation(user);
        ref.read(attendanceNotifierProvider.notifier).loadHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return const LoginScreen();
    }

    final location = attendanceState.locationResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.cloud_sync_outlined),
                if (attendanceState.pendingCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.statusWarning,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${attendanceState.pendingCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Antrean Sinkronisasi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SyncQueueScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(attendanceNotifierProvider.notifier).checkLocation(user);
          await ref.read(attendanceNotifierProvider.notifier).loadHistory(user.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kartu Profil Pegawai BNPB
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'B',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slateNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NIP: ${user.nip}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.deepCharcoal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.department,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pilihan Tiga Mode Presensi Operasional
              const Text(
                'Pilih Mode Presensi Hari Ini:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateNavy,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ModeSelectorButton(
                      label: 'WFO',
                      sublabel: 'Kantor Pusat',
                      isSelected: attendanceState.selectedMode == 'wfo',
                      onTap: () => ref
                          .read(attendanceNotifierProvider.notifier)
                          .setMode('wfo', user),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeSelectorButton(
                      label: 'WFH',
                      sublabel: 'Tempat Tinggal',
                      isSelected: attendanceState.selectedMode == 'wfh',
                      onTap: () => ref
                          .read(attendanceNotifierProvider.notifier)
                          .setMode('wfh', user),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeSelectorButton(
                      label: 'Lapangan',
                      sublabel: 'TRC Darurat',
                      isSelected: attendanceState.selectedMode == 'field',
                      onTap: () => ref
                          .read(attendanceNotifierProvider.notifier)
                          .setMode('field', user),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kartu Status Geolocation & Haversine Geofencing
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Koordinat GPS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slateNavy,
                            ),
                          ),
                          if (attendanceState.isCheckingLocation)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Perbarui Lokasi',
                              onPressed: () => ref
                                  .read(attendanceNotifierProvider.notifier)
                                  .checkLocation(user),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (location != null && location.errorMessage == null) ...[
                        _buildInfoRow('Lintang (Latitude)', location.latitude.toStringAsFixed(6)),
                        const SizedBox(height: 6),
                        _buildInfoRow('Bujur (Longitude)', location.longitude.toStringAsFixed(6)),
                        const SizedBox(height: 6),
                        _buildInfoRow('Akurasi Sinyal', '± ${location.accuracy.toStringAsFixed(1)} meter'),
                        const SizedBox(height: 6),
                        _buildInfoRow(
                          'Jarak ke Target',
                          attendanceState.selectedMode == 'field'
                              ? 'Tidak Dibatasi (Zona Tanggap Darurat)'
                              : '${location.distanceToTarget.toStringAsFixed(1)} meter',
                        ),
                        const SizedBox(height: 12),

                        // Indikator Mock Location
                        if (location.isMocked)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.statusDanger),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: AppColors.statusDanger, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppStrings.mockLocationDetected,
                                    style: TextStyle(
                                      color: AppColors.statusDanger,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: location.isWithinGeofence
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: location.isWithinGeofence
                                    ? AppColors.statusSuccess
                                    : AppColors.statusWarning,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  location.isWithinGeofence
                                      ? Icons.check_circle_outline
                                      : Icons.info_outline,
                                  color: location.isWithinGeofence
                                      ? AppColors.statusSuccess
                                      : AppColors.statusWarning,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    location.isWithinGeofence
                                        ? AppStrings.withinRadiusNotice
                                        : AppStrings.outsideRadiusWarning,
                                    style: TextStyle(
                                      color: location.isWithinGeofence
                                          ? AppColors.statusSuccess
                                          : AppColors.statusWarning,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else ...[
                        Text(
                          location?.errorMessage ?? AppStrings.locationChecking,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.statusDanger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Utama: Buka Formulir Presensi
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Buka Formulir Presensi & Swafoto'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AttendanceFormScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Tombol Navigasi Riwayat Presensi
              OutlinedButton.icon(
                icon: const Icon(Icons.history_outlined),
                label: const Text('Lihat Riwayat Presensi'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.deepCharcoal,
          ),
        ),
      ],
    );
  }
}

class _ModeSelectorButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeSelectorButton({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.slateNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
