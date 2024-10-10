import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // เพิ่ม import Firestore กลับมา

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromRGBO(162, 128, 93, 1.0), // AppBar color
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(218, 198, 163, 1.0), // Background color
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          // เปลี่ยนจาก Icon เป็น Image.network
                          'https://upload.wikimedia.org/wikipedia/commons/6/6d/Todoist_logo.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value!;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              try {
                                UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: _email, password: _password);

                                // รับ user ID และ email
                                String userId = userCredential.user!.uid;
                                String email = userCredential.user!.email!;

                                // เก็บข้อมูล user ใน Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId) // ใช้ userId เป็น document ID
                                    .set({
                                  'email': email,
                                  'userId': userId, // เก็บ userId ด้วย
                                });

                                // นำทางไปยังหน้า LoginScreen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  // แสดง SnackBar สำหรับรหัสผ่านอ่อนแอ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'The password provided is too weak.')),
                                  );
                                } else if (e.code == 'email-already-in-use') {
                                  // แสดง SnackBar สำหรับอีเมลที่ใช้งานแล้ว
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'The account already exists for that email.')),
                                  );
                                } else {
                                  // แสดง SnackBar อีเมลผิดรูปแบบ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.message!)),
                                  );
                                }
                              } catch (e) {
                                // แสดง SnackBar สำหรับข้อผิดพลาดทั่วไป
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: Text('Signup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(
                                162, 128, 93, 1.0), // Button color
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
