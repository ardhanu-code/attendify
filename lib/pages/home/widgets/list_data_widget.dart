import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/absen_history_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListDataWidget extends StatefulWidget {
  final Future<List<HistoryAbsenData>> futureAbsenHistory;

  const ListDataWidget({Key? key, required this.futureAbsenHistory})
    : super(key: key);

  @override
  State<ListDataWidget> createState() => _ListDataWidgetState();
}

class _ListDataWidgetState extends State<ListDataWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryAbsenData>>(
      future: widget.futureAbsenHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.primary),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load data'));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return Center(child: Text('No attendance data'));
        }

        // Sort data descending by attendanceDate (today at top, older below)
        final sortedData = List<HistoryAbsenData>.from(data);
        sortedData.sort((a, b) {
          final aDate = a.attendanceDate ?? DateTime(1970);
          final bDate = b.attendanceDate ?? DateTime(1970);
          return bDate.compareTo(aDate); // descending
        });

        // Only show the first 7 items
        final limitedData = sortedData.take(7).toList();

        return ListView.builder(
          itemCount: limitedData.length,
          itemBuilder: (BuildContext context, int index) {
            final absen = limitedData[index];

            final date = absen.attendanceDate ?? DateTime.now();
            final isWeekend = date.weekday == 6 || date.weekday == 7;
            if (isWeekend) {
              return SizedBox.shrink();
            }

            final dayName = _getDayName(date.weekday);
            final dateStr = '${date.day}/${date.month}/${date.year}';

            String statusStr = absen.status
                .toString()
                .split('.')
                .last
                .toLowerCase();

            final isLate = (statusStr == 'late');
            final isPermission =
                (statusStr == 'permission' || statusStr == 'izin');
            final isMasuk = (statusStr == 'masuk');

            // Tampilkan jam checkin dan out seperti di detail_absen_page.dart
            String formatTime(String? timeStr) {
              if (timeStr == null || timeStr.isEmpty) return '-- : -- : --';
              if (timeStr.length >= 8 && timeStr.contains(':')) {
                if (timeStr.contains(' ')) {
                  final parts = timeStr.split(' ');
                  if (parts.length > 1) {
                    return parts[1];
                  }
                }
                return timeStr;
              }
              return timeStr;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                  color: isLate
                      ? Colors.red.withOpacity(0.05)
                      : isPermission
                      ? Colors.orange.withOpacity(0.05)
                      : isMasuk
                      ? Colors.green.withOpacity(0.05)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(width: 18),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayName,
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isLate)
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'LATE',
                                  style: GoogleFonts.lexend(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (isPermission)
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PERMISSION',
                                  style: GoogleFonts.lexend(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (isMasuk)
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PRESENT',
                                  style: GoogleFonts.lexend(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Check in',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: Colors.black45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formatTime(absen.checkInTime),
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isLate ? Colors.red : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Check out',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: Colors.black45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formatTime(absen.checkOutTime),
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLate
                              ? Colors.red
                              : isPermission
                              ? Colors.orange
                              : isMasuk
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
