import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/attendance_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final history = attendanceState.historyList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Presensi Personel'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await ref.read(attendanceNotifierProvider.notifier).loadHistory(user.id);
          }
        },
        child: _buildContent(context, attendanceState, user, ref),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AttendanceState state,
    dynamic user,
    WidgetRef ref,
  ) {
    // 1. Status Memuat (Loading State - R-27)
    if (state.isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Memuat data riwayat presensi...',
              style: TextStyle(color: AppColors.mutedText, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // 2. Status Kosong (Empty State - R-27)
    if (state.historyList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.borderLight.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_busy_outlined,
                  size: 36,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.emptyHistory,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateNavy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Data presensi harian yang Anda kirim akan muncul dalam daftar ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Tampilan Daftar Riwayat Presensi
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.historyList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = state.historyList[index];
        return _buildAttendanceCard(context, item);
      },
    );
  }

  Widget _buildAttendanceCard(BuildContext context, AttendanceModel item) {
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm').format(item.timestamp);
    final isSynced = item.syncStatus == 'synced';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailDialog(context, item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatModeLabel(item.mode),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slateNavy,
                    ),
                  ),
                  _buildSyncBadge(isSynced),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.mutedText),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.pin_drop_outlined, size: 14, color: AppColors.mutedText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Koordinat: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.deepCharcoal),
                    ),
                  ),
                ],
              ),
              if (item.operationName != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Operasi: ${item.operationName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncBadge(bool isSynced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSynced ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSynced ? AppColors.statusSuccess : AppColors.statusWarning,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced ? Icons.cloud_done : Icons.cloud_queue,
            size: 12,
            color: isSynced ? AppColors.statusSuccess : AppColors.statusWarning,
          ),
          const SizedBox(width: 4),
          Text(
            isSynced ? 'Tersinkron' : 'Tersimpan Lokal',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSynced ? AppColors.statusSuccess : AppColors.statusWarning,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, AttendanceModel item) {
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm:ss').format(item.timestamp);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Detail Presensi ${_formatModeLabel(item.mode)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Pegawai', item.userName),
              _detailRow('NIP', item.nip),
              _detailRow('Waktu Catat', dateStr),
              _detailRow('Lintang', item.latitude.toStringAsFixed(6)),
              _detailRow('Bujur', item.longitude.toStringAsFixed(6)),
              _detailRow('Jarak Target', '${item.distanceToTarget.toStringAsFixed(1)} m'),
              _detailRow(
                'Status Sinkronisasi',
                item.syncStatus == 'synced' ? 'Tersinkron ke Cloud' : 'Antrean Offline Lokal',
              ),
              if (item.notes != null) _detailRow('Catatan Aktivitas', item.notes!),
              if (item.operationName != null) _detailRow('Nama Operasi', item.operationName!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedText)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatModeLabel(String mode) {
    switch (mode) {
      case 'wfo':
        return 'WFO (Kantor Pusat)';
      case 'wfh':
        return 'WFH (Tempat Tinggal)';
      case 'field':
        return 'TRC Lapangan Bencana';
      default:
        return mode.toUpperCase();
    }
  }
}
