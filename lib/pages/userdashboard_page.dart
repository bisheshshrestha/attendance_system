import 'package:attendance_system/api_services/app_service.dart';
import 'package:attendance_system/models/person.dart';
import 'package:attendance_system/api_services/person_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  Person? user;
  bool _isCheckingIn = false;
  String? _todayCheckIn;
  String? _todayCheckOut;
  double _attendancePercentage = 0.0;
  List<Map<String, dynamic>> _todayMeetings = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final person = await PersonService().getPerson();

      if (mounted) {
        setState(() {
          user = person;
        });
      }

      await _loadTodayAttendance();
      await _loadTodayMeetings();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  /// Load today's attendance data
  Future<void> _loadTodayAttendance() async {
    try {
      final history = await AppService.getUserAttendanceHistory();
      final today = DateTime.now().toString().split(' ')[0];

      if (history.isNotEmpty) {
        final todayRecords = history.where((r) {
          final dateStr = r['date']?.toString() ?? '';
          return dateStr.contains(today);
        }).toList();

        if (todayRecords.isNotEmpty) {
          final latestRecord = todayRecords.last;
          final stats = await AppService.getAttendanceStats();

          if (mounted) {
            setState(() {
              _todayCheckIn = latestRecord['check_in_time']?.toString() ?? '--:--';
              _todayCheckOut = latestRecord['check_out_time']?.toString() ?? '--:--';
              _attendancePercentage = (stats['present_percentage'] ?? 0) / 100.0;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading today attendance: $e');
    }
  }

  /// Load today's meetings
  Future<void> _loadTodayMeetings() async {
    try {
      await AppService.initializeMeetings();
      final meetings = await AppService.getMeetings();
      final today = DateTime.now().toString().split(' ')[0];

      if (meetings.isNotEmpty) {
        final todayMeetings = meetings.where((m) {
          final dateTimeStr = (m['date_time'] ?? m['datetime'])?.toString() ?? '';
          return dateTimeStr.contains(today);
        }).take(3).toList(); // Show max 3 meetings

        if (mounted) {
          setState(() {
            _todayMeetings = todayMeetings;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading today meetings: $e');
    }
  }

  /// Quick check-in
  Future<void> _quickCheckIn() async {
    if (_isCheckingIn) return;

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final person = await PersonService().getPerson();

      final result = await AppService.markAttendance(
        userName: person.name,
        latitude: '27.7172',
        longitude: '85.3240',
      );

      if (mounted) {
        await _loadTodayAttendance();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']?.toString() ?? 'Check-in successful'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        setState(() {
          _isCheckingIn = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _convertTo12HourFormat(String time) {
    try {
      if (time == '--:--' || time.isEmpty) return '--:--';

      final parts = time.split(':');
      if (parts.length < 2) return time;

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour;

      if (displayHour > 12) {
        displayHour -= 12;
      } else if (displayHour == 0) {
        displayHour = 12;
      }

      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time;
    }
  }

  String _extractTime(Map<String, dynamic> meeting) {
    final dateTimeStr = (meeting['date_time'] ?? meeting['datetime'])?.toString() ?? '';
    if (dateTimeStr.isEmpty) return 'N/A';

    try {
      final parts = dateTimeStr.split(' ');
      if (parts.length >= 2) {
        return '${parts[1]} ${parts[2]}';
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              user == null
                  ? const CircularProgressIndicator()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome! ${user!.name}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attendance Status Card
              _buildAttendanceCard(),
              const SizedBox(height: 20),

              // Quick Actions
              Text(
                "Quick Actions",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(icon: Icons.login, label: "Check In", onTap: _quickCheckIn),
                  _actionButton(icon: Icons.calendar_month, label: "Leave"),
                  _actionButton(icon: Icons.article, label: "News"),
                  _actionButton(icon: Icons.group, label: "Team"),
                ],
              ),
              const SizedBox(height: 24),

              // Today's Meetings Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Meetings",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await _loadTodayMeetings();
                    },
                    child: Text("Refresh", style: TextStyle(color: accentBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Meetings List
              if (_todayMeetings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentBlue.withOpacity(0.2), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "No meetings today",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                )
              else
                Column(
                  children: _todayMeetings.map((meeting) => _meetingCard(meeting)).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentBlue.withOpacity(0.3), width: 1),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _attendancePercentage,
                      strokeWidth: 8,
                      backgroundColor: accentBlue.withOpacity(0.2),
                      color: accentBlue,
                    ),
                    Text(
                      '${(_attendancePercentage * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Check In", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: accentBlue, size: 14),
                        const SizedBox(width: 4),
                        Text("Cairo, Egypt", style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    Text(
                      _convertTo12HourFormat(_todayCheckIn ?? '--:--'),
                      style: TextStyle(color: accentBlue, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("Check Out", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(
                      _todayCheckOut == null || _todayCheckOut == '--:--'
                          ? "Not Checked Out"
                          : _convertTo12HourFormat(_todayCheckOut!),
                      style: TextStyle(
                        color: _todayCheckOut == null || _todayCheckOut == '--:--' ? Colors.red : Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingIn ? null : _quickCheckIn,
              icon: _isCheckingIn
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Icon(Icons.logout),
              label: Text(_isCheckingIn ? 'Checking In...' : 'End Shift'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentBlue.withOpacity(0.2), width: 1),
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: accentBlue, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _meetingCard(Map<String, dynamic> meeting) {
    final timeDisplay = _extractTime(meeting);
    final title = meeting['title'] ?? 'Meeting';
    final location = meeting['location'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentBlue.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: accentBlue),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: accentBlue),
                  const SizedBox(width: 4),
                  Text(
                    timeDisplay,
                    style:  TextStyle(color: accentBlue, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  meeting['status']?.toString().toUpperCase() ?? 'UPCOMING',
                  style: const TextStyle(color: Color(0xFF7B82FF), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
