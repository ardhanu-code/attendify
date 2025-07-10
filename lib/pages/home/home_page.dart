import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/absen_history_model.dart';
import 'package:attendify/models/profile_model.dart';
import 'package:attendify/models/today_absen_model.dart';
import 'package:attendify/pages/detail_absen_page.dart';
import 'package:attendify/pages/maps_page.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/absen_services.dart';
import 'package:attendify/services/maps_services.dart';
import 'package:attendify/services/profile_services.dart';
import 'package:attendify/widgets/button.dart';
import 'package:attendify/widgets/detail_row.dart';
import 'package:attendify/pages/home/widgets/container_check_in_out_widget.dart';
import 'package:attendify/pages/home/widgets/container_distance.dart';
import 'package:attendify/pages/home/widgets/header_widget.dart';
import 'package:attendify/pages/home/widgets/list_data_widget.dart';
import 'package:attendify/pages/home/widgets/section_riwayat_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<HistoryAbsenData>>? _futureAbsenHistory;
  String? token;

  Future<ProfileData>? _futureProfile;

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
    _fetchLocationData();
    _fetchTodayAttendanceData();
  }

  Future<void> _fetchTodayAttendanceData() async {
    try {
      final token = await Preferences.getToken();
      if (token == null || token.isEmpty) return;

      final todayAbsenResponse = await AbsenServices.fetchTodayAbsen(token);

      setState(() {
        _todayAbsenResponse = todayAbsenResponse;
      });

      if (todayAbsenResponse.data != null &&
          todayAbsenResponse.data!.checkInTime != null) {
        try {
          String? checkInTime = _parseTimeString(
            todayAbsenResponse.data!.checkInTime!,
          );

          setState(() {
            _todayCheckInTime = checkInTime;
            _hasAttendedToday = true;
          });

          if (todayAbsenResponse.data!.checkOutTime != null) {
            String? checkOutTime = _parseTimeString(
              todayAbsenResponse.data!.checkOutTime!,
            );
            setState(() {
              _todayCheckOutTime = checkOutTime;
            });
          }
        } catch (e) {
          setState(() {
            _hasAttendedToday = false;
            _todayCheckInTime = null;
            _todayCheckOutTime = null;
          });
        }
      } else {
        setState(() {
          _hasAttendedToday = false;
          _todayCheckInTime = null;
          _todayCheckOutTime = null;
        });
      }
    } catch (e) {
      setState(() {
        _hasAttendedToday = false;
        _todayCheckInTime = null;
        _todayCheckOutTime = null;
      });
    }
  }

  Future<void> _fetchLocationData() async {
    try {
      final distance = await MapsServices.getDistanceFromOffice();
      final address = await MapsServices.getCurrentAddress();
      setState(() {
        _distanceFromOffice = distance;
        _currentAddress = address;
      });
    } catch (e) {
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
        _futureProfile = _loadProfile();
      });
      await _futureAbsenHistory;
      await _fetchLocationData();
      await _fetchTodayAttendanceData();
    } else {
      await _initTokenAndFetchHistory();
      await _fetchLocationData();
      await _fetchTodayAttendanceData();
    }
  }

  Future<void> _refreshTodayAttendance() async {
    await _fetchTodayAttendanceData();
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
              HeaderWidget(
                futureProfile: _futureProfile!,
                hasAttendedToday: _hasAttendedToday,
                showDialogDetailsAttended: _showDialogDetailsAttended,
              ),
              const SizedBox(height: 16),
              ContainerDistanceAndOpenMapWidget(
                distanceFromOffice: _distanceFromOffice,
              ),
              const SizedBox(height: 16),
              ContainerCheckInOutWidget(
                currentAddress: _currentAddress,
                hasAttendedToday: _hasAttendedToday,
                checkInTime: _todayAbsenResponse?.data?.checkInTime,
                checkOutTime: _todayAbsenResponse?.data?.checkOutTime,
              ),
              const SizedBox(height: 4),
              SectionRiwayatDetailsWidget(
                onDetailsPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailAbsenPage(),
                    ),
                  );
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppColor.primary,
                  child: ListDataWidget(
                    futureAbsenHistory: _futureAbsenHistory!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialogCheckInAndOut(context);
        },
        tooltip: 'Absen',
        backgroundColor: AppColor.primary,
        child: Icon(Icons.fingerprint, color: AppColor.text, size: 28),
      ),
    );
  }

  Future<dynamic> _showDialogCheckInAndOut(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.text,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset('assets/icons/attend.png', width: 80, height: 80),
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
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapsPage()),
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
                    onPressed: _isCheckingOut
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _showDialogCheckOut(context);
                          },
                    text: _isCheckingOut ? 'Checking out...' : 'Check out',
                    height: 45,
                    backgroundColor: AppColor.primary,
                    borderRadius: BorderRadius.circular(10),
                    textStyle: GoogleFonts.lexend(color: Colors.redAccent),
                    icon: _isCheckingOut
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.redAccent,
                              strokeWidth: 2.5,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to check out?',
                style: GoogleFonts.lexend(),
              ),
              if (_isCheckingOut) ...[
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColor.primary,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processing checkout...',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isCheckingOut
                  ? null
                  : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.lexend(
                  color: _isCheckingOut ? Colors.grey.shade400 : Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: _isCheckingOut
                  ? null
                  : () async {
                      Navigator.of(context).pop();

                      setState(() {
                        _isCheckingOut = true;
                      });

                      try {
                        final token = await Preferences.getToken();

                        if (token == null || token.isEmpty) {
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

                        final position =
                            await MapsServices.getCurrentLocation();

                        if (position == null) {
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

                        final response = await AbsenServices.checkOut(
                          token: token,
                          lat: position.latitude,
                          lng: position.longitude,
                          address: address ?? '',
                        );

                        if (response.data.checkOutTime.isNotEmpty) {
                          final checkOutTime = _parseTimeString(
                            response.data.checkOutTime,
                          );
                          setState(() {
                            _todayCheckOutTime = checkOutTime;
                            _hasAttendedToday = true;
                          });
                        }

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Check Out Berhasil! Waktu: ${response.data.checkOutTime}',
                                      style: GoogleFonts.lexend(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }

                        await _fetchTodayAttendanceData();

                        setState(() {});
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.error,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Check Out Gagal: $e',
                                      style: GoogleFonts.lexend(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isCheckingOut = false;
                          });
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

  String? _parseTimeString(String timeStr) {
    if (timeStr.isEmpty) return null;

    try {
      final dateTime = DateTime.tryParse(timeStr);
      if (dateTime != null) {
        return '${dateTime.hour.toString().padLeft(2, '0')} : ${dateTime.minute.toString().padLeft(2, '0')} : ${dateTime.second.toString().padLeft(2, '0')}';
      }

      final timeParts = timeStr.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        final second = timeParts.length > 2
            ? (int.tryParse(timeParts[2]) ?? 0)
            : 0;

        return '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')} : ${second.toString().padLeft(2, '0')}';
      }

      if (timeStr.contains(' : ')) {
        return timeStr;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> _showDialogDetailsAttended() {
    bool canCheckOut = false;
    if (_todayAbsenResponse?.data != null) {
      final data = _todayAbsenResponse!.data!;
      canCheckOut =
          data.checkInTime != null &&
          (data.checkOutTime == null || data.checkOutTime!.isEmpty);
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
                  value:
                      _todayAbsenResponse!.data!.attendanceDate ??
                      'Not available',
                ),
                DetailRow(
                  label: 'Check In:',
                  value: _todayAbsenResponse!.data!.checkInTime ?? '-',
                ),
                DetailRow(
                  label: 'Check In Address:',
                  value: _todayAbsenResponse!.data!.checkInAddress ?? '-',
                ),
                DetailRow(
                  label: 'Check Out:',
                  value: _todayAbsenResponse!.data!.checkOutTime ?? '-',
                ),
                DetailRow(
                  label: 'Check Out Address:',
                  value: _todayAbsenResponse!.data!.checkOutAddress ?? '-',
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
                                  final response = await AbsenServices.checkOut(
                                    token: token,
                                    lat: lat,
                                    lng: 0,
                                    address: address,
                                  );

                                  if (response.data.checkOutTime.isNotEmpty) {
                                    final checkOutTime = _parseTimeString(
                                      response.data.checkOutTime,
                                    );
                                    setState(() {
                                      _todayCheckOutTime = checkOutTime;
                                      _hasAttendedToday = true;
                                    });
                                  }

                                  await _fetchTodayAttendanceData();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Check Out Berhasil! Waktu: ${response.data.checkOutTime}',
                                              style: GoogleFonts.lexend(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            Icons.error,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Check Out Gagal: $e',
                                              style: GoogleFonts.lexend(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 4),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
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
                  value: _todayAbsenResponse?.message ?? 'No response message',
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
}
