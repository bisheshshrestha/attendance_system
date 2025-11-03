import 'package:attendance_system/api_services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAttendance extends StatefulWidget {
  const AdminAttendance({super.key});

  @override
  State<AdminAttendance> createState() => _AdminAttendanceState();
}

class _AdminAttendanceState extends State<AdminAttendance> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  String selectedDate = "";
  String selectedFilter = "All";
  List<Map<String, dynamic>> attendanceRecords = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toString().split(' ')[0];
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final history = await AppService.getUserAttendanceHistory();

      debugPrint('Total records from API: ${history.length}');

      if (history.isNotEmpty) {
        // Filter records by selected date
        final filteredRecords = history.where((r) {
          final dateStr = _extractSafeDate(r);
          return dateStr == selectedDate;
        }).toList();

        debugPrint('Records for $selectedDate: ${filteredRecords.length}');

        // Transform API data to match UI requirements
        final transformed = filteredRecords.map((record) {
          return {
            'name': record['user_name']?.toString() ?? record['userName']?.toString() ?? 'Unknown User',
            'user_id': record['user_id']?.toString() ?? record['userId']?.toString() ?? 'N/A',
            'checkIn': _convertTo12HourFormat(record['check_in_time']?.toString() ?? '--:--'),
            'checkOut': (record['check_out_time'] != null &&
                record['check_out_time'].toString() != '--:--' &&
                record['check_out_time'].toString().isNotEmpty)
                ? _convertTo12HourFormat(record['check_out_time'].toString())
                : '--:--',
            'status': record['status']?.toString() ?? 'Unknown',
            'date': _extractSafeDate(record),
            'latitude': record['latitude']?.toString() ?? 'N/A',
            'longitude': record['longitude']?.toString() ?? 'N/A',
          };
        }).toList();

        setState(() {
          attendanceRecords = transformed;
          _isLoading = false;
        });
      } else {
        setState(() {
          attendanceRecords = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load attendance data: $e';
      });
    }
  }

  /// Get filtered records based on status
  List<Map<String, dynamic>> _getFilteredRecords() {
    if (selectedFilter == "All") {
      return attendanceRecords;
    }
    return attendanceRecords
        .where((record) => record['status'] == selectedFilter)
        .toList();
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

  String _extractSafeDate(Map<String, dynamic> record) {
    try {
      final dateField = record['date'];
      if (dateField is String && dateField.isNotEmpty) {
        return dateField;
      }
      if (dateField is List && dateField.isNotEmpty) {
        final first = dateField.first;
        if (first is String && first.isNotEmpty) {
          return first;
        }
      }
      return DateTime.now().toString().split(' ')[0];
    } catch (e) {
      debugPrint('Error extracting date: $e');
      return DateTime.now().toString().split(' ')[0];
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
          "Attendance Management",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAttendanceData,
        backgroundColor: darkBlue,
        color: accentBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(selectedDate),
                          firstDate: DateTime(2025),
                          lastDate: DateTime.now(),
                        );

                        if (date != null) {
                          setState(() {
                            selectedDate = date.toString().split(' ')[0];
                          });
                          await _loadAttendanceData();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: accentBlue, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: accentBlue, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              selectedDate,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentBlue, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      dropdownColor: lightBlue,
                      underline: const SizedBox(),
                      items: ["All", "Present", "Absent", "Late"]
                          .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value ?? "All";
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Stats
              _buildSummaryStats(),
              const SizedBox(height: 20),

              // Loading State
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: accentBlue,
                  ),
                )
              // Error State
              else if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              // Empty State
              else if (_getFilteredRecords().isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accentBlue.withOpacity(0.3), width: 1),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white30, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            "No attendance records for $selectedDate",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                // Attendance Records List
                else
                  Column(
                    children: _getFilteredRecords()
                        .map((record) => _attendanceCard(record))
                        .toList(),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final filtered = _getFilteredRecords();
    final present = filtered.where((r) => r['status'] == 'Present').length;
    final absent = filtered.where((r) => r['status'] == 'Absent').length;
    final late = filtered.where((r) => r['status'] == 'Late').length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard('Total', filtered.length.toString(), Colors.blue),
        _statCard('Present', present.toString(), Colors.green),
        _statCard('Late', late.toString(), Colors.orange),
        _statCard('Absent', absent.toString(), Colors.red),
      ],
    );
  }

  Widget _statCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _attendanceCard(Map<String, dynamic> record) {
    Color statusColor;
    IconData statusIcon;
    switch (record["status"]) {
      case "Present":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case "Late":
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case "Absent":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record["name"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${record["user_id"]}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      record["status"],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeInfo("Check In", record["checkIn"]),
              _timeInfo("Check Out", record["checkOut"]),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location: ${record["latitude"]}, ${record["longitude"]}',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                Icon(
                  Icons.location_on,
                  color: accentBlue,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
