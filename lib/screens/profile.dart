import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tasc/extras/reusable.dart';

import '../dbms/dbcreds.dart';
import '../dbms/dbmanager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late final DataConnection _dataConnection;
  List<List<dynamic>> profileDetails = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataConnection = DataConnection();
    _initializeConnection();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeConnection() async {
    try {
      await _dataConnection.openConnection(
        DBCreds.host,
        DBCreds.database,
        DBCreds.username,
        DBCreds.password,
        DBCreds.port,
      );
      await downloadProfileData();
    } catch (e) {
      _handleError("Error initializing the connection: $e");
    }
  }

  void _handleError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  Future<void> downloadProfileData() async {
    try {
      profileDetails = await _dataConnection.fetchData(
          '''SELECT * FROM "User" WHERE email='${FirebaseAuth.instance.currentUser?.email}' ''');
      print(profileDetails);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(profileDetails);
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: RadialGradient(
              radius: 2,
              colors: [
                Colors.deepPurple.shade100,
                Colors.deepPurple.shade50.withOpacity(0.2)
              ],
              center: Alignment.bottomLeft)),
      child: DecoratedBox(
        decoration: BoxDecoration(
            backgroundBlendMode: BlendMode.multiply,
            gradient: RadialGradient(
                colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
                center: Alignment.topRight)),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Profile"),
            backgroundColor: Colors.transparent,
            actions: [feedbackBeggar(context)],
          ),
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      "${profileDetails[0][4]}",
                      scale: 0.5,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(
                    profileDetails[0][5],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(profileDetails[0][6]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
