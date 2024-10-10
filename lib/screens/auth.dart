import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/screens/home.dart';
import 'package:to_do_list/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  final String? userId; // เพิ่ม property userId

  AuthScreen({this.userId});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // ผู้ใช้ login อยู่แล้ว
          // เก็บข้อมูล user ใน subcollection "users"
          _saveUserData(snapshot.data!.uid, snapshot.data!.email!);
          return HomeScreen();
        } else {
          // ผู้ใช้ยังไม่ได้ login แสดง LoginScreen
          return LoginScreen();
        }
      },
    );
  }

  // ฟังก์ชันสำหรับเก็บข้อมูล user ใน Firestore
  Future<void> _saveUserData(String userId, String email) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'email': email}, SetOptions(merge: true));
  }

  // ฟังก์ชันสำหรับลบข้อมูล user ใน Firestore (เรียกใช้ตอน logout)
  Future<void> _deleteUserData(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}
