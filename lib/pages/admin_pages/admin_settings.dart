import 'package:attendance_system/pages/admin_pages/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:attendance_system/api_services/app_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  bool notificationsEnabled = true;
  bool darkModeEnabled = true;
  String adminName = 'Admin User';
  String adminEmail = 'admin@attendance.com';
  bool _isExporting = false;

  // ✅ NEW: Check-in Time Settings
  String workStartTime = '09:00'; // Default 9:00 AM
  int lateThresholdMinutes = 15; // Default 15 minutes grace period

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    _loadCheckInSettings(); // Load saved settings
  }

  Future<void> _loadAdminInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        adminName = prefs.getString('admin_name') ?? 'Admin User';
        adminEmail = prefs.getString('admin_email') ?? 'admin@attendance.com';
      });
    } catch (e) {
      debugPrint('Error loading admin info: $e');
    }
  }

  // ✅ NEW: Load Check-in Settings
  Future<void> _loadCheckInSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        workStartTime = prefs.getString('work_start_time') ?? '09:00';
        lateThresholdMinutes = prefs.getInt('late_threshold_minutes') ?? 15;
      });
    } catch (e) {
      debugPrint('Error loading check-in settings: $e');
    }
  }

  // ✅ NEW: Save Check-in Settings
  Future<void> _saveCheckInSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('work_start_time', workStartTime);
      await prefs.setInt('late_threshold_minutes', lateThresholdMinutes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Check-in settings saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving check-in settings: $e');
    }
  }

  Future<void> _exportAttendanceData() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export cancelled'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isExporting = false);
        return;
      }

      final history = await AppService.getUserAttendanceHistory();
      final meetings = await AppService.getMeetings();
      final DateTime now = DateTime.now();
      final String timestamp = DateFormat('yyyy_MM_dd_HH_mm_ss').format(now);
      final String fileName = 'attendance_export_$timestamp.csv';
      final String filePath = '$selectedDirectory/$fileName';

      StringBuffer csvContent = StringBuffer();
      csvContent.writeln('ATTENDANCE EXPORT');
      csvContent.writeln('Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
      csvContent.writeln('Admin: $adminName');
      csvContent.writeln('Work Start Time: $workStartTime');
      csvContent.writeln('Late Threshold: $lateThresholdMinutes minutes');
      csvContent.writeln('');
      csvContent.writeln('=== ATTENDANCE RECORDS ===');
      csvContent.writeln('Date,User Name,Check In,Check Out,Status,Location');

      for (var record in history) {
        final date = record['date'] ?? 'N/A';
        final userName = record['user_name'] ?? 'Unknown';
        final checkIn = record['check_in_time'] ?? '--:--';
        final checkOut = record['check_out_time'] ?? '--:--';
        final status = record['status'] ?? 'Unknown';
        final latitude = record['latitude'] ?? 'N/A';
        final longitude = record['longitude'] ?? 'N/A';
        csvContent.writeln('$date,$userName,$checkIn,$checkOut,$status,"$latitude, $longitude"');
      }

      csvContent.writeln('');
      csvContent.writeln('=== MEETINGS ===');
      csvContent.writeln('Title,Date Time,Location,Status');

      for (var meeting in meetings) {
        final title = meeting['title'] ?? 'N/A';
        final dateTime = meeting['date_time'] ?? 'N/A';
        final location = meeting['location'] ?? 'N/A';
        final status = meeting['status'] ?? 'N/A';
        csvContent.writeln('$title,$dateTime,$location,$status');
      }

      File(filePath).writeAsStringSync(csvContent.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Exported to:\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isExporting = false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminLoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text("Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Profile Card
            Container(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentBlue.withOpacity(0.3), width: 1.5),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Icon(Icons.admin_panel_settings, color: accentBlue, size: 40),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(adminName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(adminEmail, style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Administrator Account', style: TextStyle(color: accentBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ✅ NEW: CHECK-IN TIME SETTINGS
            Text("Attendance Settings", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Work Start Time
            Container(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentBlue.withOpacity(0.1), width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Work Start Time", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: int.parse(workStartTime.split(':')[0]),
                                minute: int.parse(workStartTime.split(':')[1]),
                              ),
                            );
                            if (time != null) {
                              setState(() {
                                workStartTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: darkBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              workStartTime,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, color: accentBlue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Late Threshold
            Container(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentBlue.withOpacity(0.1), width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Late Threshold (Minutes)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: lateThresholdMinutes.toDouble(),
                          min: 0,
                          max: 60,
                          divisions: 12,
                          activeColor: accentBlue,
                          onChanged: (value) {
                            setState(() {
                              lateThresholdMinutes = value.toInt();
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$lateThresholdMinutes min',
                          style: const TextStyle(color: Color(0xFF7B82FF), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Save Settings Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 20),
                label: const Text("Save Settings", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                onPressed: _saveCheckInSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Export Data
            Text("Data Management", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.download,
              title: "Export Data",
              subtitle: "Download attendance records",
              isLoading: _isExporting,
              onTap: _exportAttendanceData,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),

            // Logout
            Text("Account", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 22),
                label: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentBlue.withOpacity(0.1), width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 2,
                ),
              )
                  : Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}
