import 'package:attendance_system/api_services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => MeetingPageState();
}

class MeetingPageState extends State<MeetingPage> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  late Future<List<Map<String, dynamic>>> meetingsFuture;

  @override
  void initState() {
    super.initState();
    meetingsFuture = Future.value(_initializeData());
  }

  Future<List<Map<String, dynamic>>> _initializeData() async {
    await AppService.initializeMeetings();
    return AppService.getMeetings();
  }

  void _refreshMeetings() {
    setState(() {
      meetingsFuture = AppService.getMeetings();
    });
  }

  /// ✅ FIXED: Get meetings for a specific day - handles both 'date_time' and 'datetime' keys
  Future<List<Map<String, dynamic>>> _getMeetingsForDay(DateTime day) async {
    final allMeetings = await AppService.getMeetings();
    final dayFormatted = DateFormat('yyyy-MM-dd').format(day);

    debugPrint('Looking for meetings on: $dayFormatted');
    debugPrint('Total meetings: ${allMeetings.length}');

    return allMeetings.where((meeting) {
      // Try both 'date_time' and 'datetime' keys
      final dateTimeValue = (meeting['date_time'] ?? meeting['datetime'])?.toString() ?? '';
      debugPrint('Meeting "${meeting['title']}" has date_time: $dateTimeValue');
      return dateTimeValue.contains(dayFormatted);
    }).toList();
  }

  /// ✅ FIXED: Extract date from meeting data
  String _extractDate(Map<String, dynamic> meeting) {
    final dateTimeStr = (meeting['date_time'] ?? meeting['datetime'])?.toString() ?? 'N/A';

    if (dateTimeStr == 'N/A' || dateTimeStr.isEmpty) {
      return 'N/A';
    }

    try {
      // Split by space and get the first part (date)
      final parts = dateTimeStr.split(' ');
      return parts[0]; // Returns YYYY-MM-DD
    } catch (e) {
      debugPrint('Error extracting date: $e');
      return 'N/A';
    }
  }

  /// ✅ FIXED: Extract time from meeting data
  String _extractTime(Map<String, dynamic> meeting) {
    final dateTimeStr = (meeting['date_time'] ?? meeting['datetime'])?.toString() ?? 'N/A';

    if (dateTimeStr == 'N/A' || dateTimeStr.isEmpty) {
      return 'N/A';
    }

    try {
      // Split by space and get the time part
      final parts = dateTimeStr.split(' ');
      if (parts.length >= 2) {
        return '${parts[1]} ${parts[2]}'; // Returns HH:MM AM/PM
      }
      return 'N/A';
    } catch (e) {
      debugPrint('Error extracting time: $e');
      return 'N/A';
    }
  }

  void _showMeetingDetails(Map<String, dynamic> meeting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: Text(
          meeting['title'] ?? 'Meeting',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Description', meeting['description'] ?? 'N/A'),
              const SizedBox(height: 12),
              _detailRow('Date & Time', (meeting['date_time'] ?? meeting['datetime'])?.toString() ?? 'N/A'),
              const SizedBox(height: 12),
              _detailRow('Location', meeting['location'] ?? 'N/A'),
              const SizedBox(height: 12),
              if (meeting['status'] != null)
                _detailRow('Status', meeting['status'], isStatus: true),
              const SizedBox(height: 12),
              if (meeting['attendees'] != null && (meeting['attendees'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendees',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...(meeting['attendees'] as List).map(
                          (attendee) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          attendee.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isStatus = false}) {
    Color statusColor = Colors.white;
    if (isStatus) {
      if (value.toLowerCase() == 'upcoming') {
        statusColor = const Color(0xFF4CAF50);
      } else if (value.toLowerCase() == 'ongoing') {
        statusColor = const Color(0xFFFF9800);
      } else if (value.toLowerCase() == 'completed') {
        statusColor = const Color(0xFF2196F3);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: statusColor,
            fontSize: 14,
            fontWeight: isStatus ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meetings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Calendar Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date',
                      style: TextStyle(color: darkBlue, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TableCalendar(
                      firstDay: DateTime(2025, 1, 1),
                      lastDay: DateTime(2025, 12, 31),
                      focusedDay: focusedDay,
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          this.selectedDay = selectedDay;
                          this.focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Color.fromRGBO(28, 33, 101, 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: accentBlue,
                          shape: BoxShape.circle,
                        ),
                        weekendTextStyle: TextStyle(color: darkBlue),
                        defaultTextStyle: TextStyle(color: darkBlue),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronIcon: Icon(Icons.chevron_left, color: darkBlue),
                        rightChevronIcon: Icon(Icons.chevron_right, color: darkBlue),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: darkBlue),
                        weekendStyle: TextStyle(color: darkBlue),
                      ),
                      availableGestures: AvailableGestures.all,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Your Meetings Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Meetings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: selectedDay != null ? _getMeetingsForDay(selectedDay!) : AppService.getMeetings(),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return Text(
                            count.toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7B82FF)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Meetings List
              FutureBuilder<List<Map<String, dynamic>>>(
                future: selectedDay != null ? _getMeetingsForDay(selectedDay!) : AppService.getMeetings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: accentBlue),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading meetings', style: TextStyle(color: Colors.white)),
                    );
                  }

                  final meetings = snapshot.data ?? [];

                  if (meetings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No meetings scheduled',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: meetings.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => _meetingListTile(meetings[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meetingListTile(Map<String, dynamic> meeting) {
    final timeDisplay = _extractTime(meeting);
    final dateDisplay = _extractDate(meeting);

    Color statusColor = accentBlue;
    String status = meeting['status'] ?? 'upcoming';
    if (status.toLowerCase() == 'completed') {
      statusColor = const Color(0xFF4CAF50);
    } else if (status.toLowerCase() == 'ongoing') {
      statusColor = const Color(0xFFFF9800);
    }

    return GestureDetector(
      onTap: () => _showMeetingDetails(meeting),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentBlue.withOpacity(0.3), width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meeting['title'] ?? 'Meeting',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
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
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          timeDisplay,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          dateDisplay,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: accentBlue),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            meeting['location'] ?? 'N/A',
                            style: const TextStyle(color: Color(0xFF7B82FF), fontSize: 12, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
