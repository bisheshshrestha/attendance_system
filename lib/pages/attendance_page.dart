import 'package:attendance_system/api_services/app_service.dart';
import 'package:attendance_system/api_services/person_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  bool _isLoading = false;
  bool _isLoadingStats = false;
  String? _recentCheckIn;
  String? _recentCheckOut;
  String? _recentStatus;
  String? _userName;
  String? _userId;
  List<Map<String, dynamic>> _attendanceHistory = [];
  Map<String, dynamic> _stats = {};

  // Check-in settings variables
  String _workStartTime = '09:00';
  int _lateThresholdMinutes = 15;

  @override
  void initState() {
    super.initState();
    _initializeAttendancePage();
  }

  Future<void> _initializeAttendancePage() async {
    await _loadCheckInSettings();
    await _fetchCurrentUserAndHistory();
    await _loadStatistics();
  }

  /// Load Check-in Settings from SharedPreferences
  Future<void> _loadCheckInSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _workStartTime = prefs.getString('work_start_time') ?? '09:00';
        _lateThresholdMinutes = prefs.getInt('late_threshold_minutes') ?? 15;
      });
      debugPrint('Loaded settings: Start Time: $_workStartTime, Late Threshold: $_lateThresholdMinutes minutes');
    } catch (e) {
      debugPrint('Error loading check-in settings: $e');
    }
  }

  /// Determine if check-in time is late
  String _determineStatus(String checkInTime) {
    if (checkInTime == '--:--' || checkInTime.isEmpty) {
      return 'Absent';
    }

    try {
      String timeString = checkInTime.replaceAll(' AM', '').replaceAll(' PM', '').trim();
      List<String> timeParts = timeString.split(':');

      if (timeParts.length != 2) return 'Present';

      int checkInHour = int.parse(timeParts[0]);
      int checkInMinute = int.parse(timeParts[1]);

      if (checkInTime.contains('PM') && checkInHour != 12) {
        checkInHour += 12;
      } else if (checkInTime.contains('AM') && checkInHour == 12) {
        checkInHour = 0;
      }

      List<String> startParts = _workStartTime.split(':');
      int startHour = int.parse(startParts[0]);
      int startMinute = int.parse(startParts[1]);

      int allowedMinutes = startHour * 60 + startMinute + _lateThresholdMinutes;
      int checkInMinutes = checkInHour * 60 + checkInMinute;

      debugPrint('Check-in: $checkInMinutes, Allowed: $allowedMinutes, Threshold: $_lateThresholdMinutes min');

      if (checkInMinutes > allowedMinutes) {
        return 'Late';
      } else {
        return 'Present';
      }
    } catch (e) {
      debugPrint('Error determining status: $e');
      return 'Present';
    }
  }

  /// Fetch current user and attendance history
  Future<void> _fetchCurrentUserAndHistory() async {
    setState(() => _isLoading = true);

    try {
      final person = await PersonService().getPerson();
      final history = await AppService.getUserAttendanceHistory();

      if (mounted) {
        setState(() {
          _userName = person.name;
          // _userId = person.id.toString();
          _attendanceHistory = history;

          final today = DateTime.now().toString().split(' ')[0];
          final todayRecords = history.where((r) => r['date']?.toString().contains(today) ?? false).toList();

          if (todayRecords.isNotEmpty) {
            final latestRecord = todayRecords.last;
            _recentCheckIn = latestRecord['check_in_time']?.toString() ?? '--:--';
            _recentCheckOut = latestRecord['check_out_time']?.toString() ?? '--:--';
            _recentStatus = _determineStatus(_recentCheckIn!);
          } else {
            _recentCheckIn = '--:--';
            _recentCheckOut = '--:--';
            _recentStatus = 'Absent';
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          _recentCheckIn = '--:--';
          _recentCheckOut = '--:--';
          _recentStatus = 'Error';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Load attendance statistics
  Future<void> _loadStatistics() async {
    setState(() => _isLoadingStats = true);

    try {
      final stats = await AppService.getAttendanceStats();
      if (mounted) {
        setState(() => _stats = stats);
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      setState(() => _isLoadingStats = false);
    }
  }

  /// ✅ CHECK-IN Function
  Future<void> _markCheckIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final person = await PersonService().getPerson();

      final result = await AppService.markAttendance(
        userName: person.name,
        latitude: '27.7172',
        longitude: '85.3240',
      );

      if (mounted) {
        if (result['success'] == true) {
          await _fetchCurrentUserAndHistory();

          String message = _recentStatus == 'Late'
              ? '✓ Checked in! Status: LATE (Grace period exceeded)'
              : '✓ Checked in successfully! Status: PRESENT';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: _recentStatus == 'Late' ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['message'] ?? 'Unable to mark attendance'}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ✅ CHECK-OUT Function (Uses AppService.markCheckout())
  /// ✅ CHECK-OUT Function (FIXED - Works without ID)
  Future<void> _markCheckOut() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      debugPrint('Starting checkout...');

      // Call your AppService.markCheckout() method
      final result = await AppService.markCheckout();

      debugPrint('Checkout result: $result');

      if (mounted) {
        if (result['success'] == true) {
          // Refresh data to show updated checkout time
          await _fetchCurrentUserAndHistory();

          await Future.delayed(const Duration(milliseconds: 500));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Checked out successfully!\nTime: $_recentCheckOut'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          debugPrint('Checkout successful! New checkout time: $_recentCheckOut');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['message'] ?? result['error'] ?? 'Unable to checkout'}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

          debugPrint('Checkout failed: ${result['error']}');
        }
      }
    } catch (e) {
      debugPrint('Checkout exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _initializeAttendancePage,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            if (_userName != null)
              Container(
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentBlue.withOpacity(0.2), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accentBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          _userName![0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF7B82FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Work Hours Info Card
            Container(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentBlue.withOpacity(0.2), width: 1),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: accentBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work Start Time',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _workStartTime,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+$_lateThresholdMinutes min grace',
                      style: TextStyle(color: accentBlue, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today's Attendance Card with CHECK-IN & CHECK-OUT
            Container(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _recentStatus == 'Late'
                      ? Colors.orange.withOpacity(0.5)
                      : accentBlue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Status",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _recentStatus == 'Late'
                              ? Colors.orange.withOpacity(0.3)
                              : _recentStatus == 'Present'
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _recentStatus ?? 'Loading...',
                          style: TextStyle(
                            color: _recentStatus == 'Late'
                                ? Colors.orange
                                : _recentStatus == 'Present'
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check In',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _recentCheckIn ?? '--:--',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check Out',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _recentCheckOut ?? '--:--',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ CHECK-IN & CHECK-OUT BUTTONS
                  Row(
                    children: [
                      // Check-In Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _recentCheckIn == '--:--' && !_isLoading ? _markCheckIn : null,
                          icon: _isLoading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.login, size: 18),
                          label: Text(
                            _isLoading ? 'Checking In...' : 'Check In',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Check-Out Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _recentCheckIn != '--:--' && _recentCheckOut == '--:--' && !_isLoading
                              ? _markCheckOut
                              : null,
                          icon: _isLoading
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.logout, size: 18),
                          label: Text(
                            _isLoading ? 'Checking Out...' : 'Check Out',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Statistics Section
            Text(
              'Statistics',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (!_isLoadingStats)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Present',
                      _stats['present_count']?.toString() ?? '0',
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Late',
                      _stats['late_count']?.toString() ?? '0',
                      Colors.orange,
                      Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Absent',
                      _stats['absent_count']?.toString() ?? '0',
                      Colors.red,
                      Icons.close_outlined,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [1, 2, 3].map((_) {
                  return Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),

            // Attendance History Section
            Text(
              'Recent Attendance History',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_attendanceHistory.isNotEmpty)
              Column(
                children: _attendanceHistory.take(5).map((record) => _buildHistoryCard(record)).toList(),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No attendance records yet',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    String status = record['status']?.toString() ?? 'Unknown';
    Color statusColor = status.toLowerCase() == 'late'
        ? Colors.orange
        : status.toLowerCase() == 'present'
        ? Colors.green
        : Colors.red;

    IconData statusIcon = status.toLowerCase() == 'late'
        ? Icons.schedule
        : status.toLowerCase() == 'present'
        ? Icons.check_circle
        : Icons.close_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentBlue.withOpacity(0.1), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['date']?.toString() ?? 'N/A',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'In: ${record['check_in_time'] ?? '--:--'} | Out: ${record['check_out_time'] ?? '--:--'}',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
