import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/absen_history_model.dart';
import 'package:attendify/models/stat_absen_model.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/absen_services.dart';
import 'package:attendify/widgets/detail_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailAbsenPage extends StatefulWidget {
  const DetailAbsenPage({super.key});

  @override
  State<DetailAbsenPage> createState() => _DetailAbsenPageState();
}

class _DetailAbsenPageState extends State<DetailAbsenPage> {
  List<HistoryAbsenData> listHistoryAbsen = [];
  StatDataAbsen? statAbsen;
  bool _isLoading = true;

  Future<void> _getHistoryAbsen() async {
    setState(() => _isLoading = true);
    try {
      String? token = await Preferences.getToken();
      final response = await AbsenServices.fetchAbsenHistory(token ?? '');
      listHistoryAbsen = response;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getStatAbsen() async {
    setState(() => _isLoading = true);
    try {
      String? token = await Preferences.getToken();
      StatAbsenResponse statAbsenData = await AbsenServices.fetchStatAbsen(
        token ?? '',
      );
      setState(() {
        statAbsen = statAbsenData.data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getHistoryAbsen();
    _getStatAbsen();
  }

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
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back_ios, size: 18),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 16),
              _buildFilterSection(),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _getHistoryAbsen();
                    await _getStatAbsen();
                  },
                  color: AppColor.primary,
                  child: _buildAttendanceList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    int total = statAbsen?.totalAbsen ?? 0;
    int present = statAbsen?.totalMasuk ?? 0;
    int permission = statAbsen?.totalIzin ?? 0;

    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary, AppColor.primary.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            _buildSummaryItem('Attendance', total),
            const VerticalDivider(color: Colors.white60, thickness: 1),
            _buildSummaryItem('Present', present),
            const VerticalDivider(color: Colors.white60, thickness: 1),
            _buildSummaryItem('Permission', permission),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, int count) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(fontSize: 12, color: Colors.white60),
          ),
          Text(
            '$count',
            style: GoogleFonts.lexend(
              fontSize: 20,
              color: AppColor.text,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
        TextButton.icon(
          icon: Icon(Icons.filter_list, size: 16, color: AppColor.primary),
          label: Text(
            'Filter',
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: AppColor.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == "null") {
      return '-- : -- : --';
    }
    // Try to parse as HH:mm:ss or HH:mm
    try {
      // If already in HH:mm:ss
      if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(timeStr)) {
        return timeStr;
      }
      // If in HH:mm, add :00
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(timeStr)) {
        return '$timeStr:00';
      }
      // If in ISO format (e.g. 2024-06-01T08:30:00), extract time
      if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}').hasMatch(timeStr)) {
        final dt = DateTime.parse(timeStr);
        return DateFormat('HH:mm:ss').format(dt);
      }
      // Try to parse as DateTime
      final dt = DateTime.tryParse(timeStr);
      if (dt != null) {
        return DateFormat('HH:mm:ss').format(dt);
      }
    } catch (_) {}
    return timeStr;
  }

  Widget _buildAttendanceList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );
    }

    if (listHistoryAbsen.isEmpty) {
      return Center(
        child: Text(
          "No attendance records found.",
          style: GoogleFonts.lexend(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      itemCount: listHistoryAbsen.length,
      itemBuilder: (context, index) {
        final absen = listHistoryAbsen[index];

        // Tanggal
        final date = absen.attendanceDate;
        final day = DateFormat.EEEE('en_US').format(date);
        final dateStr = DateFormat('dd/MM/yyyy', 'en_US').format(date);

        // Check In Time
        String checkInTime = _formatTime(absen.checkInTime);

        // Check Out Time
        String checkOutTime = _formatTime(absen.checkOutTime);

        // Status
        Color statusColor;
        bool isMasuk = absen.status == Status.MASUK;
        bool isIzin = absen.status == Status.IZIN;
        bool isLate =
            false; // Bisa ditambahkan logika untuk late jika diperlukan

        if (isMasuk) {
          statusColor = Colors.green;
        } else if (isIzin) {
          statusColor = Colors.orange;
        } else if (isLate) {
          statusColor = Colors.red;
        } else {
          statusColor = Colors.grey;
        }

        return GestureDetector(
          onTap: () => _showDetailDialog(absen),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
              color: isMasuk
                  ? Colors.green.withOpacity(0.05)
                  : isIzin
                  ? Colors.orange.withOpacity(0.05)
                  : isLate
                  ? Colors.red.withOpacity(0.05)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(dateStr, style: GoogleFonts.lexend(fontSize: 12)),
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
                      if (isIzin)
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
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check In",
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        checkInTime,
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check Out",
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        checkOutTime,
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetailDialog(HistoryAbsenData absen) {
    // Format waktu check in dan check out
    String checkInTime = _formatTime(absen.checkInTime);
    String checkOutTime = _formatTime(absen.checkOutTime);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Attendance Detail',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DetailRow(
                label: 'Date:',
                value: DateFormat('dd/MM/yyyy').format(absen.attendanceDate),
              ),
              DetailRow(label: 'Check In:', value: checkInTime),
              DetailRow(
                label: 'Check In Location:',
                value: absen.checkInLocation ?? '-',
              ),
              DetailRow(
                label: 'Check In Address:',
                value: absen.checkInAddress ?? '-',
              ),
              DetailRow(label: 'Check Out:', value: checkOutTime),
              DetailRow(
                label: 'Check Out Location:',
                value: absen.checkOutLocation?.toString() ?? '-',
              ),
              DetailRow(
                label: 'Check Out Address:',
                value: absen.checkOutAddress?.toString() ?? '-',
              ),
              DetailRow(
                label: 'Status:',
                value: absen.status == Status.MASUK
                    ? 'Masuk'
                    : absen.status == Status.IZIN
                    ? 'Izin'
                    : '-',
              ),
              DetailRow(
                label: 'Alasan Izin:',
                value: (absen.alasanIzin?.toString().trim().isNotEmpty ?? false)
                    ? absen.alasanIzin!.toString()
                    : '-',
              ),
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
  }
}
