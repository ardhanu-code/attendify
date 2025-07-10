import 'package:attendify/const/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apakah ini dari class ini? Jawab: Ya, kode di bawah ini adalah class SectionRiwayatDetailsWidget.
/// Kode ini identik dengan potongan kode pada file_context_0, hanya saja di sini dibuat sebagai widget terpisah.
/// Fungsinya sama, yaitu menampilkan judul "Attendance History (7 Days)" dan tombol "Details".

class SectionRiwayatDetailsWidget extends StatelessWidget {
  final VoidCallback? onDetailsPressed;

  const SectionRiwayatDetailsWidget({Key? key, this.onDetailsPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance History (7 Days)',
          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: onDetailsPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColor.primary,
            minimumSize: const Size(80, 35),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Text('Details', style: GoogleFonts.lexend(fontSize: 12)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 10),
            ],
          ),
        ),
      ],
    );
  }
}
