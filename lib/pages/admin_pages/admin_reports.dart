import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class AdminReports extends StatefulWidget {
  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  String selectedMonth = "November 2025";
  bool isExporting = false;

  // Mock attendance data for export
  final List<Map<String, dynamic>> attendanceData = [
    {
      "Name": "John Doe",
      "Date": "2025-11-02",
      "Check In": "09:00 AM",
      "Check Out": "06:30 PM",
      "Status": "Present"
    },
    {
      "Name": "Jane Smith",
      "Date": "2025-11-02",
      "Check In": "09:15 AM",
      "Check Out": "06:45 PM",
      "Status": "Present"
    },
    {
      "Name": "Mike Johnson",
      "Date": "2025-11-02",
      "Check In": "09:45 AM",
      "Check Out": "-",
      "Status": "Late"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: Text("Reports", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Text(
              "Select Month",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedMonth,
                dropdownColor: lightBlue,
                isExpanded: true,
                underline: SizedBox(),
                items: [
                  "November 2025",
                  "October 2025",
                  "September 2025",
                  "August 2025",
                ]
                    .map((month) => DropdownMenuItem(
                  value: month,
                  child: Text(
                    month,
                    style: TextStyle(color: Colors.white),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedMonth = value ?? selectedMonth);
                },
              ),
            ),

            const SizedBox(height: 30),

            // Report Cards
            _reportCard(
              title: "Attendance Summary",
              subtitle: "Export attendance records for selected month",
              icon: Icons.assessment,
              onTap: _exportAttendanceCSV,
            ),
            _reportCard(
              title: "Employee Statistics",
              subtitle: "View employee attendance statistics",
              icon: Icons.people,
              onTap: () => _showEmployeeStats(),
            ),
            _reportCard(
              title: "Absence Report",
              subtitle: "List of absent employees",
              icon: Icons.person_off,
              onTap: () => _showAbsenceReport(),
            ),
            _reportCard(
              title: "Late Arrivals Report",
              subtitle: "Employees who arrived late",
              icon: Icons.schedule,
              onTap: () => _showLateArrivalsReport(),
            ),

            const SizedBox(height: 30),

            // Export All Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.download),
                label: Text("Export All Data"),
                onPressed: isExporting ? null : _exportAllData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (isExporting) ...[
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: accentBlue),
                    const SizedBox(height: 10),
                    Text(
                      "Exporting data...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accentBlue, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: accentBlue, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportAttendanceCSV() async {
    setState(() => isExporting = true);

    try {
      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ["Name", "Date", "Check In", "Check Out", "Status"],
        ...attendanceData.map((row) => [
          row["Name"],
          row["Date"],
          row["Check In"],
          row["Check Out"],
          row["Status"],
        ])
      ];

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(csvData);

      // Get directory to save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/Attendance_Report_$selectedMonth.csv";

      // Write file
      final file = File(filePath);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("File exported to: $filePath"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Export failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isExporting = false);
    }
  }

  void _exportAllData() async {
    setState(() => isExporting = true);
    await Future.delayed(Duration(seconds: 2));
    setState(() => isExporting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All data exported successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showEmployeeStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: Text("Employee Statistics", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statRow("Total Employees", "125"),
            _statRow("Present", "118"),
            _statRow("Absent", "7"),
            _statRow("Average Attendance", "94.4%"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAbsenceReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: Text("Absence Report", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reportRow("Sarah Williams", "2025-11-02"),
            _reportRow("David Brown", "2025-11-02"),
            _reportRow("Emma Davis", "2025-11-01"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showLateArrivalsReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: Text("Late Arrivals", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reportRow("Mike Johnson", "09:45 AM"),
            _reportRow("Tom Wilson", "09:30 AM"),
            _reportRow("Lisa Anderson", "09:15 AM"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _reportRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: Colors.white)),
          Text(value, style: TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }
}
