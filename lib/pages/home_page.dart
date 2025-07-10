import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/absen_history_model.dart';
import 'package:attendify/models/profile_model.dart';
import 'package:attendify/models/today_absen_model.dart';
import 'package:attendify/pages/detail_absen_page.dart';
import 'package:attendify/pages/maps_page.dart';
import 'package:attendify/pages/profile_page.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/absen_services.dart';
import 'package:attendify/services/maps_services.dart'; // <--- Tambahkan import maps_services.dart
import 'package:attendify/services/profile_services.dart';
import 'package:attendify/widgets/button.dart';
import 'package:attendify/widgets/detail_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<HistoryAbsenData>>? _futureAbsenHistory;
  String? token;

  Future<ProfileData>? _futureProfile;

  // Variabel untuk menyimpan jarak dan alamat dari maps_services
  double? _distanceFromOffice;
  String? _currentAddress;
  String? _todayCheckInTime;
  String? _todayCheckOutTime;
  bool _hasAttendedToday = false;
  TodayAbsenResponse? _todayAbsenResponse;
  bool _isCheckingOut = false;
  bool _hasCheckedOutToday = false;

  Future<ProfileData> _loadProfile() async {
    final token = await Preferences.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token kosong");
    }
    return ProfileServices.fetchProfile(token);
  }

  @override
  void initState() {
    super.initState();
    _initTokenAndFetchHistory();
    _futureProfile = _loadProfile();
    _fetchLocationData(); // Panggil fungsi dari maps_services.dart di sini
    _fetchTodayAttendanceData(); // Ambil data attendance hari ini
  }

  // Fungsi untuk mengambil data attendance hari ini
  Future<void> _fetchTodayAttendanceData() async {
    try {
      final token = await Preferences.getToken();
      if (token == null || token.isEmpty) return;

      final todayAbsenResponse = await AbsenServices.fetchTodayAbsen(token);
      print('DEBUG: Today absen response: ${todayAbsenResponse.message}');
      print('DEBUG: Today absen data: ${todayAbsenResponse.data}');

      setState(() {
        _todayAbsenResponse = todayAbsenResponse;
      });

      if (todayAbsenResponse.data != null &&
          todayAbsenResponse.data!.jamMasuk != null) {
        final jamMasuk = DateTime.tryParse(todayAbsenResponse.data!.jamMasuk!);
        if (jamMasuk != null) {
          // Format waktu check in
          final checkInTime =
              '${jamMasuk.hour.toString().padLeft(2, '0')} : ${jamMasuk.minute.toString().padLeft(2, '0')} : ${jamMasuk.second.toString().padLeft(2, '0')}';

          setState(() {
            _todayCheckInTime = checkInTime;
            _hasAttendedToday = true;
          });

          // Jika ada jam keluar
          if (todayAbsenResponse.data!.jamKeluar != null) {
            final jamKeluar = DateTime.tryParse(
              todayAbsenResponse.data!.jamKeluar!,
            );
            if (jamKeluar != null) {
              final checkOutTime =
                  '${jamKeluar.hour.toString().padLeft(2, '0')} : ${jamKeluar.minute.toString().padLeft(2, '0')} : ${jamKeluar.second.toString().padLeft(2, '0')}';
              setState(() {
                _todayCheckOutTime = checkOutTime;
              });
            }
          }
        }
      } else {
        // Tidak ada data absensi hari ini
        setState(() {
          _hasAttendedToday = false;
          _todayCheckInTime = null;
          _todayCheckOutTime = null;
        });
      }
    } catch (e) {
      print('Error fetching today attendance: $e');
      setState(() {
        _hasAttendedToday = false;
        _todayCheckInTime = null;
        _todayCheckOutTime = null;
      });
    }
  }

  // Fungsi untuk memanggil maps_services.dart
  Future<void> _fetchLocationData() async {
    try {
      // Asumsikan ada fungsi getDistanceFromOffice() dan getCurrentAddress() di maps_services.dart
      final distance = await MapsServices.getDistanceFromOffice();
      final address = await MapsServices.getCurrentAddress();
      setState(() {
        _distanceFromOffice = distance;
        _currentAddress = address;
      });
    } catch (e) {
      // Handle error jika perlu
      setState(() {
        _distanceFromOffice = null;
        _currentAddress = null;
      });
    }
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
      await _fetchLocationData(); // Refresh lokasi juga saat refresh
      await _fetchTodayAttendanceData(); // Refresh data attendance hari ini
    } else {
      await _initTokenAndFetchHistory();
      await _fetchLocationData();
      await _fetchTodayAttendanceData();
    }
  }

  Future<void> _handleCheckOut() async {
    if (_distanceFromOffice == null || _currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi belum tersedia. Coba refresh lokasi.')),
      );
      return;
    }
    setState(() {
      _isCheckingOut = true;
    });
    try {
      final token = await Preferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan, silakan login ulang.');
      }
      final response = await AbsenServices.checkOut(
        token: token,
        lat: _distanceFromOffice!,
        lng: 0, // Anda bisa ganti dengan posisi longitude user jika ingin
        address: _currentAddress!,
      );
      setState(() {
        _hasCheckedOutToday = true;
      });
      await _fetchTodayAttendanceData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check Out Berhasil: ${response.message}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check Out Gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
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
                            Navigator.of(context).pop(); // Pop dialog
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
                          onPressed: () {
                            Navigator.of(context).pop(); // Pop dialog
                            _showDialogCheckOut(context);
                          },
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

  Future<dynamic> _showDialogCheckOut(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Confirm Check Out',
            style: GoogleFonts.lexend(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to check out?',
            style: GoogleFonts.lexend(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.lexend(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                print('[DEBUG] Check out dialog confirmed');

                setState(() {
                  _isCheckingOut = true;
                });

                try {
                  final token = await Preferences.getToken();
                  print('[DEBUG] Retrieved token: $token');

                  if (token == null || token.isEmpty) {
                    print('[ERROR] Token tidak ditemukan');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Token tidak ditemukan, silakan login ulang.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    setState(() {
                      _isCheckingOut = false;
                    });
                    return;
                  }

                  final position = await MapsServices.getCurrentLocation();
                  print('[DEBUG] Retrieved position: $position');

                  if (position == null) {
                    print('[ERROR] Gagal mendapatkan lokasi');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin lokasi diberikan.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    setState(() {
                      _isCheckingOut = false;
                    });
                    return;
                  }

                  final address = await MapsServices.getAddressFromLatLng(
                    position,
                  );
                  print('[DEBUG] Retrieved address: $address');

                  final response = await AbsenServices.checkOut(
                    token: token,
                    lat: position.latitude,
                    lng: position.longitude,
                    address: address ?? '',
                  );
                  print('[DEBUG] API Response: ${response.message}');

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Check Out Berhasil: ${response.message}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }

                  print('[DEBUG] Refreshing today attendance data...');
                  await _fetchTodayAttendanceData();
                } catch (e) {
                  print('[ERROR] Exception caught: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Check Out Gagal: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isCheckingOut = false;
                    });
                    print('[DEBUG] _isCheckingOut set to false');
                  }
                }
              },
              child: Text(
                'Check Out',
                style: GoogleFonts.lexend(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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
        FutureBuilder(
          future: _futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar(
                backgroundColor: AppColor.secondary,
                radius: 30,
                child: Icon(Icons.person, color: AppColor.text, size: 30),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return CircleAvatar(
                backgroundColor: AppColor.secondary,
                radius: 30,
                child: Icon(Icons.person, color: AppColor.text, size: 30),
              );
            }
            final profile = snapshot.data;
            String? photoUrl = profile?.profilePhoto;
            ImageProvider? imageProvider;
            if (photoUrl != null && photoUrl.isNotEmpty) {
              imageProvider = photoUrl.startsWith('http')
                  ? NetworkImage(photoUrl)
                  : NetworkImage(
                      'https://appabsensi.mobileprojp.com/public/$photoUrl',
                    );
            }
            return CircleAvatar(
              backgroundColor: AppColor.secondary,
              radius: 30,
              backgroundImage: imageProvider,
              child: (imageProvider == null)
                  ? Icon(Icons.person, color: AppColor.text, size: 30)
                  : null,
            );
          },
        ),
        SizedBox(width: 16),
        FutureBuilder(
          future: _futureProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer(
                      duration: Duration(seconds: 3),
                      interval: Duration(seconds: 5),
                      color: Colors.grey.shade300,
                      colorOpacity: 1,
                      enabled: true,
                      direction: ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                    ),
                    Shimmer(
                      duration: Duration(seconds: 3),
                      interval: Duration(seconds: 5),
                      color: Colors.grey.shade300,
                      colorOpacity: 1,
                      enabled: true,
                      direction: ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: 60,
                        height: 14,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 6),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load profile',
                  style: GoogleFonts.lexend(fontSize: 12),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  'No profile data available',
                  style: GoogleFonts.lexend(fontSize: 12),
                ),
              );
            }
            final profile = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                greetingWithIcon(),
                Text(profile.name, style: GoogleFonts.lexend(fontSize: 12)),
                GestureDetector(
                  onTap: () {
                    _showDialogDetailsAttended();
                  },
                  child: Row(
                    children: [
                      Text(
                        _hasAttendedToday ? 'Attended' : 'Not Attended',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: _hasAttendedToday ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: _hasAttendedToday ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
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
    print(
      'DEBUG: Showing dialog with _todayAbsenResponse: $_todayAbsenResponse',
    );
    print('DEBUG: Data in response: ${_todayAbsenResponse?.data}');

    bool canCheckOut = false;
    if (_todayAbsenResponse?.data != null) {
      final data = _todayAbsenResponse!.data!;
      canCheckOut =
          data.jamMasuk != null &&
          (data.jamKeluar == null || data.jamKeluar!.isEmpty);
    }
    ValueNotifier<bool> isDialogCheckingOut = ValueNotifier(false);

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
              if (_todayAbsenResponse?.data != null) ...[
                DetailRow(
                  label: 'Date:',
                  value: _todayAbsenResponse!.data!.tanggal,
                ),
                DetailRow(
                  label: 'Check In:',
                  value: _todayAbsenResponse!.data!.jamMasuk ?? '-',
                ),
                DetailRow(
                  label: 'Check In Address:',
                  value: _todayAbsenResponse!.data!.alamatMasuk ?? '-',
                ),
                DetailRow(
                  label: 'Check Out:',
                  value: _todayAbsenResponse!.data!.jamKeluar ?? '-',
                ),
                DetailRow(
                  label: 'Check Out Address:',
                  value: _todayAbsenResponse!.data!.alamatKeluar ?? '-',
                ),
                DetailRow(
                  label: 'Status:',
                  value: _todayAbsenResponse!.data!.status ?? '-',
                ),
                DetailRow(
                  label: 'Permission Reason:',
                  value: _todayAbsenResponse!.data!.alasanIzin ?? '-',
                ),
                if (canCheckOut)
                  ValueListenableBuilder<bool>(
                    valueListenable: isDialogCheckingOut,
                    builder: (context, isLoading, _) {
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                isDialogCheckingOut.value = true;
                                try {
                                  final token = await Preferences.getToken();
                                  if (token == null || token.isEmpty)
                                    throw Exception(
                                      'Token tidak ditemukan, silakan login ulang.',
                                    );
                                  final lat = _distanceFromOffice ?? 0;
                                  final address = _currentAddress ?? '-';
                                  await AbsenServices.checkOut(
                                    token: token,
                                    lat: lat,
                                    lng:
                                        0, // Ganti dengan longitude user jika ingin
                                    address: address,
                                  );
                                  await _fetchTodayAttendanceData();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Check Out Berhasil'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Check Out Gagal: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  isDialogCheckingOut.value = false;
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: AppColor.text,
                          minimumSize: Size(120, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColor.text,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Check Out',
                                style: GoogleFonts.lexend(fontSize: 14),
                              ),
                      );
                    },
                  ),
              ] else ...[
                DetailRow(
                  label: 'Status:',
                  value: 'No attendance data for today',
                ),
                DetailRow(
                  label: 'Message:',
                  value: _todayAbsenResponse?.message ?? 'No response',
                ),
              ],
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
                  _distanceFromOffice != null
                      ? '${_distanceFromOffice!.toStringAsFixed(1)}m'
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
                final timeString =
                    '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                return Text(
                  timeString,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                );
              },
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
                  Expanded(
                    child: Text(
                      _currentAddress != null && _currentAddress!.isNotEmpty
                          ? _currentAddress!
                          : 'Your address will be appear here...',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: AppColor.text,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                          _todayCheckInTime ?? '00 : 00 : 00',
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
                          _todayCheckOutTime ?? '00 : 00 : 00',
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
    return FutureBuilder<List<HistoryAbsenData>>(
      future: _futureAbsenHistory,
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
              if (dt == null) return '-- : -- : --';
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
