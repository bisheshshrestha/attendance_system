import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppService {
  static List<Map<String, dynamic>> meetings = [];

  // ==================== INITIALIZE MEETINGS ====================
  static Future<void> initializeMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final meetingsJson = prefs.getString('meetings_list');

    if (meetingsJson == null) {
      meetings = [
        {
          'id': '1',
          'title': 'Team Standup',
          'description': 'Daily team sync meeting',
          'date_time': '2025-11-02 09:30 AM',
          'location': 'Conference Room A',
          'attendees': ['John Doe', 'Jane Smith'],
          'status': 'upcoming',
        },
        {
          'id': '2',
          'title': 'Board Meeting',
          'description': 'Quarterly board review',
          'date_time': '2025-11-02 02:00 PM',
          'location': 'Main Hall',
          'attendees': ['Admin User', 'Mike Johnson'],
          'status': 'upcoming',
        },
      ];
      await _saveMeetings();
    } else {
      meetings = List<Map<String, dynamic>>.from(jsonDecode(meetingsJson));
    }
    debugPrint('✅ Meetings initialized: ${meetings.length} meetings loaded');
  }

  static Future<void> _saveMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('meetings_list', jsonEncode(meetings));
    debugPrint('✅ Meetings saved to SharedPreferences');
  }

  // ==================== USER MANAGEMENT ====================
  static Future<Map<String, dynamic>> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = {
      'user_id': prefs.getString('user_id'),
      'user_name': prefs.getString('user_name'),
      'user_email': prefs.getString('user_email'),
      'user_role': prefs.getString('user_role'),
    };
    debugPrint('📋 Stored User: $user');
    return user;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('✅ User logged out and all data cleared');
  }

  static Future<bool> isAuthenticated() async {
    final user = await getStoredUser();
    return user['user_id'] != null && user['user_id'].toString().isNotEmpty;
  }

  // ==================== MEETINGS MANAGEMENT ====================
  static Future<List<Map<String, dynamic>>> getMeetings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('📋 Fetched ${meetings.length} meetings');
    return meetings;
  }

  static Future<Map<String, dynamic>> createMeeting({
    required String title,
    required String description,
    required String dateTime,
    required String location,
    required List<String> attendees,
    String status = "upcoming",
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newMeeting = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'description': description,
      'date_time': dateTime,
      'location': location,
      'attendees': attendees,
      'status': status,
    };

    meetings.add(newMeeting);
    await _saveMeetings();
    debugPrint('✅ Meeting created: ${newMeeting['id']}');

    return {
      'success': true,
      'message': 'Meeting created successfully',
      'meeting': newMeeting,
    };
  }

  static Future<Map<String, dynamic>> updateMeeting({
    required String meetingId,
    required String title,
    required String description,
    required String dateTime,
    required String location,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = meetings.indexWhere((m) => m['id'] == meetingId);

    if (index == -1) {
      debugPrint('❌ Meeting not found: $meetingId');
      return {'success': false, 'error': 'Meeting not found'};
    }

    meetings[index] = {
      ...meetings[index],
      'title': title,
      'description': description,
      'date_time': dateTime,
      'location': location,
      'status': status,
    };

    await _saveMeetings();
    debugPrint('✅ Meeting updated: $meetingId');

    return {
      'success': true,
      'message': 'Meeting updated successfully',
    };
  }

  static Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    meetings.removeWhere((m) => m['id'] == meetingId);
    await _saveMeetings();
    debugPrint('✅ Meeting deleted: $meetingId');

    return {
      'success': true,
      'message': 'Meeting deleted successfully',
    };
  }

  static Future<List<Map<String, dynamic>>> getMeetingsByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final filtered = meetings.where((m) => m['status'] == status).toList();
    debugPrint('📋 Found ${filtered.length} meetings with status: $status');
    return filtered;
  }

  static Future<List<Map<String, dynamic>>> getMeetingsByDate(String date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final filtered = meetings.where((m) => m['date_time'].contains(date)).toList();
    debugPrint('📋 Found ${filtered.length} meetings on date: $date');
    return filtered;
  }

  // ==================== ATTENDANCE MANAGEMENT ====================

  /// Initialize attendance records on first launch
  static Future<void> initializeAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString('attendance_records');

    if (attendanceJson == null) {
      await prefs.setString('attendance_records', jsonEncode([]));
      debugPrint('✅ Attendance records initialized (empty)');
    } else {
      final count = (jsonDecode(attendanceJson) as List).length;
      debugPrint('✅ Attendance records already exist: $count records');
    }
  }

  /// Mark attendance by Session ID - Independent of username changes
  static Future<Map<String, dynamic>> markAttendanceBySession({
    required String sessionId,
    required String userName,
    required String latitude,
    required String longitude,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('🔄 Marking attendance with sessionId: $sessionId, userName: $userName');

      final now = DateTime.now();
      final time =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final date = now.toString().split(' ')[0];

      // Check if already checked in today using SESSION ID
      final existingRecords = await getUserAttendanceHistory();
      final todayCheckIn = existingRecords.any((r) =>
      r['session_id'] == sessionId &&
          r['date'] == date &&
          r['check_in_time'] != '--:--');

      if (todayCheckIn) {
        debugPrint('❌ Already checked in today');
        return {
          'success': false,
          'error': 'Already checked in today',
          'message': 'You have already checked in',
        };
      }

      // Create new attendance record with session ID
      final newRecord = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'session_id': sessionId,
        'user_name': userName,
        'check_in_time': time,
        'check_out_time': '--:--',
        'status': 'Present',
        'date': date,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Get existing records and add new one
      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = prefs.getString('attendance_records') ?? '[]';
      final attendanceList = List<Map<String, dynamic>>.from(
        jsonDecode(attendanceJson).map((item) => Map<String, dynamic>.from(item as Map)),
      );
      attendanceList.add(newRecord);

      // Save to SharedPreferences
      await prefs.setString('attendance_records', jsonEncode(attendanceList));
      debugPrint('✅ Attendance marked successfully with session ID');
      debugPrint('✅ Record: $newRecord');
      debugPrint('✅ Total records: ${attendanceList.length}');

      return {
        'success': true,
        'message': 'Check-in successful at $time',
        'data': newRecord,
      };
    } catch (e) {
      debugPrint('❌ Error marking attendance: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to mark attendance',
      };
    }
  }

  /// Mark checkout by Session ID - Doesn't depend on current username
  static Future<Map<String, dynamic>> markCheckoutBySession({
    required String sessionId,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('🔄 Marking checkout for sessionId: $sessionId');

      if (sessionId.isEmpty) {
        debugPrint('❌ Session ID is empty');
        return {
          'success': false,
          'error': 'Session ID cannot be empty',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = prefs.getString('attendance_records') ?? '[]';
      final attendanceList = List<Map<String, dynamic>>.from(
        jsonDecode(attendanceJson).map((item) => Map<String, dynamic>.from(item as Map)),
      );

      final today = DateTime.now().toString().split(' ')[0];
      final checkOutTime =
          '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

      debugPrint('🔍 Looking for checkout record with sessionId: $sessionId on $today');
      debugPrint('📊 Total records available: ${attendanceList.length}');

      bool found = false;
      for (int i = 0; i < attendanceList.length; i++) {
        final record = attendanceList[i];
        debugPrint(
            '🔎 Checking record: sessionId=${record['session_id']}, date=${record['date']}');

        // Match by SESSION ID and DATE - not by username!
        if (record['session_id'] == sessionId && record['date'] == today) {
          debugPrint('📍 Found matching record at index $i');

          if (record['check_out_time'] == '--:--' || record['check_out_time'] == null) {
            attendanceList[i]['check_out_time'] = checkOutTime;
            found = true;
            debugPrint('✅ Checkout time updated to: $checkOutTime');
            break;
          } else {
            debugPrint('❌ Already checked out at: ${record['check_out_time']}');
            return {
              'success': false,
              'error': 'Already checked out at ${record['check_out_time']}',
            };
          }
        }
      }

      if (!found) {
        debugPrint('❌ No check-in record found for today');
        return {
          'success': false,
          'error': 'No check-in record found for today. Please check in first.',
        };
      }

      await prefs.setString('attendance_records', jsonEncode(attendanceList));
      debugPrint('✅ Checkout saved successfully');
      debugPrint('✅ Total records: ${attendanceList.length}');

      return {
        'success': true,
        'message': 'Check-out marked successfully at $checkOutTime',
        'checkout_time': checkOutTime,
      };
    } catch (e) {
      debugPrint('❌ Checkout error: $e');
      return {
        'success': false,
        'error': 'Error: $e',
        'message': 'Failed to mark checkout',
      };
    }
  }

  /// Get today's attendance
  static Future<List<Map<String, dynamic>>> getTodayAttendance() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = prefs.getString('attendance_records') ?? '[]';
      final attendance = List<Map<String, dynamic>>.from(
        jsonDecode(attendanceJson).map((item) => Map<String, dynamic>.from(item as Map)),
      );

      final today = DateTime.now().toString().split(' ')[0];
      final todayRecords = attendance.where((a) => a['date'] == today).toList();

      debugPrint('📅 Today\'s records: ${todayRecords.length}');
      return todayRecords;
    } catch (e) {
      debugPrint('❌ Error fetching today\'s attendance: $e');
      return [];
    }
  }

  /// Get all attendance history
  static Future<List<Map<String, dynamic>>> getUserAttendanceHistory() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = prefs.getString('attendance_records') ?? '[]';

      if (attendanceJson == '[]') {
        debugPrint('⚠️ No attendance records found');
        return [];
      }

      final attendance = List<Map<String, dynamic>>.from(
        jsonDecode(attendanceJson).map((item) => Map<String, dynamic>.from(item as Map)),
      );

      debugPrint('✅ Retrieved ${attendance.length} attendance records');
      return attendance;
    } catch (e) {
      debugPrint('❌ Error retrieving attendance history: $e');
      return [];
    }
  }

  /// Get attendance by specific date
  static Future<List<Map<String, dynamic>>> getAttendanceByDate(String date) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final allRecords = await getUserAttendanceHistory();
      final filtered = allRecords.where((a) => a['date'] == date).toList();

      debugPrint('📅 Attendance records for $date: ${filtered.length}');
      return filtered;
    } catch (e) {
      debugPrint('❌ Error filtering by date: $e');
      return [];
    }
  }

  /// Get attendance statistics
  static Future<Map<String, dynamic>> getAttendanceStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final allRecords = await getUserAttendanceHistory();

      final present = allRecords.where((a) => a['status'] == 'Present').length;
      final late = allRecords.where((a) => a['status'] == 'Late').length;
      final absent = allRecords.where((a) => a['status'] == 'Absent').length;
      final total = allRecords.length;

      final presentPercentage =
      total == 0 ? 0.0 : ((present / total) * 100).toStringAsFixed(2);

      debugPrint(
          '📊 Stats - Present: $present, Late: $late, Absent: $absent, Total: $total');

      return {
        'present_count': present,
        'late_count': late,
        'absent_count': absent,
        'total_count': total,
        'present_percentage': presentPercentage,
        'average_attendance': total == 0 ? 0 : ((present / total) * 100).toStringAsFixed(1),
      };
    } catch (e) {
      debugPrint('❌ Error calculating stats: $e');
      return {
        'present_count': 0,
        'late_count': 0,
        'absent_count': 0,
        'total_count': 0,
        'present_percentage': 0,
        'average_attendance': 0,
      };
    }
  }

  /// Clear all attendance records (for testing/debugging)
  static Future<void> clearAllAttendanceRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('attendance_records', jsonEncode([]));
      debugPrint('✅ All attendance records cleared');
    } catch (e) {
      debugPrint('❌ Error clearing records: $e');
    }
  }

  /// Delete specific attendance record
  static Future<bool> deleteAttendanceRecord(String recordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = prefs.getString('attendance_records') ?? '[]';
      final attendanceList = List<Map<String, dynamic>>.from(
        jsonDecode(attendanceJson).map((item) => Map<String, dynamic>.from(item as Map)),
      );

      final initialLength = attendanceList.length;
      attendanceList.removeWhere((record) => record['id'] == recordId);

      if (attendanceList.length < initialLength) {
        await prefs.setString('attendance_records', jsonEncode(attendanceList));
        debugPrint('✅ Record deleted: $recordId');
        return true;
      } else {
        debugPrint('❌ Record not found: $recordId');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting record: $e');
      return false;
    }
  }
}
