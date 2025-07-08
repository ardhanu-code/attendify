import 'package:attendify/const/app_color.dart';
import 'package:attendify/pages/detail_absen_page.dart';
import 'package:attendify/pages/maps_page.dart';
import 'package:attendify/pages/profile_page.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendify/widgets/detail_row.dart';
import 'package:attendify/models/absen_history_model.dart';
import 'package:attendify/services/absen_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<HistoryAbsenData>>? _futureAbsenHistory;
  String? token;

  @override
  void initState() {
    super.initState();
    _initTokenAndFetchHistory();
  }

  Future<void> _initTokenAndFetchHistory() async {
    final savedToken = await Preferences.getToken();
    if (savedToken != null) {
      setState(() {
        token = savedToken;
        _futureAbsenHistory = AbsenServices.fetchAbsenHistory(token!);
      });
    }
  }

  Future<void> _refreshData() async {
    if (token != null) {
      setState(() {
        _futureAbsenHistory = AbsenServices.fetchAbsenHistory(token!);
      });
      // Wait for the fetch to complete
      await _futureAbsenHistory;
    } else {
      await _initTokenAndFetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.text,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildContainerDistanceAndOpenMaps(),
              const SizedBox(height: 16),
              _buildContainerCheckInAndOut(),
              const SizedBox(height: 4),
              _buildRiwayatAndDetails(),
              // Wrap attendance list with RefreshIndicator
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppColor.primary,
                  child: _listDataContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColor.text,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/icons/attend.png',
                  width: 80,
                  height: 80,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Attend Now!',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'If you ever not check in, tap check in.\nIf you\'re already checked in tap check out',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapsPage(),
                              ),
                            );
                          },
                          text: 'Check in',
                          height: 45,
                          backgroundColor: AppColor.primary,
                          borderRadius: BorderRadius.circular(10),
                          textStyle: GoogleFonts.lexend(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          onPressed: () {},
                          text: 'Check out',
                          height: 45,
                          backgroundColor: AppColor.primary,
                          borderRadius: BorderRadius.circular(10),
                          textStyle: GoogleFonts.lexend(
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        tooltip: 'Absen',
        backgroundColor: AppColor.primary,
        child: Icon(Icons.fingerprint, color: AppColor.text, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    Widget greetingWithIcon() {
      final hour = DateTime.now().hour;
      String greetingText;
      String assetPath;

      if (hour >= 5 && hour < 12) {
        greetingText = 'Good morning';
        assetPath =
            'assets/icons/morning.png'; // replace with your morning icon asset
      } else if (hour >= 12 && hour < 17) {
        greetingText = 'Good afternoon';
        assetPath =
            'assets/icons/afternoon.png'; // replace with your afternoon icon asset
      } else if (hour >= 17 && hour < 21) {
        greetingText = 'Good evening';
        assetPath =
            'assets/icons/evening.png'; // replace with your evening icon asset
      } else {
        greetingText = 'Good night';
        assetPath =
            'assets/icons/night.png'; // replace with your night icon asset
      }

      return Row(
        children: [
          Text(
            greetingText,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 4),
          Image.asset(assetPath, width: 24, height: 24),
        ],
      );
    }

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColor.secondary,
          radius: 30,
          child: Icon(Icons.person, color: AppColor.text, size: 30),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            greetingWithIcon(),
            Text('Sakti Ardhanu', style: GoogleFonts.lexend(fontSize: 12)),
            GestureDetector(
              onTap: () {
                _showDialogDetailsAttended();
              },
              child: Row(
                children: [
                  Text(
                    'Attended',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 10, color: Colors.green),
                ],
              ),
            ),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Open profile')));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          },
          child: Container(
            height: 32,
            width: 35,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.secondary),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outlined, size: 18),
          ),
        ),
      ],
    );
  }

  Future<dynamic> _showDialogDetailsAttended() {
    // Contoh: gunakan data dari model jika ingin menampilkan data hari ini
    // Untuk sekarang, tetap hardcode, sesuaikan jika ingin ambil dari model
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Today\'s Attendance Data',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailRow(label: 'Date:', value: '2025-07-07'),
              DetailRow(label: 'Check In:', value: '2025-07-07 01:53:24'),
              DetailRow(label: 'Check In Address:', value: 'Jakarta'),
              DetailRow(label: 'Check Out:', value: '2025-07-07 01:53:27'),
              DetailRow(label: 'Check Out Address:', value: 'Jakarta'),
              DetailRow(label: 'Status:', value: 'present'),
              DetailRow(label: 'Permission Reason:', value: 'null'),
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

  Widget _buildContainerDistanceAndOpenMaps() {
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
              children: [
                Text(
                  'Distance from place',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppColor.secondary,
                  ),
                ),
                Text(
                  '123.0m',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.text,
                minimumSize: Size(80, 35),
                padding: EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Open Maps', style: GoogleFonts.lexend(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCheckInAndOut() {
    return Container(
      height: 140,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: ShapeDecoration(
                      shape: CircleBorder(),
                      color: AppColor.text,
                    ),
                    child: Icon(Icons.location_on, size: 14),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Your address will be appear here...',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppColor.text,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14),
            Container(
              height: 68,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.secondary,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check in',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                        Text(
                          '00 : 00 : 00',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: AppColor.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: VerticalDivider(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check out',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                        Text(
                          '00 : 00 : 00',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
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
          ],
        ),
      ),
    );
  }

  Widget _listDataContent() {
    return Expanded(
      child: FutureBuilder<List<HistoryAbsenData>>(
        future: _futureAbsenHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(child: Text('No attendance data'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final absen = data[index];

              // Use checkIn for date, skip if null
              final date = absen.checkIn ?? absen.createdAt ?? DateTime.now();
              final isWeekend = date.weekday == 6 || date.weekday == 7;
              if (isWeekend) {
                return SizedBox.shrink();
              }

              final dayName = _getDayName(date.weekday);
              final dateStr = '${date.day}/${date.month}/${date.year}';
              final isLate = (absen.status?.toLowerCase() == 'late');
              final isPermission =
                  (absen.status?.toLowerCase() == 'permission' ||
                  absen.status?.toLowerCase() == 'izin');

              String formatTime(DateTime? dt) {
                if (dt == null) return '-';
                return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
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
                                formatTime(absen.checkIn),
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
                                formatTime(absen.checkOut),
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
                                : Colors.green,
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
      ),
    );
  }

  Widget _buildRiwayatAndDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Attendance History (7 Days)',
          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetailAbsenPage()),
            );
          },
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
