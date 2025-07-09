import 'package:attendify/const/app_color.dart';
import 'package:attendify/models/profile_model.dart';
import 'package:attendify/pages/splash_screen.dart';
import 'package:attendify/preferences/preferences.dart';
import 'package:attendify/services/profile_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<ProfileData>? _futureProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await Preferences.getToken();
    setState(() {
      _futureProfile = ProfileServices.fetchProfile(token ?? '');
    });
  }

  Future<void> _logout(BuildContext context) async {
    await Preferences.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColor.text,
        foregroundColor: AppColor.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 16),
        ),
      ),
      backgroundColor: AppColor.text,
      body: _futureProfile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColor.primary),
            )
          : FutureBuilder<ProfileData>(
              future: _futureProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColor.primary),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load profile'));
                }

                final profile = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColor.secondary,
                            backgroundImage: profile.profilePhoto != null
                                ? NetworkImage(
                                    'https://your-api-url.com/storage/${profile.profilePhoto}',
                                  )
                                : null,
                            child: profile.profilePhoto == null
                                ? Icon(
                                    Icons.person,
                                    size: 48,
                                    color: AppColor.text,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Implement upload photo functionality
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.badge, color: AppColor.primary),
                        title: Text('Batch', style: GoogleFonts.lexend()),
                        subtitle: Text('Batch ${profile.batchKe}'),
                      ),
                      ListTile(
                        leading: Icon(Icons.school, color: AppColor.primary),
                        title: Text('Training', style: GoogleFonts.lexend()),
                        subtitle: Text(profile.trainingTitle),
                      ),
                      ListTile(
                        leading: Icon(Icons.wc, color: AppColor.primary),
                        title: Text('Gender', style: GoogleFonts.lexend()),
                        subtitle: Text(
                          profile.jenisKelamin == 'L' ? 'Male' : 'Female',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.redAccent),
                        title: Text(
                          'Logout',
                          style: GoogleFonts.lexend(color: Colors.redAccent),
                        ),
                        onTap: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Logout',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to logout?',
                                style: GoogleFonts.lexend(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.lexend(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'Logout',
                                    style: GoogleFonts.lexend(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (shouldLogout == true) {
                            await _logout(context);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: Colors.red.withOpacity(0.05),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
