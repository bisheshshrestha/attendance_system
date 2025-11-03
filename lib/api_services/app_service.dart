// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AppService {
//   static const String ninjaUrl = "https://api.api-ninjas.com/v1";
//   static const String ninjaApiKey = "wvfzoGlwsXuTbfULJGNkWA==VrGoHfnK8xR7OLbN";
//
//   static List<Map<String, dynamic>> meetings = [];
//
//   static final mockUsers = [
//     {
//       'id': '1',
//       'username': 'mmorris',
//       'email': 'lindsay32@hotmail.com',
//       'password': 'password123',
//       'name': 'Susan Johnson',
//       'sex': 'F',
//       'address': '686 Robert Bridge Suite 551, North Loriland, PA 64298',
//       'birthday': '1926-05-29',
//       'role': 'employee',
//       'department': 'IT',
//     },
//     {
//       'id': '2',
//       'username': 'john_doe',
//       'email': 'john@gmail.com',
//       'password': 'john123',
//       'name': 'John Doe',
//       'sex': 'M',
//       'address': '123 Main St',
//       'birthday': '1990-01-15',
//       'role': 'employee',
//       'department': 'IT',
//     },
//     {
//       'id': '3',
//       'username': 'jane_smith',
//       'email': 'jane@gmail.com',
//       'password': 'jane123',
//       'name': 'Jane Smith',
//       'sex': 'F',
//       'address': '456 Oak Ave',
//       'birthday': '1992-03-20',
//       'role': 'employee',
//       'department': 'HR',
//     },
//     {
//       'id': '4',
//       'username': 'mike_johnson',
//       'email': 'mike@gmail.com',
//       'password': 'mike123',
//       'name': 'Mike Johnson',
//       'sex': 'M',
//       'address': '789 Pine Rd',
//       'birthday': '1988-07-10',
//       'role': 'employee',
//       'department': 'Finance',
//     },
//     {
//       'id': 'admin1',
//       'username': 'admin',
//       'email': 'admin@gmail.com',
//       'password': 'admin123',
//       'name': 'Admin User',
//       'sex': 'M',
//       'address': 'Admin Building',
//       'birthday': '1985-05-05',
//       'role': 'admin',
//       'department': 'Management',
//     },
//   ];
//
//   // ==================== INITIALIZE MEETINGS ====================
//   static Future initializeMeetings() async {
//     final prefs = await SharedPreferences.getInstance();
//     final meetingsJson = prefs.getString('meetings_list');
//
//     if (meetingsJson == null) {
//       meetings = [
//         {
//           'id': '1',
//           'title': 'Team Standup',
//           'description': 'Daily team sync meeting',
//           'date_time': '2025-11-02 09:30 AM',
//           'location': 'Conference Room A',
//           'attendees': ['John Doe', 'Jane Smith'],
//           'status': 'upcoming',
//         },
//         {
//           'id': '2',
//           'title': 'Board Meeting',
//           'description': 'Quarterly board review',
//           'date_time': '2025-11-02 02:00 PM',
//           'location': 'Main Hall',
//           'attendees': ['Admin User', 'Mike Johnson'],
//           'status': 'upcoming',
//         },
//       ];
//       await _saveMeetings();
//     } else {
//       meetings = List<Map<String, dynamic>>.from(jsonDecode(meetingsJson));
//     }
//   }
//
//   static Future _saveMeetings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('meetings_list', jsonEncode(meetings));
//   }
//
//   // ==================== NEW: USERNAME + PASSWORD LOGIN ====================
//   static Future<Map<String, dynamic>> loginWithUsernamePassword({
//     required String username,
//     required String password,
//   }) async {
//     try {
//       print('🔄 Attempting login with username: $username');
//       await Future.delayed(const Duration(seconds: 1));
//
//       final user = mockUsers.firstWhere(
//             (u) => u['username'] == username && u['password'] == password,
//         orElse: () => {},
//       );
//
//       if (user.isEmpty) {
//         print('❌ Invalid username or password');
//         return {
//           'success': false,
//           'error': 'Invalid username or password',
//         };
//       }
//
//       print('✅ Login successful: ${user['name']}');
//
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('user_id', user['username'] ?? 'unknown');
//       await prefs.setString('user_name', user['name'] ?? 'User');
//       await prefs.setString('user_email', user['email'] ?? '');
//       await prefs.setString('user_role', user['role'] ?? 'employee');
//
//       return {
//         'success': true,
//         'user_id': user['username'],
//         'name': user['name'],
//         'email': user['email'],
//         'sex': user['sex'],
//         'address': user['address'],
//         'birthday': user['birthday'],
//         'role': user['role'],
//       };
//     } catch (e) {
//       print('❌ Login error: $e');
//       return {
//         'success': false,
//         'error': 'Error: ${e.toString()}',
//       };
//     }
//   }
//
//   // ==================== EXISTING: OLD EMAIL/PASSWORD LOGIN (KEEP FOR COMPATIBILITY) ====================
//   static Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//     required String role,
//   }) async {
//     await Future.delayed(const Duration(seconds: 1));
//
//     final user = mockUsers.firstWhere(
//           (u) =>
//       u['email'] == email &&
//           u['password'] == password &&
//           u['role'] == role,
//       orElse: () => {},
//     );
//
//     if (user.isEmpty) {
//       return {'success': false, 'error': 'Invalid credentials'};
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_id', user['id']!);
//     await prefs.setString('user_name', user['name']!);
//     await prefs.setString('user_role', role);
//
//     return {
//       'success': true,
//       'user_id': user['id'],
//       'name': user['name'],
//       'role': role,
//     };
//   }
//
//   // ==================== USER MANAGEMENT ====================
//   static Future<Map<String, dynamic>> getStoredUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'user_id': prefs.getString('user_id'),
//       'user_name': prefs.getString('user_name'),
//       'user_email': prefs.getString('user_email'),
//       'user_role': prefs.getString('user_role'),
//     };
//   }
//
//   static Future logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
//
//   static Future<bool> isAuthenticated() async {
//     final user = await getStoredUser();
//     return user['user_id'] != null;
//   }
//
//   // ==================== MEETINGS MANAGEMENT ====================
//   static Future<List<Map<String, dynamic>>> getMeetings() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return meetings;
//   }
//
//   static Future<Map<String, dynamic>> createMeeting({
//     required String title,
//     required String description,
//     required String dateTime,
//     required String location,
//     required List<String> attendees,
//     String status = "upcoming",
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final newMeeting = {
//       'id': DateTime.now().millisecondsSinceEpoch.toString(),
//       'title': title,
//       'description': description,
//       'date_time': dateTime,
//       'location': location,
//       'attendees': attendees,
//       'status': status,
//     };
//
//     meetings.add(newMeeting);
//     await _saveMeetings();
//
//     return {
//       'success': true,
//       'message': 'Meeting created successfully',
//       'meeting': newMeeting,
//     };
//   }
//
//   static Future<Map<String, dynamic>> updateMeeting({
//     required String meetingId,
//     required String title,
//     required String description,
//     required String dateTime,
//     required String location,
//     required String status,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final index = meetings.indexWhere((m) => m['id'] == meetingId);
//
//     if (index == -1) {
//       return {'success': false, 'error': 'Meeting not found'};
//     }
//
//     meetings[index] = {
//       ...meetings[index],
//       'title': title,
//       'description': description,
//       'date_time': dateTime,
//       'location': location,
//       'status': status,
//     };
//
//     await _saveMeetings();
//
//     return {
//       'success': true,
//       'message': 'Meeting updated successfully',
//     };
//   }
//
//   static Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     meetings.removeWhere((m) => m['id'] == meetingId);
//     await _saveMeetings();
//
//     return {
//       'success': true,
//       'message': 'Meeting deleted successfully',
//     };
//   }
//
//   static Future<List<Map<String, dynamic>>> getMeetingsByStatus(
//       String status) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return meetings.where((m) => m['status'] == status).toList();
//   }
//
//   static Future<List<Map<String, dynamic>>> getMeetingsByDate(String date) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     return meetings.where((m) => m['date_time'].contains(date)).toList();
//   }
//
//   // ==================== ATTENDANCE MANAGEMENT ====================
//   static Future<Map<String, dynamic>> markAttendance({
//     required String latitude,
//     required String longitude,
//   }) async {
//     await Future.delayed(const Duration(seconds: 1));
//
//     final user = await getStoredUser();
//     final userId = user['user_id'];
//
//     if (userId == null) {
//       return {'success': false, 'error': 'Not authenticated'};
//     }
//
//     final hour = DateTime.now().hour;
//     final minute = DateTime.now().minute;
//     String status = 'Present';
//
//     if (hour > 9 || (hour == 9 && minute > 30)) {
//       status = 'Late';
//     }
//
//     final attendanceRecord = {
//       'id': DateTime.now().millisecondsSinceEpoch.toString(),
//       'user_id': userId,
//       'user_name': user['user_name'],
//       'check_in_time':
//       '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
//       'status': status,
//       'date': DateTime.now().toString().split(' '),
//       'latitude': latitude,
//       'longitude': longitude,
//     };
//
//     final prefs = await SharedPreferences.getInstance();
//     final attendanceJson = prefs.getString('attendance_records') ?? '[]';
//     final attendanceList = jsonDecode(attendanceJson) as List;
//
//     attendanceList.add(attendanceRecord);
//
//     await prefs.setString('attendance_records', jsonEncode(attendanceList));
//
//     return {
//       'success': true,
//       'message': 'Attendance marked - Status: $status',
//       'status': status,
//     };
//   }
//
//   static Future<List<Map<String, dynamic>>> getTodayAttendance() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final user = await getStoredUser();
//     final userId = user['user_id'];
//
//     final prefs = await SharedPreferences.getInstance();
//     final attendanceJson = prefs.getString('attendance_records') ?? '[]';
//     final attendance = jsonDecode(attendanceJson) as List;
//     final today = DateTime.now().toString().split(' ')[0];
//
//     final todayAttendance = attendance
//         .where((a) => a['date'] == today && a['user_id'] == userId)
//         .toList();
//
//     if (todayAttendance.isEmpty) {
//       return [];
//     }
//
//     return List<Map<String, dynamic>>.from(todayAttendance);
//   }
//
//
//   static Future<List<Map<String, dynamic>>> getUserAttendanceHistory() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final user = await getStoredUser();
//     final userId = user['user_id'];
//
//     if (userId == null) return [];
//
//     final prefs = await SharedPreferences.getInstance();
//     final attendanceJson = prefs.getString('attendance_records') ?? '[]';
//     final attendance = jsonDecode(attendanceJson) as List;
//
//     return List<Map<String, dynamic>>.from(attendance.where((a) => a['user_id'] == userId).toList(),
//     );
//   }
//
//   static Future<Map<String, dynamic>> getAttendanceStats() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final prefs = await SharedPreferences.getInstance();
//     final attendanceJson = prefs.getString('attendance_records') ?? '[]';
//     final attendance = jsonDecode(attendanceJson) as List;
//
//     final present = attendance.where((a) => a['status'] == 'Present').length;
//     final late = attendance.where((a) => a['status'] == 'Late').length;
//     final absent = attendance.where((a) => a['status'] == 'Absent').length;
//
//     return {
//       'total': attendance.length,
//       'present': present,
//       'late': late,
//       'absent': absent,
//       'present_percentage': attendance.isEmpty
//           ? 0
//           : ((present / attendance.length) * 100).toStringAsFixed(2),
//     };
//   }
//
//   // ==================== EMPLOYEES MANAGEMENT ====================
//   static Future<List<Map<String, dynamic>>> getEmployees() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     return mockUsers.where((user) => user['role'] == 'employee').toList();
//   }
//
//   static Future<Map<String, dynamic>> getEmployeeDetails(
//       String employeeId) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//
//     final employee = mockUsers.firstWhere(
//           (user) => user['username'] == employeeId && user['role'] == 'employee',
//       orElse: () => {},
//     );
//
//     if (employee.isEmpty) {
//       return {'success': false, 'error': 'Employee not found'};
//     }
//
//     return {
//       'success': true,
//       ...employee,
//     };
//   }
//
//   // ==================== ADMIN FUNCTIONS ====================
//   static Future<Map<String, dynamic>> adminLogin({
//     required String username,
//     required String password,
//   }) async {
//     await Future.delayed(const Duration(seconds: 1));
//
//     final admin = mockUsers.firstWhere(
//           (u) =>
//       u['username'] == username &&
//           u['password'] == password &&
//           u['role'] == 'admin',
//       orElse: () => {},
//     );
//
//     if (admin.isEmpty) {
//       return {'success': false, 'error': 'Invalid admin credentials'};
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_id', admin['username']!);
//     await prefs.setString('user_name', admin['name']!);
//     await prefs.setString('user_role', 'admin');
//
//     return {
//       'success': true,
//       'user_id': admin['username'],
//       'name': admin['name'],
//       'role': 'admin',
//     };
//   }
//
//   static Future<List<Map<String, dynamic>>> getAllAttendanceRecords() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final prefs = await SharedPreferences.getInstance();
//     final attendanceJson = prefs.getString('attendance_records') ?? '[]';
//     return List<Map<String, dynamic>>.from(jsonDecode(attendanceJson));
//   }
//
//   static Future<Map<String, dynamic>> getDetailedAttendanceStats() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     final allRecords = await getAllAttendanceRecords();
//     final employees = await getEmployees();
//
//     final present = allRecords.where((a) => a['status'] == 'Present').length;
//     final late = allRecords.where((a) => a['status'] == 'Late').length;
//     final absent = allRecords.where((a) => a['status'] == 'Absent').length;
//
//     return {
//       'total_employees': employees.length,
//       'total_records': allRecords.length,
//       'present': present,
//       'late': late,
//       'absent': absent,
//       'present_percentage': allRecords.isEmpty
//           ? 0
//           : ((present / allRecords.length) * 100).toStringAsFixed(2),
//       'late_percentage': allRecords.isEmpty
//           ? 0
//           : ((late / allRecords.length) * 100).toStringAsFixed(2),
//     };
//   }
// }

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppService {
  static List<Map<String, dynamic>> meetings = [];

  // ==================== INITIALIZE MEETINGS ====================
  static Future initializeMeetings() async {
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
  }

  static Future _saveMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('meetings_list', jsonEncode(meetings));
  }

  // ==================== USER MANAGEMENT ====================
  static Future<Map<String, dynamic>> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString('user_id'),
      'user_name': prefs.getString('user_name'),
      'user_email': prefs.getString('user_email'),
      'user_role': prefs.getString('user_role'),
    };
  }

  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isAuthenticated() async {
    final user = await getStoredUser();
    return user['user_id'] != null;
  }

  // ==================== MEETINGS MANAGEMENT ====================
  static Future<List<Map<String, dynamic>>> getMeetings() async {
    await Future.delayed(const Duration(milliseconds: 300));
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

    return {
      'success': true,
      'message': 'Meeting updated successfully',
    };
  }

  static Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    meetings.removeWhere((m) => m['id'] == meetingId);
    await _saveMeetings();

    return {
      'success': true,
      'message': 'Meeting deleted successfully',
    };
  }

  static Future<List<Map<String, dynamic>>> getMeetingsByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return meetings.where((m) => m['status'] == status).toList();
  }

  static Future<List<Map<String, dynamic>>> getMeetingsByDate(String date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return meetings.where((m) => m['date_time'].contains(date)).toList();
  }

  // ==================== ATTENDANCE MANAGEMENT ====================
  static Future<Map<String, dynamic>> markAttendance({
    required String userName,
    required String latitude,
    required String longitude,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = await getStoredUser();
    final userId = user['user_id'];

    if (userId == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }

    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    String status = 'Present';

    if (hour > 9 || (hour == 9 && minute > 30)) {
      status = 'Late';
    }

    final attendanceRecord = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
      'user_name': userName, // ✅ Use API name instead of mockUser
      'check_in_time':
      '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      'status': status,
      'date': DateTime.now().toString().split(' ')[0], // ✅ Fixed to String
      'latitude': latitude,
      'longitude': longitude,
    };

    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString('attendance_records') ?? '[]';
    final attendanceList = jsonDecode(attendanceJson) as List;

    attendanceList.add(attendanceRecord);

    await prefs.setString('attendance_records', jsonEncode(attendanceList));

    return {
      'success': true,
      'message': 'Attendance marked - Status: $status',
      'status': status,
    };
  }

  static Future<List<Map<String, dynamic>>> getTodayAttendance() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = await getStoredUser();
    final userId = user['user_id'];

    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString('attendance_records') ?? '[]';
    final attendance = jsonDecode(attendanceJson) as List;
    final today = DateTime.now().toString().split(' ')[0];

    final todayAttendance = attendance
        .where((a) => a['date'] == today && a['user_id'] == userId)
        .toList();

    if (todayAttendance.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(todayAttendance);
  }

  static Future<List<Map<String, dynamic>>> getUserAttendanceHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = await getStoredUser();
    final userId = user['user_id'];

    if (userId == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString('attendance_records') ?? '[]';
    final attendance = jsonDecode(attendanceJson) as List;

    return List<Map<String, dynamic>>.from(
      attendance.where((a) => a['user_id'] == userId).toList(),
    );
  }

  static Future<Map<String, dynamic>> getAttendanceStats() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getString('attendance_records') ?? '[]';
    final attendance = jsonDecode(attendanceJson) as List;

    final present = attendance.where((a) => a['status'] == 'Present').length;
    final late = attendance.where((a) => a['status'] == 'Late').length;
    final absent = attendance.where((a) => a['status'] == 'Absent').length;

    return {
      'total': attendance.length,
      'present': present,
      'late': late,
      'absent': absent,
      'present_percentage': attendance.isEmpty
          ? 0
          : ((present / attendance.length) * 100).toStringAsFixed(2),
    };
  }
  /// Mark Checkout
  // static Future<Map<String, dynamic>> markCheckout() async {
  //   await Future.delayed(const Duration(milliseconds: 500));
  //
  //   final user = await getStoredUser();
  //   final userId = user['user_id'];
  //
  //   if (userId == null) {
  //     return {'success': false, 'error': 'Not authenticated'};
  //   }
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final attendanceJson = prefs.getString('attendance_records') ?? '[]';
  //   final attendanceList = jsonDecode(attendanceJson) as List;
  //
  //   final today = DateTime.now().toString().split(' ')[0];
  //
  //   // Find today's record for this user
  //   for (var record in attendanceList) {
  //     if (record['user_id'] == userId && record['date'].toString().contains(today)) {
  //       record['check_out_time'] =
  //       '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
  //       break;
  //     }
  //   }
  //
  //   await prefs.setString('attendance_records', jsonEncode(attendanceList));
  //
  //   return {
  //     'success': true,
  //     'message': 'Check-out marked successfully',
  //   };
  // }

  /// Mark Checkout - Works without ID
  static Future<Map<String, dynamic>> markCheckout() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get user name instead of ID
      final userName = prefs.getString('user_name');

      if (userName == null) {
        return {'success': false, 'error': 'User not authenticated'};
      }

      final attendanceJson = prefs.getString('attendance_records') ?? '[]';
      final attendanceList = jsonDecode(attendanceJson) as List;

      final today = DateTime.now().toString().split(' ')[0];

      // Find and update today's record by USER NAME
      bool found = false;
      for (var record in attendanceList) {
        if (record['user_name'] == userName && record['date'].toString().contains(today)) {
          // Only update if checkout is not already set
          if (record['check_out_time'] == null || record['check_out_time'] == '--:--') {
            record['check_out_time'] =
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
            found = true;
            debugPrint('✓ Checkout marked at: ${record['check_out_time']}');
            break;
          } else {
            return {'success': false, 'error': 'Already checked out'};
          }
        }
      }

      if (!found) {
        return {'success': false, 'error': 'No check-in found for today'};
      }

      await prefs.setString('attendance_records', jsonEncode(attendanceList));

      return {
        'success': true,
        'message': 'Check-out marked successfully at ${DateTime.now().hour}:${DateTime.now().minute}',
      };
    } catch (e) {
      debugPrint('Checkout error: $e');
      return {'success': false, 'error': 'Error: $e'};
    }
  }

}


