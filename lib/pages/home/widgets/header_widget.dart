import 'package:attendify/const/app_color.dart';
import 'package:attendify/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class HeaderWidget extends StatefulWidget {
  final Future<dynamic> futureProfile;
  final bool hasAttendedToday;
  final VoidCallback showDialogDetailsAttended;

  const HeaderWidget({
    Key? key,
    required this.futureProfile,
    required this.hasAttendedToday,
    required this.showDialogDetailsAttended,
  }) : super(key: key);

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  Widget greetingWithIcon() {
    final hour = DateTime.now().hour;
    String greetingText;
    String assetPath;

    if (hour >= 5 && hour < 12) {
      greetingText = 'Good morning';
      assetPath = 'assets/icons/morning.png';
    } else if (hour >= 12 && hour < 17) {
      greetingText = 'Good afternoon';
      assetPath = 'assets/icons/afternoon.png';
    } else if (hour >= 17 && hour < 21) {
      greetingText = 'Good evening';
      assetPath = 'assets/icons/evening.png';
    } else {
      greetingText = 'Good night';
      assetPath = 'assets/icons/night.png';
    }

    return Row(
      children: [
        Text(
          greetingText,
          style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        SizedBox(width: 4),
        Image.asset(assetPath, width: 24, height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder(
          future: widget.futureProfile,
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
          future: widget.futureProfile,
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
                  onTap: widget.showDialogDetailsAttended,
                  child: Row(
                    children: [
                      Text(
                        widget.hasAttendedToday ? 'Attended' : 'Not Attended',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: widget.hasAttendedToday
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: widget.hasAttendedToday
                            ? Colors.green
                            : Colors.red,
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
        SizedBox(width: 4),
      ],
    );
  }
}
