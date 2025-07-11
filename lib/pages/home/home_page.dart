import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/absen_history_model.dart';
import 'package:attendify/models/profile_model.dart';
import 'package:attendify/models/today_absen_model.dart';
import 'package:attendify/pages/detail_absen_page.dart';
import 'package:attendify/pages/home/widgets/container_check_in_out_widget.dart';
import 'package:attendify/pages/home/widgets/container_distance.dart';
import 'package:attendify/pages/home/widgets/header_widget.dart';
import 'package:attendify/pages/home/widgets/list_data_widget.dart';
import 'package:attendify/pages/home/widgets/section_riwayat_details_widget.dart';
import 'package:attendify/pages/maps_page.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/absen_services.dart';
import 'package:attendify/services/maps_services.dart';
import 'package:attendify/services/profile_services.dart';
import 'package:attendify/widgets/button.dart';
import 'package:attendify/widgets/detail_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  Future<List<HistoryAbsenData>>? _futureAbsenHistory;
  String? token;
  bool _isFirstLoad = true;
  Future<ProfileData>? _futureProfile;

  @override
  bool get wantKeepAlive => true;

  double? _distanceFromOffice;
  String? _currentAddress;
  String? _todayCheckInTime;
  String? _todayCheckOutTime;
  bool _hasAttendedToday = false;
  TodayAbsenResponse? _todayAbsenResponse;
  bool _isCheckingOut = false;

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
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isFirstLoad) {
      _refreshEssentialData();
    } else {
      _isFirstLoad = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshAfterAttendance();
    }
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
    try {
      if (token == null) {
        await _initTokenAndFetchHistory();
      }
      setState(() {
        _futureAbsenHistory = AbsenServices.fetchAbsenHistory(token!);
        _futureProfile = _loadProfile();
      });
      await Future.wait([_fetchLocationData(), _fetchTodayAttendanceData()]);
    } catch (_) {}
  }

  Future<void> _refreshAfterAttendance() async {
    try {
      await _fetchTodayAttendanceData();
      if (token != null) {
        setState(() {
          _futureAbsenHistory = AbsenServices.fetchAbsenHistory(token!);
        });
      }
      await _fetchLocationData();
    } catch (_) {}
  }

  Future<void> _refreshFromMapsPage() async {
    try {
      await Future.wait([_fetchTodayAttendanceData(), _fetchLocationData()]);
      if (token != null) {
        setState(() {
          _futureAbsenHistory = AbsenServices.fetchAbsenHistory(token!);
        });
      }
    } catch (_) {}
  }

  Future<void> _refreshEssentialData() async {
    try {
      await Future.wait([_fetchTodayAttendanceData(), _fetchLocationData()]);
      if (token != null) {
        setState(() {
          _futureAbsenHistory = AbsenServices.fetchAbsenHistory(token!);
        });
      }
    } catch (_) {}
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
                onRefreshData: () async {
                  if (mounted) {
                    await _refreshEssentialData();
                  }
                },
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
                onDetailsPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailAbsenPage(),
                    ),
                  );
                  if (mounted) {
                    await _refreshEssentialData();
                  }
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
        tooltip: 'Absen & Izin',
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
              'Attendance',
              style: GoogleFonts.lexend(
                fontSize: 26,
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Seamlessly check in or out for your attendance. Your presence, your way.',
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: AppColor.primary.withOpacity(0.85),
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapsPage(),
                          fullscreenDialog: false,
                        ),
                      ).then((_) async {
                        await _refreshFromMapsPage();
                      });
                    },
                    text: 'Check In / Out',
                    height: 48,
                    backgroundColor: AppColor.primary,
                    borderRadius: BorderRadius.circular(12),
                    textStyle: GoogleFonts.lexend(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                    icon: Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    // Dialog check out dihapus, hanya tampilkan data attendance hari ini
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
                // Permission Reason removed
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
