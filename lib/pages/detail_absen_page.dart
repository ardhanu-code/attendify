import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/absen_history_model.dart';
import 'package:attendify/models/stat_absen_model.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/absen_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendify/widgets/detail_row.dart';
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
      List<HistoryAbsenData> historyAbsen =
          await AbsenServices.fetchAbsenHistory(token ?? '');
      setState(() {
        listHistoryAbsen = historyAbsen;
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
          onPressed: () => Navigator.pop(context),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColor.tertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton.icon(
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
        ),
      ],
    );
  }

  Widget _buildAttendanceList() {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );

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
        final date = absen.checkIn ?? absen.createdAt;
        final day = date != null ? DateFormat('EEEE').format(date) : '-';
        final dateStr = date != null
            ? DateFormat('dd/MM/yyyy').format(date)
            : '--/--/----';
        final checkInTime = absen.checkIn != null
            ? DateFormat('HH:mm:ss').format(absen.checkIn!)
            : '-- : -- : --';
        final checkOutTime = absen.checkOut != null
            ? DateFormat('HH:mm:ss').format(absen.checkOut!)
            : '-- : -- : --';

        return GestureDetector(
          onTap: () => _showDetailDialog(absen),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
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
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Check In",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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
                      const Text(
                        "Check Out",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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
                    color: absen.status == 'masuk'
                        ? Colors.green
                        : absen.status == 'izin'
                        ? Colors.orange
                        : Colors.red,
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
    String formatTime(DateTime? dateTime) =>
        dateTime != null ? DateFormat('HH:mm:ss').format(dateTime) : '-';
    String formatDate(DateTime? dateTime) => dateTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
        : '-';

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
                label: 'User ID:',
                value: absen.userId?.toString() ?? '-',
              ),
              DetailRow(label: 'Check In:', value: formatTime(absen.checkIn)),
              DetailRow(
                label: 'Check In Location:',
                value: absen.checkInLocation ?? '-',
              ),
              DetailRow(
                label: 'Check In Address:',
                value: absen.checkInAddress ?? '-',
              ),
              DetailRow(label: 'Check Out:', value: formatTime(absen.checkOut)),
              DetailRow(
                label: 'Check Out Location:',
                value: absen.checkOutLocation ?? '-',
              ),
              DetailRow(
                label: 'Check Out Address:',
                value: absen.checkOutAddress ?? '-',
              ),
              DetailRow(label: 'Status:', value: absen.status ?? '-'),
              DetailRow(
                label: 'Alasan Izin:',
                value: (absen.alasanIzin?.toString().trim().isNotEmpty ?? false)
                    ? absen.alasanIzin
                    : '-',
              ),
              DetailRow(
                label: 'Created At:',
                value: formatDate(absen.createdAt),
              ),
              DetailRow(
                label: 'Updated At:',
                value: formatDate(absen.updatedAt),
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
