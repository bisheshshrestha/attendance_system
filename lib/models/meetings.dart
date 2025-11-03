class Meeting {
  final String id;
  final String title;
  final String description;
  final String time;
  final String date;
  final String location;
  final List<String> attendees;
  final String status; // upcoming, completed, cancelled

  Meeting({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.location,
    required this.attendees,
    required this.status,
  });
}
