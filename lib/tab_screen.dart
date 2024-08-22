import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMK Negeri 4',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TabScreen(),
    );
  }
}

class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('SMK Negeri 4 - Mobile Apps'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Dashboard'),
              Tab(icon: Icon(Icons.people), text: 'Students'),
              Tab(icon: Icon(Icons.account_circle), text: 'Profile'),
            ],
            labelColor: const Color.fromARGB(255, 0, 0, 0),
            unselectedLabelColor: Color.fromARGB(255, 102, 166, 248),
            indicatorColor: Colors.white,
          ),
          backgroundColor: Color.fromARGB(255, 204, 236, 252),
        ),
        body: TabBarView(
          children: [
            DashboardTab(),
            StudentsTab(),
            ProfileTab(),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.book, 'label': 'Mata Pelajaran'},
    {'icon': Icons.event, 'label': 'Kalender Sekolah'},
    {'icon': Icons.notifications, 'label': 'Pengumuman'},
    {'icon': Icons.assignment, 'label': 'Pengumpulan Tugas'},
    {'icon': Icons.phone_android_rounded, 'label': 'Kontak'},
    {'icon': Icons.access_time, 'label': 'Jadwal KBM'},
    {'icon': Icons.help_outline, 'label': 'Tentang'},
  ];

  void _onMenuItemTap(BuildContext context, String label) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(label: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return GestureDetector(
            onTap: () => _onMenuItemTap(context, item['label']),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 50.0, color: Colors.blueGrey),
                  SizedBox(height: 8.0),
                  Text(
                    item['label'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.0, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String label;

  DetailScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    // Define text based on the label
    Map<String, String> descriptions = {
      'Mata Pelajaran':
          'Explore various subjects and their details here. Find out what topics are covered in each subject, the syllabus, and more.',
      'Kalender Sekolah':
          'View the school calendar to keep track of important dates, holidays, and events throughout the academic year.',
      'Pengumuman':
          'Stay updated with the latest announcements and notifications from the school administration.',
      'Pengumpulan Tugas':
          'Submit your assignments and track their status. Find submission deadlines and feedback from your teachers.',
      'Kontak':
          'Find contact information for school staff and faculty. Reach out to them via phone, email, or in person.',
      'Jadwal KBM':
          'Check the schedule for your classes and learning activities. See when and where each class takes place.',
      'Bantuan':
          'Get assistance with any issues or questions you have. Access guides, FAQs, and support contact information.',
    };

    // Retrieve the description for the selected label
    final description =
        descriptions[label] ?? 'No details available for $label.';

    return Scaffold(
      appBar: AppBar(
        title: Text(label),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display description text
            Text(
              description,
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            SizedBox(height: 20),
            // Add a button for further actions
            ElevatedButton(
              onPressed: () {
                // Handle button action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action for $label')),
                );
              },
              child: Text('Take Action'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentsTab extends StatelessWidget {
  Future<List<Student>> fetchStudents() async {
    final response =
        await http.get(Uri.parse('https://reqres.in/api/users?page=1'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((user) => Student.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Student>>(
        future: fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final students = snapshot.data!;
            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Text(student.firstName[0],
                        style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(student.firstName,
                      style: TextStyle(color: Colors.black87)),
                  subtitle: Text(student.email,
                      style: TextStyle(color: Colors.grey[600])),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/profile_picture.jpg'), // Ganti dengan path gambar profil
              backgroundColor: Color.fromARGB(255, 201, 87, 34),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'VVION',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Email: auliaviona005@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Profile Information',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey),
          ),
          Divider(color: Colors.blueGrey),
          ListTile(
            leading: Icon(Icons.person, color: Colors.blueGrey),
            title: Text('Full Name', style: TextStyle(color: Colors.blueGrey)),
            subtitle:
                Text('vionaaulia', style: TextStyle(color: Colors.grey[600])),
          ),
          ListTile(
            leading: Icon(Icons.cake, color: Colors.blueGrey),
            title:
                Text('Date of Birth', style: TextStyle(color: Colors.blueGrey)),
            subtitle: Text('3 January 2008',
                style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }
}

class Student {
  final String firstName;
  final String email;
  Student({required this.firstName, required this.email});
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      firstName: json['first_name'],
      email: json['email'],
    );
  }
}