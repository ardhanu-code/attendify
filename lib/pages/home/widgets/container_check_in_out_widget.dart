import 'package:attendify/const/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContainerCheckInOutWidget extends StatefulWidget {
  final String? currentAddress;
  final bool hasAttendedToday;
  final String? checkInTime;
  final String? checkOutTime;

  const ContainerCheckInOutWidget({
    Key? key,
    required this.currentAddress,
    required this.hasAttendedToday,
    required this.checkInTime,
    required this.checkOutTime,
  }) : super(key: key);

  @override
  State<ContainerCheckInOutWidget> createState() =>
      _ContainerCheckInOutWidgetState();
}

class _ContainerCheckInOutWidgetState extends State<ContainerCheckInOutWidget> {
  String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '00:00:00';
    // Format: "2024-06-07 08:00:00" or "08:00:00"
    // Use only HH:mm:ss
    if (timeStr.length >= 8 && timeStr.contains(':')) {
      // If contains space, take after space
      if (timeStr.contains(' ')) {
        final parts = timeStr.split(' ');
        if (parts.length > 1) {
          return parts[1];
        }
      }
      // If only time
      return timeStr;
    }
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.currentAddress != null &&
                              widget.currentAddress!.isNotEmpty
                          ? widget.currentAddress!
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
            SizedBox(height: 8),
            if (widget.hasAttendedToday) SizedBox(height: 8),
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
                          widget.hasAttendedToday
                              ? formatTime(widget.checkInTime)
                              : '00 : 00 : 00',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color: widget.hasAttendedToday
                                ? AppColor.text
                                : Colors.white60,
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
                          widget.checkOutTime != null &&
                                  widget.checkOutTime!.isNotEmpty
                              ? formatTime(widget.checkOutTime)
                              : (widget.hasAttendedToday
                                    ? '-- : -- : --'
                                    : '00 : 00 : 00'),
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            color:
                                widget.checkOutTime != null &&
                                    widget.checkOutTime!.isNotEmpty
                                ? AppColor.text
                                : (widget.hasAttendedToday
                                      ? Colors.orange
                                      : Colors.white60),
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
