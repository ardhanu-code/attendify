import 'package:attendify/const/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailAbsenPage extends StatefulWidget {
  const DetailAbsenPage({super.key});

  @override
  State<DetailAbsenPage> createState() => _DetailAbsenPageState();
}

class _DetailAbsenPageState extends State<DetailAbsenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.text,
      appBar: AppBar(
        title: Text(
          'Detail Attendance',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: AppColor.text,
        foregroundColor: AppColor.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Column(
            children: [
              _buildSummaryCard(),
              SizedBox(height: 16),
              _buildFilterSection(),
              SizedBox(height: 8),
              _buildAttendanceList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Attendance',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    '22',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      color: AppColor.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(color: Colors.white60, thickness: 1),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Present',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    '18',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      color: AppColor.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(color: Colors.white60, thickness: 1),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Permission',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    '4',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      color: AppColor.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance Records',
          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColor.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 18,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: Implement filter action
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, size: 16, color: AppColor.primary),
                  SizedBox(width: 4),
                  Text(
                    'Filter',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 30,
        itemBuilder: (BuildContext context, int index) {
          // Generate sample data
          DateTime date = DateTime.now().subtract(Duration(days: index));
          String dayName = _getDayName(date.weekday);
          String dateStr = '${date.day}/${date.month}/${date.year}';
          bool isLate = index % 7 == 0; // Every 7th day is late
          bool isWeekend = date.weekday == 6 || date.weekday == 7;

          if (isWeekend) {
            return SizedBox.shrink(); // Hide weekends
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Attendance Detail',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(label: 'Name:', value: '1'),
                          _buildDetailRow(
                            label: 'Check In:',
                            value: '2025-04-10 07:54:40',
                          ),
                          _buildDetailRow(
                            label: 'Check In Location:',
                            value: '-6.2, 106.8',
                          ),
                          _buildDetailRow(
                            label: 'Check In Address:',
                            value: 'Jakarta',
                          ),
                          _buildDetailRow(
                            label: 'Check Out:',
                            value: '2025-04-10 07:56:51',
                          ),
                          _buildDetailRow(
                            label: 'Check Out Location:',
                            value: '-6.2, 106.8',
                          ),
                          _buildDetailRow(
                            label: 'Check Out Address:',
                            value: 'Jakarta',
                          ),
                          _buildDetailRow(label: 'Status:', value: 'masuk'),
                          _buildDetailRow(label: 'Alasan Izin:', value: 'null'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Close',
                          style: GoogleFonts.lexend(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                  color: isLate ? Colors.red.withOpacity(0.05) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Date section
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
                          ],
                        ),
                      ),
                      // Check in section
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
                              isLate ? '08:15:30' : '08:00:00',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isLate ? Colors.red : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Check out section
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
                              '17:00:00',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isLate ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Perbaikan _buildDetailRow:
  // - Ubah dari positional ke named parameter (label, value, dst)
  // - Pastikan pemanggilan di atas juga pakai named parameter
  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    FontWeight? valueFontWeight,
    double? valueFontSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.lexend(
                fontSize: valueFontSize ?? 12,
                color: valueColor ?? Colors.black87,
                fontWeight: valueFontWeight ?? FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
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
        return 'Unknown';
    }
  }
}
