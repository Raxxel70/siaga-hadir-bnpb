import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/attendance_provider.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final queueService = ref.watch(hiveQueueServiceProvider);
    final pendingItems = queueService.getPendingQueue();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrean Sinkronisasi Lapangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Penjelasan Mekanisme Zona Bencana
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_off_outlined, color: AppColors.primaryDark),
                      SizedBox(width: 8),
                      Text(
                        'Resiliensi Blank-Spot BNPB',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Saat berada di lokasi bencana tanpa sinyal, seluruh rekaman presensi disimpan aman di memori lokal gawai. Data akan otomatis diunggah ketika internet kembali terhubung.',
                    style: TextStyle(fontSize: 12, color: AppColors.deepCharcoal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Belum Tersinkron:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slateNavy,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: pendingItems.isEmpty
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pendingItems.length} Catatan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: pendingItems.isEmpty
                          ? AppColors.statusSuccess
                          : AppColors.statusWarning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: pendingItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 56,
                            color: AppColors.statusSuccess,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Semua Data Telah Tersinkron',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slateNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tidak ada data presensi yang tertunda di memori lokal.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: pendingItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = pendingItems[index];
                        final dateStr =
                            DateFormat('dd MMM yyyy, HH:mm:ss').format(item.timestamp);
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.schedule_outlined,
                              color: AppColors.statusWarning,
                            ),
                            title: Text(
                              'Presensi ${item.mode.toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              '$dateStr\nKoordinat: ${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.cloud_upload_outlined),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: Text(
                attendanceState.isSubmitting
                    ? 'Menghubungkan ke Server...'
                    : AppStrings.syncNowAction,
              ),
              onPressed: pendingItems.isEmpty || attendanceState.isSubmitting
                  ? null
                  : () async {
                      await ref.read(attendanceNotifierProvider.notifier).syncNow();
                    },
            ),
          ],
        ),
      ),
    );
  }
}
