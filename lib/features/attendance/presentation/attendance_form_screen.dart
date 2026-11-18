import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

class AttendanceFormScreen extends ConsumerStatefulWidget {
  const AttendanceFormScreen({super.key});

  @override
  ConsumerState<AttendanceFormScreen> createState() => _AttendanceFormScreenState();
}

class _AttendanceFormScreenState extends ConsumerState<AttendanceFormScreen> {
  XFile? _selfieFile;
  XFile? _sptFile;
  final _notesController = TextEditingController();
  final _operationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    _operationController.dispose();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    final camera = ref.read(cameraServiceProvider);
    final photo = await camera.captureLiveSelfie();
    if (photo != null) {
      setState(() {
        _selfieFile = photo;
      });
    }
  }

  Future<void> _pickSpt() async {
    final camera = ref.read(cameraServiceProvider);
    final doc = await camera.pickSptDocument();
    if (doc != null) {
      setState(() {
        _sptFile = doc;
      });
    }
  }

  void _submit() async {
    if (_selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wajib mengambil foto swafoto langsung di lokasi.'),
          backgroundColor: AppColors.statusDanger,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final user = ref.read(authNotifierProvider).user;
      if (user == null) return;

      final success = await ref.read(attendanceNotifierProvider.notifier).submitAttendance(
            user: user,
            photoPath: _selfieFile!.path,
            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
            operationName: _operationController.text.trim().isNotEmpty
                ? _operationController.text.trim()
                : null,
            sptDocumentUrl: _sptFile?.path,
          );

      if (mounted) {
        final state = ref.read(attendanceNotifierProvider);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.statusMessage ?? 'Presensi berhasil disimpan.'),
              backgroundColor: AppColors.statusSuccess,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.statusDanger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final location = attendanceState.locationResult;
    final mode = attendanceState.selectedMode;
    final nowFormatted = DateFormat('dd MMM yyyy, HH:mm:ss').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Presensi Lapangan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kartu Mode Terpilih
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode Aktif: ${_getModeTitle(mode)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Area Pratinjau Swafoto dengan Watermark Koordinat & Timestamp
              const Text(
                'Swafoto Wajah Petugas (Live Camera):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateNavy,
                ),
              ),
              const SizedBox(height: 8),
              if (_selfieFile != null)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_selfieFile!.path),
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Watermark Koordinat & Stempel Waktu (Semi-transparan)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Waktu: $nowFormatted WIB',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          Text(
                            'Koordinat: ${location?.latitude.toStringAsFixed(6)}, ${location?.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Sistem Presensi Resmi BNPB',
                            style: TextStyle(color: AppColors.primaryOrange, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_front_outlined,
                          size: 48,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada foto swafoto',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 18),
                label: Text(_selfieFile == null ? AppStrings.takeSelfie : 'Ambil Ulang Swafoto'),
                onPressed: _takeSelfie,
              ),
              const SizedBox(height: 18),

              // Masukan Khusus WFH: Catatan Kegiatan Harian
              if (mode == 'wfh') ...[
                const Text(
                  AppStrings.dailyNotesLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slateNavy,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: AppStrings.dailyNotesHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Staf WFH wajib mengisi ringkasan kegiatan harian.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
              ],

              // Masukan Khusus Lapangan / TRC Darurat: Nama Operasi & SPT
              if (mode == 'field') ...[
                const Text(
                  AppStrings.disasterNameLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slateNavy,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _operationController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.disasterNameHint,
                    prefixIcon: Icon(Icons.flag_outlined, color: AppColors.mutedText),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib mencantumkan nama operasi atau posko penugasan.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  AppStrings.sptUploadLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slateNavy,
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  icon: const Icon(Icons.attachment_outlined, size: 18),
                  label: Text(_sptFile == null ? 'Unggah Foto Dokumen SPT' : 'Dokumen SPT Terlampir'),
                  onPressed: _pickSpt,
                ),
                const SizedBox(height: 18),
              ],

              // Tombol Pengiriman Presensi
              ElevatedButton(
                onPressed: attendanceState.isSubmitting ? null : _submit,
                child: attendanceState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(AppStrings.recordAttendance),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getModeTitle(String mode) {
    switch (mode) {
      case 'wfo':
        return AppStrings.modeWfo;
      case 'wfh':
        return AppStrings.modeWfh;
      case 'field':
        return AppStrings.modeField;
      default:
        return mode;
    }
  }
}
