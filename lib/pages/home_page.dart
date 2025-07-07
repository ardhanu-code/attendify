import 'package:attendify/const/app_color.dart';
import 'package:attendify/pages/detail_absen_page.dart';
import 'package:attendify/pages/maps_page.dart';
import 'package:attendify/widgets/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendify/widgets/detail_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.text,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 16),
              _buildContainerDistanceAndOpenMaps(),
              SizedBox(height: 16),
              _buildContainerCheckInAndOut(),
              SizedBox(height: 4),
              _buildRiwayatAndDetails(),
              _listData(),
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
                    'If you ever not check in, tap check in.\nIf you\'re alredy check in tap check out',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: 16),
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
                      SizedBox(width: 14),
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

  Widget _listData() {
    return Expanded(
      child: ListView.builder(
        itemCount: 7, // tampilkan 7 data saja
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
              MaterialPageRoute(builder: (context) => DetailAbsenPage()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColor.primary,
            minimumSize: Size(80, 35),
            padding: EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Text('Details', style: GoogleFonts.lexend(fontSize: 12)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
            Text(
              'Selamat pagi ganteng',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
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
        SizedBox(width: 88),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Open profile')));
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
                minimumSize: Size(80, 35), // Mengubah width dari 25 ke 80
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ), // Mengubah padding dari 2 ke 8
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
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
