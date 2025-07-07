import 'package:attendify/const/app_color.dart';
import 'package:attendify/pages/detail_absen_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        onPressed: () {},
        tooltip: 'Absen',
        backgroundColor: AppColor.primary,
        child: Icon(Icons.fingerprint, color: AppColor.text, size: 28),
      ),
    );
  }

  Widget _listData() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hari',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: AppColor.primary,

                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),

                          Text(
                            'Tanggal',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: AppColor.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
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
                            '00 : 00 : 00',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
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
                            '00 : 00 : 00',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
          'Attendance History',
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
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
              _buildDetailRow(label: 'Date:', value: '2025-07-07'),
              _buildDetailRow(label: 'Check In:', value: '2025-07-07 01:53:24'),
              _buildDetailRow(label: 'Check In Address:', value: 'Jakarta'),
              _buildDetailRow(
                label: 'Check Out:',
                value: '2025-07-07 01:53:27',
              ),
              _buildDetailRow(label: 'Check Out Address:', value: 'Jakarta'),
              _buildDetailRow(label: 'Status:', value: 'present'),
              _buildDetailRow(label: 'Permission Reason:', value: 'null'),
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
              onPressed: () {},
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
}
