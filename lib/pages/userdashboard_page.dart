import 'package:flutter/material.dart';

class UserDashboardPage extends StatelessWidget {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome! Rahma-Ahmed",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              // Attendance Status Card
              Container(
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(34),
                ),
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: CircularProgressIndicator(
                        value: 0.45,
                        strokeWidth: 8,
                        backgroundColor: accentBlue.withOpacity(0.25),
                        color: accentBlue,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Started", style: TextStyle(color: Colors.white, fontSize: 17)),
                          Row(children: [
                            Icon(Icons.location_on, color: accentBlue, size: 16),
                            SizedBox(width: 6),
                            Text("Egypt, Cairo", style: TextStyle(color: Colors.white70)),
                          ]),
                          Text("06:35 AM", style: TextStyle(color: accentBlue, fontSize: 20)),
                          const SizedBox(height: 10),
                          Text("Ended", style: TextStyle(color: Colors.white, fontSize: 17)),
                          Text("No location", style: TextStyle(color: Colors.white70)),
                          Text("End Shift", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(icon: Icons.calendar_month, label: "Leave"),
                  _actionButton(icon: Icons.article, label: "News"),
                  _actionButton(icon: Icons.group, label: "Team"),
                  _actionButton(icon: Icons.description, label: "Report"),
                ],
              ),
              const SizedBox(height: 18),
              // Schedule Section
              Text(
                "Schedule",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text("see details", style: TextStyle(color: accentBlue, fontSize: 13)),
              const SizedBox(height: 10),
              _meetingCard("Meetings", "08:30am"),
              _meetingCard("Meetings", "08:30am"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: lightBlue.withOpacity(0.85),
          radius: 22,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        SizedBox(height: 7),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 15)),
      ],
    );
  }

  Widget _meetingCard(String meeting, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(meeting, style: TextStyle(color: Colors.white, fontSize: 17)),
          Text(time, style: TextStyle(color: Colors.white, fontSize: 17)),
        ],
      ),
    );
  }
}