import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MeetingPage extends StatefulWidget {
  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color cardColor = Colors.white;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              // Date selector and calendar card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select date", style: TextStyle(fontSize: 15, color: darkBlue)),
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${_selectedDay != null ? _selectedDayFormatted() : _focusedDayFormatted()}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                        Icon(Icons.edit, color: darkBlue),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TableCalendar(
                      firstDay: DateTime.utc(2023, 1, 1),
                      lastDay: DateTime.utc(2027, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Color.fromRGBO(28, 33, 101, 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: darkBlue,
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
              // Meeting List
              Expanded(
                child: ListView(
                  children: [
                    _meetingListTile("HR Meeting", "08:30am", "10/12/2025"),
                    _meetingListTile("HR Meeting", "08:30am", "10/12/2025"),
                    _meetingListTile("Board Meetings", "08:30am", "10/12/2025"),
                    _meetingListTile("Meetings", "08:30am", "10/12/2025"),
                    _meetingListTile("Meetings", "08:30am", "10/12/2025"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meetingListTile(String title, String time, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontSize: 17)),
              const SizedBox(height: 3),
              Text(time, style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
          Text(date, style: TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    );
  }

  String _focusedDayFormatted() {
    return "${_weekDay(_focusedDay.weekday)}, ${_monthName(_focusedDay.month)} ${_focusedDay.day}";
  }

  String _selectedDayFormatted() {
    if (_selectedDay == null) return '';
    return "${_weekDay(_selectedDay!.weekday)}, ${_monthName(_selectedDay!.month)} ${_selectedDay!.day}";
  }

  String _weekDay(int weekday) {
    const days = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    return days[weekday - 1];
  }

  String _monthName(int month) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[month - 1];
  }
}
