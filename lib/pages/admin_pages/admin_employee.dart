import 'package:flutter/material.dart';

class AdminEmployees extends StatefulWidget {
  @override
  State<AdminEmployees> createState() => _AdminEmployeesState();
}

class _AdminEmployeesState extends State<AdminEmployees> {
  final Color darkBlue = const Color(0xFF15194A);
  final Color lightBlue = const Color(0xFF1C2165);
  final Color accentBlue = const Color(0xFF7B82FF);

  // Mock data - Replace with Ninja API calls
  final List<Map<String, dynamic>> employees = [
    {
      "id": "001",
      "name": "John Doe",
      "email": "john@company.com",
      "department": "IT",
      "status": "Active"
    },
    {
      "id": "002",
      "name": "Jane Smith",
      "email": "jane@company.com",
      "department": "HR",
      "status": "Active"
    },
    {
      "id": "003",
      "name": "Mike Johnson",
      "email": "mike@company.com",
      "department": "Finance",
      "status": "Inactive"
    },
    {
      "id": "004",
      "name": "Sarah Williams",
      "email": "sarah@company.com",
      "department": "Marketing",
      "status": "Active"
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = employees
        .where((emp) =>
    emp["name"].toLowerCase().contains(searchQuery.toLowerCase()) ||
        emp["email"].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        title: Text("Employees", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: accentBlue),
            onPressed: () {
              _showAddEmployeeDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search employees...",
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: lightBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Employee List
          Expanded(
            child: filteredEmployees.isEmpty
                ? Center(
              child: Text(
                "No employees found",
                style: TextStyle(color: Colors.white54),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final emp = filteredEmployees[index];
                return _employeeCard(emp);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeCard(Map<String, dynamic> emp) {
    bool isActive = emp["status"] == "Active";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: accentBlue.withOpacity(0.3),
          child: Text(
            emp["name"][0],
            style: TextStyle(
              color: accentBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          emp["name"],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emp["email"],
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              "${emp["department"]} • ${emp["id"]}",
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                emp["status"],
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showEmployeeDetails(emp),
      ),
    );
  }

  void _showEmployeeDetails(Map<String, dynamic> emp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightBlue,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emp["name"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _detailRow("Email", emp["email"]),
            _detailRow("Employee ID", emp["id"]),
            _detailRow("Department", emp["department"]),
            _detailRow("Status", emp["status"]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text("Edit"),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.delete),
                  label: Text("Delete"),
                  onPressed: () => Navigator.pop(context),
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

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightBlue,
        title: Text("Add Employee", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Name",
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: darkBlue,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: darkBlue,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Department",
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: darkBlue,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
