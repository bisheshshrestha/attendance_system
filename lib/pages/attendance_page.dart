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
  String? _recentCheckIn;
  String? _recentCheckOut;
  String? _recentStatus;
  String? _userName;
  String? _sessionId;
  List<Map<String, dynamic>> _attendanceHistory = [];
  Map<String, dynamic> _stats = {};
  String _workStartTime = '09:00';
  int _lateThresholdMinutes = 15;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _initializeSession();
    await _loadCheckInSettings();
    await _fetchCurrentUserAndHistory();
    await _loadStatistics();
  }

  /// Initialize or retrieve session ID
  Future<void> _initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var sessionId = prefs.getString('session_id');

      if (sessionId == null || sessionId.isEmpty) {
        // Create new session ID
        sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('session_id', sessionId);
        debugPrint('✅ New session created: $sessionId');
      } else {
        debugPrint('✅ Session retrieved: $sessionId');
      }

      setState(() {
        _sessionId = sessionId;
      });
    } catch (e) {
      debugPrint('❌ Error initializing session: $e');
    }
  }

  Future<void> _loadCheckInSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _workStartTime = prefs.getString('work_start_time') ?? '09:00';
        _lateThresholdMinutes = prefs.getInt('late_threshold_minutes') ?? 15;
      });
      debugPrint('✅ Settings loaded: Start=$_workStartTime, Grace=$_lateThresholdMinutes min');
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
    }
  }

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

      return checkInMinutes > allowedMinutes ? 'Late' : 'Present';
    } catch (e) {
      debugPrint('❌ Error determining status: $e');
      return 'Present';
    }
  }

  Future<void> _fetchCurrentUserAndHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      debugPrint('🔄 Fetching attendance data...');
      final person = await PersonService().getPerson();
      final history = await AppService.getUserAttendanceHistory();

      if (!mounted) return;

      final today = DateTime.now().toString().split(' ')[0];
      final todayRecords = history.where((r) => r['date']?.toString() == today).toList();

      debugPrint('📋 Total records: ${history.length}');
      debugPrint('📅 Today\'s records: ${todayRecords.length}');

      String checkIn = '--:--';
      String checkOut = '--:--';
      String status = 'Absent';

      if (todayRecords.isNotEmpty) {
        final latestRecord = todayRecords.last;
        checkIn = latestRecord['check_in_time']?.toString() ?? '--:--';
        checkOut = latestRecord['check_out_time']?.toString() ?? '--:--';
        status = _determineStatus(checkIn);
        debugPrint('✅ Record: CheckIn=$checkIn, CheckOut=$checkOut, Status=$status');
      } else {
        debugPrint('⚠️ No records for today');
      }

      setState(() {
        _userName = person.name;
        _attendanceHistory = List<Map<String, dynamic>>.from(history.reversed);
        _recentCheckIn = checkIn;
        _recentCheckOut = checkOut;
        _recentStatus = status;
      });
      debugPrint('✅ UI Updated');
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        setState(() {
          _recentCheckIn = '--:--';
          _recentCheckOut = '--:--';
          _recentStatus = 'Error';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await AppService.getAttendanceStats();
      if (mounted) {
        setState(() => _stats = stats);
        debugPrint(
            '✅ Stats: P=${stats['present_count']}, L=${stats['late_count']}, A=${stats['absent_count']}');
      }
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
    }
  }

  Future<void> _markCheckIn() async {
    if (_isLoading || _recentCheckIn != '--:--' || _sessionId == null) return;
    setState(() => _isLoading = true);
    try {
      debugPrint('🔄 Marking check-in...');
      final person = await PersonService().getPerson();
      final result = await AppService.markAttendanceBySession(
        sessionId: _sessionId!,
        userName: person.name,
        latitude: '27.7172',
        longitude: '85.3240',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        debugPrint('✅ Check-in successful, refreshing data...');
        await Future.delayed(const Duration(milliseconds: 500));
        await _fetchCurrentUserAndHistory();
        await _loadStatistics();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Checked in at $_recentCheckIn - Status: $_recentStatus'),
              backgroundColor: _recentStatus == 'Late' ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Check-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markCheckOut() async {
    if (_isLoading || _recentCheckOut != '--:--' || _sessionId == null) return;
    setState(() => _isLoading = true);
    try {
      debugPrint('🔄 Marking check-out...');

      final result = await AppService.markCheckoutBySession(sessionId: _sessionId!);

      if (!mounted) return;

      if (result['success'] == true) {
        debugPrint('✅ Checkout successful, refreshing data...');
        await Future.delayed(const Duration(milliseconds: 500));
        await _fetchCurrentUserAndHistory();
        await _loadStatistics();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Checked out at $_recentCheckOut'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Checkout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
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
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            if (_userName != null)
              Container(
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentBlue.withOpacity(0.2)),
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
                          Text(
                            DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Today's Status Card
            Container(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentBlue.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Status',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Check In',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
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
                            const Text(
                              'Check Out',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_recentStatus ?? 'Absent').withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _recentStatus ?? 'Absent',
                                style: TextStyle(
                                  color: _getStatusColor(_recentStatus ?? 'Absent'),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Check In / Check Out Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_recentCheckIn != '--:--' || _isLoading) ? null : _markCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading && _recentCheckIn == '--:--'
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Check In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_recentCheckOut != '--:--' || _recentCheckIn == '--:--' || _isLoading)
                        ? null
                        : _markCheckOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading && _recentCheckOut == '--:--'
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Check Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentBlue.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'Present',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_stats['present_count'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentBlue.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'Late',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_stats['late_count'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentBlue.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          'Absent',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_stats['absent_count'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Attendance History Header
            const Text(
              'Attendance History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Attendance History List
            if (_attendanceHistory.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentBlue.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(24),
                child: const Center(
                  child: Text(
                    'No attendance records yet',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attendanceHistory.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final record = _attendanceHistory[index];
                  final date = record['date']?.toString() ?? 'Unknown';
                  final checkIn = record['check_in_time']?.toString() ?? '--:--';
                  final checkOut = record['check_out_time']?.toString() ?? '--:--';
                  final status = record['status']?.toString() ?? 'Unknown';

                  return Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentBlue.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check In',
                                  style: TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkIn,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check Out',
                                  style: TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  checkOut,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (record['latitude'] != null && record['longitude'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location',
                                    style: TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    Icons.location_on,
                                    color: accentBlue,
                                    size: 16,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
