import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/today_absen_model.dart';
import 'package:attendify/pages/izin_page.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/absen_services.dart';
import 'package:attendify/services/check_in_out_service.dart';
import 'package:attendify/services/maps_services.dart';
import 'package:attendify/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Position? _currentPosition;
  String? _currentAddress;
  GoogleMapController? _mapController;
  bool _loading = true;
  String? _errorMessage;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  bool _hasCheckedIn = false;
  TodayAbsenResponse? _todayAbsenResponse;
  bool _isSubmittingIzin = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkTodayCheckInStatus();
    _fetchTodayAttendanceData();
  }

  Future<void> _checkTodayCheckInStatus() async {
    try {
      final token = await Preferences.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _hasCheckedIn = false;
        });
        return;
      }
      final checkedIn = await CheckInService.hasCheckedInToday(token: token);
      setState(() {
        _hasCheckedIn = checkedIn;
      });
    } catch (e) {
      setState(() {
        _hasCheckedIn = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final position = await MapsServices.getCurrentLocation();
      if (position == null) {
        setState(() {
          _loading = false;
          _errorMessage =
              "Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin lokasi diberikan.";
        });
        return;
      }
      setState(() {
        _currentPosition = position;
      });
      await _getAddressFromLatLng(position);
    } catch (e) {
      String errorMsg = "Terjadi kesalahan saat mengambil lokasi: $e";
      if (e.toString().contains('MissingPluginException')) {
        errorMsg =
            "Aplikasi tidak dapat mengakses layanan lokasi. Pastikan aplikasi dijalankan di perangkat fisik atau emulator dengan plugin yang benar.";
      }
      setState(() {
        _loading = false;
        _errorMessage = errorMsg;
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      final address = await MapsServices.getAddressFromLatLng(position);
      setState(() {
        _currentAddress = address;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = null;
        _loading = false;
        _errorMessage = "Gagal mendapatkan alamat: $e";
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
          todayAbsenResponse.data!.checkIn.isNotEmpty) {
        setState(() {
          _hasCheckedIn = true;
        });
      }
    } catch (e) {
      setState(() {
        _todayAbsenResponse = null;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi belum tersedia. Coba refresh lokasi.')),
      );
      return;
    }

    if (_currentAddress == null || _currentAddress!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alamat belum tersedia. Coba refresh lokasi.')),
      );
      return;
    }

    if (_currentPosition!.latitude == 0.0 &&
        _currentPosition!.longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koordinat lokasi tidak valid. Coba refresh lokasi.'),
        ),
      );
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final token = await Preferences.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan, silakan login ulang.');
      }

      try {
        final response = await CheckInService.checkIn(
          token: token,
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          address: _currentAddress!,
          status: 'masuk',
          attendanceDate: DateTime.now(),
        );

        setState(() {
          _hasCheckedIn = true;
        });
        await _fetchTodayAttendanceData();

        setState(() {
          _hasCheckedIn = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check In Berhasil: ${response.message ?? 'Success'}',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } on Exception catch (e) {
        final msg = e.toString();
        if (msg.contains('409')) {
          setState(() {
            _hasCheckedIn = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda sudah melakukan absen hari ini'),
              backgroundColor: Colors.yellow[800],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check In Gagal: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  Future<void> _handleCheckOut() async {
    if (_currentPosition == null || _currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_off, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lokasi belum tersedia. Coba refresh lokasi.',
                  style: GoogleFonts.lexend(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
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
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        address: _currentAddress!,
      );

      setState(() {
        _hasCheckedIn = false;
      });
      await _fetchTodayAttendanceData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check Out Gagal: ${e.toString()}',
                  style: GoogleFonts.lexend(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }

  Future<void> _handleIzin() async {
    Navigator.pop(context);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const IzinPage()),
    );

    if (result == true && mounted) {
      await _fetchTodayAttendanceData();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCheckedIn = _hasCheckedIn;
    bool isIzin = false;
    if (_todayAbsenResponse != null && _todayAbsenResponse!.data != null) {
      final data = _todayAbsenResponse!.data!;
      if (data.status != null && data.status!.toLowerCase() == 'izin') {
        isIzin = true;
        isCheckedIn = false;
      } else if (data.checkIn.isNotEmpty) {
        isCheckedIn = true;
      }
    }

    return Scaffold(
      backgroundColor: AppColor.text,
      appBar: AppBar(
        backgroundColor: AppColor.text,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.primary, size: 20),
          onPressed: () => Navigator.pop(context, false),
        ),
        centerTitle: true,
        title: Text(
          'Kehadiran',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColor.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      _loading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColor.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage == null
                                        ? "Mengambil lokasi..."
                                        : _errorMessage!,
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor.primary,
                                          foregroundColor: AppColor.text,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: _getCurrentLocation,
                                        icon: Icon(Icons.refresh),
                                        label: Text("Coba Lagi"),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : (_currentPosition == null)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Lokasi tidak tersedia",
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primary,
                                      foregroundColor: AppColor.text,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _getCurrentLocation,
                                    icon: Icon(Icons.refresh),
                                    label: Text("Refresh Lokasi"),
                                  ),
                                ],
                              ),
                            )
                          : GoogleMap(
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 15.0,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('current_location'),
                                  position: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: 'Lokasi Anda',
                                    snippet:
                                        _currentAddress ??
                                        'Alamat tidak tersedia',
                                  ),
                                ),
                              },
                            ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: FloatingActionButton.small(
                          onPressed: _getCurrentLocation,
                          backgroundColor: AppColor.primary,
                          foregroundColor: AppColor.text,
                          child: Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          isIzin
                              ? 'Izin'
                              : (isCheckedIn
                                    ? 'Sudah Check In'
                                    : 'Belum Check In'),
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isIzin
                                ? Colors.orange
                                : (isCheckedIn ? Colors.green : Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alamat: ',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _currentAddress ?? '-',
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Kehadiran',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final days = [
                            'Sunday',
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                          ];
                          String dayName = days[now.weekday % 7];
                          String monthName = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ][now.month - 1];
                          String dateStr =
                              "${now.day.toString().padLeft(2, '0')}-${monthName}-${now.year}";

                          String checkInTime = '-';
                          String checkOutTime = '-';

                          final todayData =
                              (_todayAbsenResponse != null &&
                                  _todayAbsenResponse!.data != null)
                              ? _todayAbsenResponse!.data
                              : null;

                          if (todayData != null) {
                            if (todayData.status != null &&
                                todayData.status!.toLowerCase() == 'izin') {
                              checkInTime = 'Izin';
                              checkOutTime = '-';
                            } else {
                              if (todayData.checkIn.isNotEmpty) {
                                try {
                                  final dt = DateTime.parse(todayData.checkIn);
                                  checkInTime =
                                      "${dt.hour.toString().padLeft(2, '0')} : ${dt.minute.toString().padLeft(2, '0')} : ${dt.second.toString().padLeft(2, '0')}";
                                } catch (_) {
                                  checkInTime = todayData.checkIn;
                                }
                              }
                              if (todayData.checkOut != null &&
                                  todayData.checkOut!.isNotEmpty) {
                                try {
                                  final dt = DateTime.parse(
                                    todayData.checkOut!,
                                  );
                                  checkOutTime =
                                      "${dt.hour.toString().padLeft(2, '0')} : ${dt.minute.toString().padLeft(2, '0')} : ${dt.second.toString().padLeft(2, '0')}";
                                } catch (_) {
                                  checkOutTime = todayData.checkOut!;
                                }
                              }
                            }
                          }

                          return Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dayName,
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      dateStr,
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check In',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      checkInTime,
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: checkInTime == 'Izin'
                                            ? Colors.orange
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check Out',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      checkOutTime,
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: _isCheckingIn || _isCheckingOut || isIzin
                            ? null
                            : (isCheckedIn ? _handleCheckOut : _handleCheckIn),
                        text: _isCheckingIn
                            ? ''
                            : (_isCheckingOut
                                  ? ''
                                  : (isCheckedIn ? 'Check Out' : 'Check In')),
                        minWidth: double.infinity,
                        height: 45,
                        backgroundColor: AppColor.primary,
                        foregroundColor: AppColor.text,
                        borderRadius: BorderRadius.circular(10),
                        icon: _isCheckingIn || _isCheckingOut
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColor.text,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        onPressed: isIzin ? null : _handleIzin,
                        text: isIzin ? 'Sudah Izin' : 'Ajukan Izin',
                        minWidth: double.infinity,
                        height: 45,
                        backgroundColor: isIzin ? Colors.grey : Colors.orange,
                        foregroundColor: AppColor.text,
                        borderRadius: BorderRadius.circular(10),
                        icon: isIzin
                            ? Icon(Icons.check_circle, size: 20)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
