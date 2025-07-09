import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/today_absen_model.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/absen_services.dart'; // Tambahkan import absen_services.dart
import 'package:attendify/services/check_in_service.dart';
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkTodayCheckInStatus();
    _fetchTodayAttendanceData();
  }

  // Mengecek status check-in hari ini dari backend
  Future<void> _checkTodayCheckInStatus() async {
    try {
      final token = await Preferences.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _hasCheckedIn = false;
        });
        return;
      }
      // Asumsikan CheckInService.hasCheckedInToday mengembalikan bool
      final checkedIn = await CheckInService.hasCheckedInToday(token: token);
      setState(() {
        _hasCheckedIn = checkedIn;
      });
    } catch (e) {
      // Jika error, anggap belum check in (atau bisa tampilkan error)
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
      // Tangani MissingPluginException secara khusus
      if (e.toString().contains('MissingPluginException')) {
        errorMsg =
            "Aplikasi tidak dapat mengakses layanan lokasi. Pastikan aplikasi dijalankan di perangkat fisik atau emulator dengan plugin yang benar, dan sudah melakukan 'flutter clean' serta restart aplikasi. (MissingPluginException)";
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
    } catch (e) {
      setState(() {
        _todayAbsenResponse = null;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (_currentPosition == null || _currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi belum tersedia. Coba refresh lokasi.')),
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
      final response = await CheckInService.checkIn(
        token: token,
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        address: _currentAddress!,
        status: 'masuk',
      );
      setState(() {
        _hasCheckedIn = true;
      });
      await _fetchTodayAttendanceData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check In Berhasil: ${response.message}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check In Gagal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  // Tambahkan _handleCheckOut dari home_page.dart dan gunakan API dari absen_services.dart
  Future<void> _handleCheckOut() async {
    if (_currentPosition == null || _currentAddress == null) {
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
      // Gunakan AbsenServices.checkOut sesuai instruksi
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
      appBar: AppBar(
        backgroundColor: AppColor.text,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.primary, size: 20),
          onPressed: () => Navigator.pop(context),
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
                // Map Section
                Container(
                  height: 400, // Tinggikan maps agar lebih memanjang ke bawah
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _loading
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
                                        borderRadius: BorderRadius.circular(8),
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
                                _errorMessage ?? 'Lokasi tidak tersedia',
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                                label: Text("Coba Lagi"),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GoogleMap(
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  zoom: 16,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId('currentLocation'),
                                    position: LatLng(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                    ),
                                    infoWindow: InfoWindow(
                                      title: 'Lokasi Anda',
                                    ),
                                  ),
                                },
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 35,
                              child: FloatingActionButton(
                                backgroundColor: Colors.blueAccent,
                                onPressed: _getCurrentLocation,
                                child: Icon(
                                  Icons.my_location,
                                  color: AppColor.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 18),
                // Status & Address
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
                          _hasCheckedIn ? 'Sudah Check In' : 'Belum Check In',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _hasCheckedIn ? Colors.green : Colors.red,
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
                // Attendance Time Card
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
                          // Ambil data hari ini dari backend jika sudah check in
                          // Perbaikan: gunakan data check in/out dari backend jika tersedia
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

                          // Ambil data check in/out dari backend jika ada
                          String checkInTime = '-';
                          String checkOutTime = '-';

                          // Cek apakah ada response absen hari ini
                          // Pastikan _todayAbsenResponse dan _todayAbsenResponse.data sudah diambil dari backend
                          // dan diupdate setiap kali check in/out berhasil
                          final todayData =
                              (_todayAbsenResponse != null &&
                                  _todayAbsenResponse!.data != null)
                              ? _todayAbsenResponse!.data
                              : null;

                          if (todayData != null) {
                            // Format waktu check in
                            if (todayData.checkIn.isNotEmpty) {
                              try {
                                final dt = DateTime.parse(todayData.checkIn);
                                checkInTime =
                                    "${dt.hour.toString().padLeft(2, '0')} : ${dt.minute.toString().padLeft(2, '0')} : ${dt.second.toString().padLeft(2, '0')}";
                              } catch (_) {
                                checkInTime = todayData.checkIn;
                              }
                            }
                            // Format waktu check out jika sudah ada
                            if (todayData.checkOut != null &&
                                todayData.checkOut!.isNotEmpty) {
                              try {
                                final dt = DateTime.parse(todayData.checkOut!);
                                checkOutTime =
                                    "${dt.hour.toString().padLeft(2, '0')} : ${dt.minute.toString().padLeft(2, '0')} : ${dt.second.toString().padLeft(2, '0')}";
                              } catch (_) {
                                checkOutTime = todayData.checkOut!;
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
                                        color: Colors.black,
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
                // Tempat untuk foto (placeholder)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    //onTap:
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: Colors.grey[500],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap for insert image',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // CustomButton(
                //   onPressed: () {},
                //   text: 'Take Photo',
                //   minWidth: double.infinity,
                //   height: 45,
                //   backgroundColor: AppColor.secondary,
                //   foregroundColor: AppColor.text,
                //   borderRadius: BorderRadius.circular(10),
                // ),
                SizedBox(height: 12),
                CustomButton(
                  onPressed: _isCheckingIn || _isCheckingOut
                      ? null
                      : (_hasCheckedIn ? _handleCheckOut : _handleCheckIn),
                  text: _isCheckingIn
                      ? ''
                      : (_isCheckingOut
                            ? ''
                            : (_hasCheckedIn ? 'Check Out' : 'Check In')),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
