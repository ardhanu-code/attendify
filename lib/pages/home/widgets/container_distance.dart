import 'package:attendify/const/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContainerDistanceAndOpenMapWidget extends StatefulWidget {
  final double? distanceFromOffice;

  const ContainerDistanceAndOpenMapWidget({
    Key? key,
    required this.distanceFromOffice,
  }) : super(key: key);

  @override
  State<ContainerDistanceAndOpenMapWidget> createState() =>
      _ContainerDistanceAndOpenMapWidgetState();
}

class _ContainerDistanceAndOpenMapWidgetState
    extends State<ContainerDistanceAndOpenMapWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance from place',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppColor.secondary,
                  ),
                ),
                Text(
                  widget.distanceFromOffice != null
                      ? '${widget.distanceFromOffice!.toStringAsFixed(1)}m'
                      : '...',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();

                // Manual formatting for Indonesian date: Rabu, 15 Juli 2025
                const hari = [
                  'Minggu',
                  'Senin',
                  'Selasa',
                  'Rabu',
                  'Kamis',
                  'Jumat',
                  'Sabtu',
                ];
                const bulan = [
                  '',
                  'Januari',
                  'Februari',
                  'Maret',
                  'April',
                  'Mei',
                  'Juni',
                  'Juli',
                  'Agustus',
                  'September',
                  'Oktober',
                  'November',
                  'Desember',
                ];

                String pad(int n) => n.toString().padLeft(2, '0');
                String hariString = hari[now.weekday % 7];
                String bulanString = bulan[now.month];
                String dateString =
                    '$hariString, ${now.day} $bulanString ${now.year}';
                String timeString =
                    '${pad(now.hour)}:${pad(now.minute)}:${pad(now.second)}';

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      dateString,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.secondary,
                      ),
                    ),
                    Text(
                      timeString,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
