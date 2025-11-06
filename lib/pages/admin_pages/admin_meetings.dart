import 'package:attendance_system/api_services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AdminMeetingsPage extends StatefulWidget {
  const AdminMeetingsPage({super.key});

  @override
  State<AdminMeetingsPage> createState() => _AdminMeetingsPageState();
}

class _AdminMeetingsPageState extends State<AdminMeetingsPage> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String selectedFilter = "All";

  // ✅ FIXED: Remove 'late' and initialize with empty future
  Future<List<Map<String, dynamic>>> _meetingsFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// ✅ Initialize meetings from SharedPreferences
  Future<void> _initializeData() async {
    debugPrint('🔄 Initializing admin meetings data...');
    await AppService.initializeMeetings();
    _refreshMeetings();
  }

  /// ✅ Refresh meetings - ensures latest data
  void _refreshMeetings() {
    debugPrint('🔄 Refreshing meetings in admin page...');
    setState(() {
      _meetingsFuture = AppService.getMeetings();
    });
  }

  Future<void> _showAddMeetingDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: Text(
          "Add Meeting",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Meeting Title",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2026),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: accentBlue,
                            onPrimary: Colors.white,
                            surface: lightBlue,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    dateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    enabled: false,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Select Date",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: darkBlue,
                      suffixIcon: Icon(Icons.calendar_today, color: accentBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: accentBlue,
                            onPrimary: Colors.white,
                            surface: lightBlue,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    final now = DateTime.now();
                    final dt = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    final formatted = DateFormat('hh:mm a').format(dt);
                    timeController.text = formatted;
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: timeController,
                    enabled: false,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Select Time",
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: darkBlue,
                      suffixIcon: Icon(Icons.schedule, color: accentBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Location",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  dateController.text.isEmpty ||
                  timeController.text.isEmpty ||
                  locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Please fill all fields"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final dateTime =
                  "${dateController.text} ${timeController.text}";

              final result = await AppService.createMeeting(
                title: titleController.text,
                description: descriptionController.text,
                dateTime: dateTime,
                location: locationController.text,
                attendees: [],
                status: "upcoming",
              );

              if (result['success']) {
                Navigator.pop(context);
                _refreshMeetings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✅ Meeting added successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text("Add", style: TextStyle(color: accentBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: Text(
          "Meetings & Schedule",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: accentBlue),
            onPressed: _showAddMeetingDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: accentBlue),
            onPressed: _refreshMeetings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar
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
                    "Select Date",
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TableCalendar(
                    firstDay: DateTime(2025, 1, 1),
                    lastDay: DateTime(2025, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: accentBlue.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: accentBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Filter Buttons
            Text(
              "Filter",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _filterChip("All"),
                _filterChip("Upcoming"),
                _filterChip("Completed"),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Meetings Schedule",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _meetingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: accentBlue),
                  );
                }

                final meetings = snapshot.data ?? [];

                if (meetings.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "No meetings scheduled",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }

                return Column(
                  children: meetings
                      .where((meeting) {
                    if (selectedFilter == "All") return true;
                    return meeting["status"]
                        .toString()
                        .toLowerCase()
                        .contains(selectedFilter.toLowerCase());
                  })
                      .map((meeting) => _meetingCard(meeting))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accentBlue : lightBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentBlue : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _meetingCard(Map<String, dynamic> meeting) {
    Color statusColor = meeting["status"] == "upcoming"
        ? Colors.green
        : Colors.blue;

    return GestureDetector(
      onLongPress: () => _showMeetingOptions(meeting),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meeting["title"] ?? "N/A",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meeting["status"]?.toUpperCase() ?? "UPCOMING",
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              meeting["description"] ?? "No description",
              style: TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: accentBlue, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      meeting["date_time"] ?? "N/A",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: accentBlue, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      meeting["location"] ?? "N/A",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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

  void _showMeetingOptions(Map<String, dynamic> meeting) {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlue,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              meeting["title"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              meeting["description"] ?? "",
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text("Edit"),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditMeetingDialog(meeting);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text("Delete"),
                  onPressed: () async {
                    final result =
                    await AppService.deleteMeeting(meeting["id"]);
                    if (result['success']) {
                      Navigator.pop(context);
                      _refreshMeetings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✅ Meeting deleted"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditMeetingDialog(Map<String, dynamic> meeting) async {
    final titleController = TextEditingController(text: meeting["title"]);
    final descriptionController =
    TextEditingController(text: meeting["description"]);
    final dateTimeController =
    TextEditingController(text: meeting["date_time"]);
    final locationController =
    TextEditingController(text: meeting["location"]);
    String selectedStatus = meeting["status"] ?? "upcoming";

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: Text(
          "Edit Meeting",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Meeting Title",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateTimeController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Date & Time",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Location",
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: darkBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: StatefulBuilder(
                  builder: (context, setStateDropdown) =>
                      DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        dropdownColor: darkBlue,
                        underline: Container(),
                        items: ["upcoming", "completed"].map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDropdown(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              final result = await AppService.updateMeeting(
                meetingId: meeting["id"],
                title: titleController.text,
                description: descriptionController.text,
                dateTime: dateTimeController.text,
                location: locationController.text,
                status: selectedStatus,
              );

              if (result['success']) {
                Navigator.pop(context);
                _refreshMeetings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✅ Meeting updated successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text("Update", style: TextStyle(color: accentBlue)),
          ),
        ],
      ),
    );
  }
}
