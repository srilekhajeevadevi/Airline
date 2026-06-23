import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SkyRosterApp());
}

class SkyRosterApp extends StatelessWidget {
  const SkyRosterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sky Roster',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C2E91),
          primary: const Color(0xFF5C2E91),
          secondary: const Color(0xFF9068BE),
          background: const Color(0xFFF9F7FD),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F7FD),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.deepPurple.shade50, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C2E91),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5C2E91),
            side: const BorderSide(color: Color(0xFF5C2E91), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5C2E91), width: 1.8),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIconColor: const Color(0xFF5C2E91),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const DashboardPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  String selectedRole = 'Cabin Crew';
  bool isSignUp = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5C2E91).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDFC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 70,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.flight,
                      size: 70,
                      color: Color(0xFF5C2E91),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sky Roster',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C2E91),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Airline Crew Scheduling App',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 25),
                if (isSignUp) ...[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pilot', child: Text('Pilot')),
                    DropdownMenuItem(value: 'Cabin Crew', child: Text('Cabin Crew')),
                    DropdownMenuItem(value: 'Flight Engineer', child: Text('Flight Engineer')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedRole = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      final name = nameController.text.trim();
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      if (email.isEmpty) {
                        messenger.showSnackBar(const SnackBar(content: Text('Please enter email')));
                        return;
                      }
                      if (password.isEmpty) {
                        messenger.showSnackBar(const SnackBar(content: Text('Please enter password')));
                        return;
                      }
                      if (isSignUp && name.isEmpty) {
                        messenger.showSnackBar(const SnackBar(content: Text('Please enter full name')));
                        return;
                      }
                      if (!email.contains('@') || !email.contains('.')) {
                        messenger.showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
                        return;
                      }

                      if (isSignUp) {
                        try {
                          UserCredential userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          await FirebaseFirestore.instance
                              .collection('crew')
                              .doc(userCredential.user!.uid)
                              .set({
                            'uid': userCredential.user!.uid,
                            'name': name,
                            'email': email,
                            'role': selectedRole,
                            'flight': 'Not Assigned Yet',
                          });

                          await flutterTts.speak("Account created successfully");

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Crew account registered successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          setState(() {
                            isSignUp = false;
                            nameController.clear();
                            emailController.clear();
                            passwordController.clear();
                          });
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Registration failed: $e')),
                          );
                        }
                      } else {
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          await flutterTts.speak("Welcome crew to Sky Roster");

                          await Future.delayed(const Duration(seconds: 1));

                          navigator.pushReplacement(
                            MaterialPageRoute(builder: (context) => const DashboardPage()),
                          );
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Login failed: $e')),
                          );
                        }
                      }
                    },
                    child: Text(
                      isSignUp ? 'Register Crew' : 'Crew Login',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!isSignUp) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await flutterTts.speak("Welcome to Sky Roster");
                        navigator.push(
                          MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                        );
                      },
                      child: const Text(
                        'Admin Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSignUp = !isSignUp;
                    });
                  },
                  child: Text(
                    isSignUp
                        ? 'Already have an account? Login'
                        : "Don't have an account? Sign Up",
                    style: const TextStyle(
                      color: Color(0xFF5C2E91),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Widget menuCard(BuildContext context, IconData icon, String title, Widget page) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 45, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        title: const Text('Sky Roster Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await FirebaseAuth.instance.signOut();
              navigator.pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            menuCard(context, Icons.flight, 'Flight Schedule',
                const FlightSchedulePage()),
            menuCard(context, Icons.groups, 'Crew Details',
                const CrewDetailsPage()),
            menuCard(context, Icons.event_available, 'Leave Request',
                const LeaveRequestPage()),
            menuCard(context, Icons.notifications, 'Notifications',
                const NotificationsPage()),
            menuCard(
                context, Icons.favorite, 'Wellness', const WellnessPage()),
            menuCard(context, Icons.person, 'Profile', const ProfilePage()),
            menuCard(
              context,
              Icons.warning,
              'Emergency Alert',
              const EmergencyAlertPage(),
            ),
            menuCard(
              context,
              Icons.bedtime,
              'Fatigue Check',
              const FatigueCheckPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class FlightSchedulePage extends StatelessWidget {
  const FlightSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Schedule'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('flights').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final flightDocs = snapshot.data!.docs;

          if (flightDocs.isEmpty) {
            return const Center(child: Text('No flights found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flightDocs.length,
            itemBuilder: (context, index) {
              final data = flightDocs[index].data() as Map<String, dynamic>;

              return Card(
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.flight_takeoff,
                    color: Colors.deepPurple,
                  ),
                  title: Text(data['flightNo'] ?? 'No Flight Number'),
                  subtitle: Text(data['status'] ?? 'No Status'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Route: ${data['route'] ?? 'No Route'}'),
                          const SizedBox(height: 8),
                          Text('Time: ${data['time'] ?? 'No Time'}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CrewDetailsPage extends StatelessWidget {
  const CrewDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crew Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('crew').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final crewDocs = snapshot.data!.docs;

          if (crewDocs.isEmpty) {
            return const Center(child: Text('No crew members found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: crewDocs.length,
            itemBuilder: (context, index) {
              final data =
              crewDocs[index].data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(
                    '${data['role'] ?? ''} • Flight: ${data['flight'] ?? 'Not Assigned'}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final nameController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCrewName();
  }

  Future<void> _loadCrewName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('crew').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
      } else {
        nameController.text = user.email ?? '';
      }
    }
    setState(() { isLoading = false; });
  }

  @override
  void dispose() {
    nameController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leave Request'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Request'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Crew Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: startDateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      startDate = picked;
                      startDateController.text = picked.toString().split(' ')[0];
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Start Date', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: endDateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      endDate = picked;
                      endDateController.text = picked.toString().split(' ')[0];
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'End Date', prefixIcon: Icon(Icons.calendar_month), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Reason', prefixIcon: Icon(Icons.edit_note), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final reason = reasonController.text.trim();
                    final messenger = ScaffoldMessenger.of(context);

                    if (name.isEmpty || startDate == null || endDate == null || reason.isEmpty) {
                      messenger.showSnackBar(const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red));
                      return;
                    }
                    if (!endDate!.isAfter(startDate!)) {
                      messenger.showSnackBar(const SnackBar(content: Text('End Date must be after Start Date'), backgroundColor: Colors.orange));
                      return;
                    }

                    await FirebaseFirestore.instance.collection('leave_requests').add({
                      'crewName': name,
                      'startDate': startDateController.text,
                      'endDate': endDateController.text,
                      'reason': reason,
                      'status': 'Pending',
                      'createdAt': Timestamp.now(),
                    });

                    messenger.showSnackBar(const SnackBar(content: Text('Leave request submitted successfully'), backgroundColor: Colors.deepPurple));
                    startDateController.clear();
                    endDateController.clear();
                    reasonController.clear();
                    setState(() { startDate = null; endDate = null; });
                  },
                  child: const Text('Submit Leave Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final isRead = data['read'] == true;

              return Card(
                color: isRead ? Colors.grey.shade100 : Colors.deepPurple.shade50,
                child: InkWell(
                  onTap: () async {
                    if (!isRead) {
                      await FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(doc.id)
                          .update({'read': true});
                    }
                  },
                  child: ListTile(
                    leading: Icon(
                      isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: isRead ? Colors.grey : Colors.deepPurple,
                    ),
                    title: Text(data['title'] ?? 'No Title', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(data['message'] ?? 'No Message'),
                    trailing: isRead ? const Text('Read', style: TextStyle(color: Colors.grey, fontSize: 12)) : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> {
  final sleepController = TextEditingController();
  final stressController = TextEditingController();
  final healthController = TextEditingController();

  @override
  void dispose() {
    sleepController.dispose();
    stressController.dispose();
    healthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Tracker'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: sleepController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sleep Hours',
                  prefixIcon: Icon(Icons.bed),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: stressController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stress Level (1-10)',
                  prefixIcon: Icon(Icons.mood),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: healthController,
                decoration: const InputDecoration(
                  labelText: 'Health Status',
                  prefixIcon: Icon(Icons.favorite),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Fit, Tired, Sick',
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final sleep = sleepController.text.trim();
                  final stress = stressController.text.trim();
                  final health = healthController.text.trim();
                  final messenger = ScaffoldMessenger.of(context);

                  if (sleep.isEmpty || stress.isEmpty || health.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final user = FirebaseAuth.instance.currentUser;
                  String name = 'Unknown Crew';
                  if (user != null) {
                    final doc = await FirebaseFirestore.instance.collection('crew').doc(user.uid).get();
                    if (doc.exists) {
                      final data = doc.data() as Map<String, dynamic>;
                      name = data['name'] ?? name;
                    } else {
                      name = user.email ?? name;
                    }
                  }

                  await FirebaseFirestore.instance.collection('wellness_reports').add({
                    'crewName': name,
                    'sleepHours': sleep,
                    'stressLevel': stress,
                    'healthStatus': health,
                    'createdAt': Timestamp.now(),
                  });

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Wellness report submitted'),
                      backgroundColor: Colors.deepPurple,
                    ),
                  );

                  sleepController.clear();
                  stressController.clear();
                  healthController.clear();
                },
                child: const Text('Submit Wellness Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final phoneController = TextEditingController();
  final baseController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    baseController.dispose();
    super.dispose();
  }

  void _showEditDialog(BuildContext context, String uid, String currentPhone, String currentBase) {
    phoneController.text = currentPhone;
    baseController.text = currentBase;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 12),
            TextField(controller: baseController, decoration: const InputDecoration(labelText: 'Base Location', prefixIcon: Icon(Icons.location_on))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('crew').doc(uid).update({
                'phone': phoneController.text.trim(),
                'base': baseController.text.trim(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
        body: const Center(child: Text('No crew member logged in.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('crew').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          String name = user.email ?? 'Unknown';
          String role = 'Crew';
          String phone = '';
          String base = '';
          final crewId = user.uid.length >= 6 ? user.uid.substring(0, 6).toUpperCase() : user.uid;
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? name;
            role = data['role'] ?? role;
            phone = data['phone'] ?? '';
            base = data['base'] ?? '';
          } else {
            name = 'Admin'; role = 'Administrator';
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: const Icon(Icons.person, size: 50, color: Colors.deepPurple),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: InkWell(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Picture upload: Tap to select image (requires image_picker plugin)'))),
                        child: const CircleAvatar(radius: 16, backgroundColor: Colors.deepPurple, child: Icon(Icons.camera_alt, size: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(child: ListTile(leading: const Icon(Icons.badge), title: const Text('Crew ID'), subtitle: Text(crewId))),
                Card(child: ListTile(leading: const Icon(Icons.person), title: const Text('Name'), subtitle: Text(name))),
                Card(child: ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(user.email ?? ''))),
                Card(child: ListTile(leading: const Icon(Icons.work), title: const Text('Role'), subtitle: Text(role))),
                Card(child: ListTile(leading: const Icon(Icons.phone), title: const Text('Phone'), subtitle: Text(phone.isEmpty ? 'Not set' : phone))),
                Card(child: ListTile(leading: const Icon(Icons.location_on), title: const Text('Base Location'), subtitle: Text(base.isEmpty ? 'Not set' : base))),
                const SizedBox(height: 10),
                // Total flight hours
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('assignments')
                      .where('crewName', isEqualTo: name)
                      .where('status', isEqualTo: 'Completed')
                      .get(),
                  builder: (ctx, assignSnap) {
                    final hours = (assignSnap.data?.docs.length ?? 0) * 2; // estimate 2h per flight
                    final overLimit = hours > 100;
                    return Card(
                      color: overLimit ? Colors.red.shade50 : null,
                      child: ListTile(
                        leading: Icon(Icons.timer, color: overLimit ? Colors.red : Colors.deepPurple),
                        title: Text('Total Flight Hours (Completed)', style: TextStyle(color: overLimit ? Colors.red : null)),
                        subtitle: Text('$hours hrs (${assignSnap.data?.docs.length ?? 0} flights × 2h)'),
                        trailing: overLimit ? const Icon(Icons.warning, color: Colors.red) : null,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: () => _showEditDialog(context, user.uid, phone, base),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _hoursWarningCheck(AsyncSnapshot snapshot) => false;
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Widget statCard(String title, Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(title),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget adminCard(BuildContext context, IconData icon, String title, Widget page) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 45, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency SOS Banner
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('emergency_alerts')
                .where('status', isEqualTo: 'Pending')
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasData && snap.data!.docs.isNotEmpty) {
                final alert = snap.data!.docs.first.data() as Map<String, dynamic>;
                return Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SOS Alert from ${alert['crewName']}: ${alert['message']}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEmergencyAlertsPage())),
                        child: const Text('View', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: statCard(
                          'Crew',
                          FirebaseFirestore.instance.collection('crew').snapshots(),
                        ),
                      ),
                      Expanded(
                        child: statCard(
                          'Flights',
                          FirebaseFirestore.instance.collection('flights').snapshots(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        adminCard(context, Icons.add, 'Add Flight', const AddFlightPage()),
                        adminCard(context, Icons.check_circle, 'Approve Leave', const ApproveLeavePage()),
                        adminCard(context, Icons.favorite, 'Wellness Reports', const AdminWellnessReportPage()),
                        adminCard(context, Icons.people, 'Manage Crew', const ManageCrewPage()),
                        adminCard(context, Icons.notifications, 'Notifications', const NotificationsPage()),
                        adminCard(context, Icons.assignment, 'Assign Flight', const AssignFlightPage()),
                        adminCard(context, Icons.assignment, 'My Assigned Flights', const MyAssignedFlightsPage()),
                        adminCard(context, Icons.update, 'Update Flight Status', const UpdateFlightStatusPage()),
                        adminCard(context, Icons.warning, 'Emergency Alerts', const AdminEmergencyAlertsPage()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddFlightPage extends StatefulWidget {
  const AddFlightPage({super.key});

  @override
  State<AddFlightPage> createState() => _AddFlightPageState();
}

class _AddFlightPageState extends State<AddFlightPage> {
  final flightNoController = TextEditingController();
  final routeController = TextEditingController();
  final timeController = TextEditingController();
  final statusController = TextEditingController();

  @override
  void dispose() {
    flightNoController.dispose();
    routeController.dispose();
    timeController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> addFlight() async {
    final flightNo = flightNoController.text.trim();
    final route = routeController.text.trim();
    final time = timeController.text.trim();
    final status = statusController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (flightNo.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter Flight Number')));
      return;
    }
    if (route.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter Route')));
      return;
    }
    if (time.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please select Date and Time')));
      return;
    }
    if (status.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter Status')));
      return;
    }

    final duplicateCheck = await FirebaseFirestore.instance
        .collection('flights')
        .where('flightNo', isEqualTo: flightNo)
        .get();

    if (duplicateCheck.docs.isNotEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Flight Number already exists')));
      return;
    }
    await FirebaseFirestore.instance.collection('flights').add({
      'flightNo': flightNo,
      'route': route,
      'time': time,
      'status': status,
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Flight added successfully'),
        backgroundColor: Colors.deepPurple,
      ),
    );

    flightNoController.clear();
    routeController.clear();
    timeController.clear();
    statusController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Flight Schedule'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: flightNoController,
                decoration: const InputDecoration(
                  labelText: 'Flight Number',
                  prefixIcon: Icon(Icons.flight),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: routeController,
                decoration: const InputDecoration(
                  labelText: 'Route',
                  prefixIcon: Icon(Icons.route),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: timeController,
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null && context.mounted) {
                      setState(() {
                        timeController.text = '${date.toString().split(' ')[0]} ${time.format(context)}';
                      });
                    }
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: statusController,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: addFlight,
                child: const Text('Add Flight'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApproveLeavePage extends StatelessWidget {
  const ApproveLeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve Leave'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final leaveDocs = snapshot.data!.docs;

          if (leaveDocs.isEmpty) {
            return const Center(child: Text('No leave requests found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaveDocs.length,
            itemBuilder: (context, index) {
              final doc = leaveDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.event_available,
                    color: Colors.deepPurple,
                  ),
                  title: Text(data['crewName'] ?? 'No Name'),
                  subtitle: Text(
                    'Date: ${data['leaveDate'] ?? 'No Date'}\n'
                        'Reason: ${data['reason'] ?? 'No Reason'}\n'
                        'Status: ${data['status'] ?? 'Pending'}',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await FirebaseFirestore.instance
                              .collection('leave_requests')
                              .doc(doc.id)
                              .update({'status': 'Approved'});
                          await FirebaseFirestore.instance.collection('notifications').add({
                            'title': 'Leave Approved',
                            'message': 'Your leave request has been approved',
                            'createdAt': Timestamp.now(),
                          });

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Leave approved'),
                              backgroundColor: Colors.deepPurple,
                            ),
                          );
                        },
                        child: const Text('Approve'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await FirebaseFirestore.instance
                              .collection('leave_requests')
                              .doc(doc.id)
                              .update({'status': 'Rejected'});
                          await FirebaseFirestore.instance.collection('notifications').add({
                            'title': 'Leave Rejected',
                            'message': 'Your leave request has been rejected',
                            'createdAt': Timestamp.now(),
                          });

                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Leave rejected'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminWellnessReportPage extends StatelessWidget {
  const AdminWellnessReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Reports'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wellness_reports')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No wellness reports found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['crewName'] ?? 'Unknown Crew';
              final sleep = data['sleepHours'] ?? '';
              final stress = data['stressLevel'] ?? '';
              final health = data['healthStatus'] ?? '';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.deepPurple),
                  title: Text(name),
                  subtitle: Text(
                      'Sleep: $sleep hrs\nStress: $stress/10\nStatus: $health'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ManageCrewPage extends StatelessWidget {
  const ManageCrewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Crew'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('crew').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final crewDocs = snapshot.data!.docs;

          if (crewDocs.isEmpty) {
            return const Center(child: Text('No crew members found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: crewDocs.length,
            itemBuilder: (context, index) {
              final data = crewDocs[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final role = data['role'] ?? 'Crew';
              final email = data['email'] ?? 'No email';
              final uid = crewDocs[index].id;
              final shortId = uid.length >= 6 ? uid.substring(0, 6).toUpperCase() : uid;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  subtitle: Text('$role • ID: $shortId\n$email'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AssignFlightPage extends StatefulWidget {
  const AssignFlightPage({super.key});

  @override
  State<AssignFlightPage> createState() => _AssignFlightPageState();
}

class _AssignFlightPageState extends State<AssignFlightPage> {
  final flightController = TextEditingController();
  final routeController = TextEditingController();
  final dateController = TextEditingController();
  String? selectedCrewName;
  List<String> crewNames = [];
  bool loadingCrew = true;

  @override
  void initState() {
    super.initState();
    _loadCrewNames();
  }

  Future<void> _loadCrewNames() async {
    final snap = await FirebaseFirestore.instance.collection('crew').get();
    final names = snap.docs.map((d) => (d.data()['name'] ?? '') as String).where((n) => n.isNotEmpty).toList();
    setState(() {
      crewNames = names;
      loadingCrew = false;
    });
  }

  @override
  void dispose() {
    flightController.dispose();
    routeController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> assignFlight() async {
    final crew = selectedCrewName ?? '';
    final flight = flightController.text.trim();
    final route = routeController.text.trim();
    final date = dateController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (crew.isEmpty || flight.isEmpty || route.isEmpty || date.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please fill all details'), backgroundColor: Colors.red));
      return;
    }

    // Conflict check: same crew on same date
    final conflict = await FirebaseFirestore.instance
        .collection('assignments')
        .where('crewName', isEqualTo: crew)
        .where('date', isEqualTo: date)
        .where('status', isEqualTo: 'Assigned')
        .get();

    if (conflict.docs.isNotEmpty) {
      messenger.showSnackBar(SnackBar(
        content: Text('Conflict: $crew is already assigned a flight on $date'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    await FirebaseFirestore.instance.collection('assignments').add({
      'crewName': crew,
      'flightNo': flight,
      'route': route,
      'date': date,
      'status': 'Assigned',
    });

    // Write notification for assigned crew
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': 'Flight Assigned',
      'message': 'You have been assigned Flight $flight on $date (Route: $route)',
      'targetCrew': crew,
      'read': false,
      'createdAt': Timestamp.now(),
    });

    final query = await FirebaseFirestore.instance.collection('crew').where('name', isEqualTo: crew).get();
    for (var doc in query.docs) {
      await doc.reference.update({'flight': flight});
    }

    messenger.showSnackBar(const SnackBar(content: Text('Flight Assigned Successfully'), backgroundColor: Colors.deepPurple));

    setState(() { selectedCrewName = null; });
    flightController.clear();
    routeController.clear();
    dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Flight'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              loadingCrew
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: selectedCrewName,
                    decoration: const InputDecoration(
                      labelText: 'Select Crew Member',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: crewNames.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                    onChanged: (val) => setState(() => selectedCrewName = val),
                  ),
              const SizedBox(height: 15),
              TextField(
                controller: flightController,
                decoration: const InputDecoration(
                  labelText: 'Flight Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flight),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: routeController,
                decoration: const InputDecoration(
                  labelText: 'Route',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.route),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      dateController.text = picked.toString().split(' ')[0];
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: assignFlight,
                  child: const Text('Assign Flight'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAssignedFlightsPage extends StatelessWidget {
  const MyAssignedFlightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assigned Flights'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: user != null
            ? FirebaseFirestore.instance.collection('crew').doc(user.uid).get()
            : Future.value(null as DocumentSnapshot?),
        builder: (context, userSnap) {
          final crewName = (userSnap.hasData && userSnap.data != null && userSnap.data!.exists)
              ? ((userSnap.data!.data() as Map<String, dynamic>)['name'] ?? '') as String
              : (user?.email ?? '');
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('assignments')
                .where('crewName', isEqualTo: crewName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final flights = snapshot.data!.docs;
              if (flights.isEmpty) return const Center(child: Text('No assigned flights found'));
              return ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  final doc = flights[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isDone = data['status'] == 'Completed';
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      leading: Icon(Icons.flight, color: isDone ? Colors.green : Colors.deepPurple),
                      title: Text(data['flightNo'] ?? ''),
                      subtitle: Text('Route: ${data['route']}\nDate: ${data['date']}\nStatus: ${data['status']}'),
                      trailing: isDone
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('assignments').doc(doc.id).update({'status': 'Completed'});
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Completed'), backgroundColor: Colors.green));
                                }
                              },
                              child: const Text('Mark Completed'),
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UpdateFlightStatusPage extends StatelessWidget {
  const UpdateFlightStatusPage({super.key});

  Future<void> updateStatus(String docId, String status) async {
    await FirebaseFirestore.instance
        .collection('flights')
        .doc(docId)
        .update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Flight Status'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('flights').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final flights = snapshot.data!.docs;

          if (flights.isEmpty) {
            return const Center(child: Text('No flights found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final doc = flights[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.flight, color: Colors.deepPurple),
                  title: Text(data['flightNo'] ?? 'No Flight'),
                  subtitle: Text(
                    '${data['route'] ?? 'No Route'}\nCurrent Status: ${data['status'] ?? 'No Status'}',
                  ),
                  trailing: DropdownButton<String>(
                    value: ['On Time', 'Delayed', 'Boarding', 'Cancelled']
                        .contains(data['status'])
                        ? data['status']
                        : 'On Time',
                    items: const [
                      DropdownMenuItem(value: 'On Time', child: Text('On Time')),
                      DropdownMenuItem(value: 'Delayed', child: Text('Delayed')),
                      DropdownMenuItem(value: 'Boarding', child: Text('Boarding')),
                      DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        await updateStatus(doc.id, value);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EmergencyAlertPage extends StatelessWidget {
  const EmergencyAlertPage({super.key});

  Future<void> sendSosAlert(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm SOS Alert', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to send an SOS Emergency Alert? This will immediately notify all admins.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm SOS'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    final messenger = ScaffoldMessenger.of(context);
    String name = 'Unknown Crew';
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('crew').doc(user.uid).get();
      if (doc.exists) name = (doc.data() as Map<String, dynamic>)['name'] ?? name;
      else name = user.email ?? name;
    }

    await FirebaseFirestore.instance.collection('emergency_alerts').add({
      'crewName': name,
      'alertType': 'SOS',
      'message': 'SOS Emergency Alert reported by $name',
      'status': 'Pending',
      'createdAt': Timestamp.now(),
    });

    if (context.mounted) {
      messenger.showSnackBar(const SnackBar(content: Text('SOS Alert sent to Admin!'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alert'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              const Text('Press the SOS button below in case of an emergency.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 12,
                  ),
                  onPressed: () => sendSosAlert(context),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos, size: 60),
                      SizedBox(height: 8),
                      Text('SOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminEmergencyAlertsPage extends StatelessWidget {
  const AdminEmergencyAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alerts'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_alerts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!.docs;

          if (alerts.isEmpty) {
            return const Center(child: Text('No emergency alerts found'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final doc = alerts[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red),
                  title: Text(data['alertType'] ?? ''),
                  subtitle: Text(
                    'Crew: ${data['crewName'] ?? ''}\nStatus: ${data['status'] ?? ''}',
                  ),
                  trailing: data['status'] == 'Resolved'
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await FirebaseFirestore.instance
                          .collection('emergency_alerts')
                          .doc(doc.id)
                          .update({'status': 'Resolved'});

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Alert resolved'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Resolve'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FatigueCheckPage extends StatefulWidget {
  const FatigueCheckPage({super.key});

  @override
  State<FatigueCheckPage> createState() => _FatigueCheckPageState();
}

class _FatigueCheckPageState extends State<FatigueCheckPage> {
  final previousFlightEndController = TextEditingController();
  final nextFlightStartController = TextEditingController();

  String result = '';
  String shiftType = '';

  @override
  void dispose() {
    previousFlightEndController.dispose();
    nextFlightStartController.dispose();
    super.dispose();
  }

  Future<void> checkRestTime() async {
    final previousEnd = int.tryParse(previousFlightEndController.text) ?? 0;
    final nextStart = int.tryParse(nextFlightStartController.text) ?? 0;

    int restHours = nextStart - previousEnd;

    if (restHours < 0) {
      restHours = restHours + 24;
    }

    if (nextStart >= 6 && nextStart < 14) {
      shiftType = 'Morning Shift';
    } else if (nextStart >= 14 && nextStart < 22) {
      shiftType = 'Evening Shift';
    } else {
      shiftType = 'Night Shift';
    }

    setState(() {
      if (restHours >= 10) {
        result = 'Fit for next duty\nRest Time: $restHours hours\n$shiftType';
      } else {
        result =
        'Rest Conflict Alert\nOnly $restHours hours rest available\nMinimum 10 hours required';
      }
    });

    final user = FirebaseAuth.instance.currentUser;
    String name = 'Unknown Crew';
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('crew').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        name = data['name'] ?? name;
      } else {
        name = user.email ?? name;
      }
    }

    await FirebaseFirestore.instance.collection('rest_time_checks').add({
      'crewName': name,
      'previousFlightEnd': previousEnd,
      'nextFlightStart': nextStart,
      'restHours': restHours,
      'shiftType': shiftType,
      'result': result,
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest Time Checker'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: previousFlightEndController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Previous Flight End Time (0-23)',
                  hintText: 'Example: 22',
                  prefixIcon: Icon(Icons.flight_land),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nextFlightStartController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Next Flight Start Time (0-23)',
                  hintText: 'Example: 8',
                  prefixIcon: Icon(Icons.flight_takeoff),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: checkRestTime,
                child: const Text('Check Rest Time'),
              ),
              const SizedBox(height: 20),
              if (result.isNotEmpty)
                Text(
                  result,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: result.contains('Conflict') ? Colors.red : Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}